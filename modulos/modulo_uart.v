module modulo_uart
#(
  parameter BAUD_DIV = 5208                        // 50 MHz / 9600 baud
)
(
  input            clk_50,                         // Clock de 50 MHz da placa
  input            send,                           // Controle 'uart_send' (dominio da CPU)
  input      [7:0] data_in,                        // Byte a transmitir (br_dado1[7:0])
  output           tx,                             // Pino serial para o RX do Arduino
  output           tx_ready                        // 1 quando a TX esta livre
);

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

endmodule
