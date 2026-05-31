module modulo_uart
#(
  parameter BAUD_DIV = 5208                        // 50 MHz / 9600 baud
)
(
  input            clk_50,                         // Clock de 50 MHz da placa
  input            send,                           // Controle 'uart_send' (dominio da CPU)
  input      [7:0] data_in,                        // Byte a transmitir (br_dado1[7:0])
  input            receive,                         // Controle 'uart_receive' (dominio da CPU): consome o byte
  input            rx,                             // Pino serial vindo do TX do Arduino
  output           tx,                             // Pino serial para o RX do Arduino
  output           tx_ready,                       // 1 quando a TX esta livre
  output     [7:0] data_out,                       // Ultimo byte recebido
  output           rx_ready                        // 1 quando ha um byte recebido nao consumido
);

  // ==========================================================================
  // TX
  // ==========================================================================

  // Sincronizacao do pulso 'send' para o dominio de 50 MHz e deteccao de borda
  reg send_sync1, send_sync2, send_prev;
  wire send_rising;

  initial begin
    send_sync1 = 1'b0;
    send_sync2 = 1'b0;
    send_prev  = 1'b0;
  end

  always @(posedge clk_50) begin
    send_sync1 <= send;
    send_sync2 <= send_sync1;
    send_prev  <= send_sync2;
  end

  assign send_rising = send_sync2 & ~send_prev;

  wire tx_busy;
  // So dispara se a TX estiver livre, evitando corromper uma transmissao em curso.
  wire start_pulse = send_rising & ~tx_busy;

  uart_tx #(
    .BAUD_DIV(BAUD_DIV)
  ) tx_inst (
    .clk(clk_50),
    .start(start_pulse),
    .data_in(data_in),
    .tx(tx),
    .busy(tx_busy)
  );

  assign tx_ready = ~tx_busy;

  // ==========================================================================
  // RX
  // ==========================================================================

  // Sincronizacao do pulso 'receive' (consumo do byte pela CPU) e deteccao de borda
  reg recv_sync1, recv_sync2, recv_prev;
  wire recv_rising;

  reg [7:0] rx_data_reg;                           // Guarda o ultimo byte recebido
  reg       rx_avail;                              // 1 = byte disponivel ainda nao consumido
  wire [7:0] rx_byte;
  wire       rx_valid;

  initial begin
    recv_sync1  = 1'b0;
    recv_sync2  = 1'b0;
    recv_prev   = 1'b0;
    rx_data_reg = 8'd0;
    rx_avail    = 1'b0;
  end

  always @(posedge clk_50) begin
    recv_sync1 <= receive;
    recv_sync2 <= recv_sync1;
    recv_prev  <= recv_sync2;
  end

  assign recv_rising = recv_sync2 & ~recv_prev;

  uart_rx #(
    .BAUD_DIV(BAUD_DIV)
  ) rx_inst (
    .clk(clk_50),
    .rx(rx),
    .data_out(rx_byte),
    .valid(rx_valid)
  );

  // Recebimento de byte tem prioridade sobre o consumo: se chegar um byte novo
  // no mesmo ciclo em que a CPU consome, o flag permanece ligado para o novo byte.
  always @(posedge clk_50) begin
    if (rx_valid) begin
      rx_data_reg <= rx_byte;                      // Novo byte recebido
      rx_avail    <= 1'b1;
    end else if (recv_rising) begin
      rx_avail    <= 1'b0;                          // CPU consumiu o byte
    end
  end

  assign data_out = rx_data_reg;
  assign rx_ready = rx_avail;

endmodule
