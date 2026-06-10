module uart_rx
#(
  parameter BAUD_DIV = 5208                        // Ciclos de clock por bit
)
(
  input            clk,                            // Clock de 50 MHz
  input            rx,                             // Linha serial (idle = 1), vinda do TX do Arduino
  output reg [7:0] data_out,                       // Ultimo byte recebido
  output reg       valid                           // Pulso de 1 ciclo quando um byte fica pronto
);

  // Estados da maquina
  localparam IDLE  = 2'd0;
  localparam START = 2'd1;
  localparam DATA  = 2'd2;
  localparam STOP  = 2'd3;

  // Sincronizador de 2 estagios para a linha rx (sinal assincrono)
  reg rx_sync1, rx_sync2;

  reg [1:0]  state;
  reg [12:0] baud_cnt;                             // Conta ciclos dentro de um bit
  reg [2:0]  bit_idx;                              // Indice do bit de dados atual (0..7)
  reg [7:0]  shift;                                // Montagem do byte (LSB primeiro)

  initial begin
    rx_sync1 = 1'b1;
    rx_sync2 = 1'b1;
    state    = IDLE;
    baud_cnt = 13'd0;
    bit_idx  = 3'd0;
    shift    = 8'd0;
    data_out = 8'd0;
    valid    = 1'b0;
  end

  always @(posedge clk) begin
    // Sincroniza a linha rx antes de qualquer uso
    rx_sync1 <= rx;
    rx_sync2 <= rx_sync1;

    // 'valid' e sempre um pulso de 1 ciclo
    valid <= 1'b0;

    case (state)
      IDLE: begin
        baud_cnt <= 13'd0;
        bit_idx  <= 3'd0;
        if (rx_sync2 == 1'b0) begin                // Borda de descida = start bit
          state <= START;
        end
      end

      START: begin
        // Espera ate o meio do start bit e confirma que ainda esta em 0
        if (baud_cnt == (BAUD_DIV/2 - 1)) begin
          baud_cnt <= 13'd0;
          if (rx_sync2 == 1'b0) begin
            state <= DATA;                         // Start valido
          end else begin
            state <= IDLE;                         // Falso start (ruido)
          end
        end else begin
          baud_cnt <= baud_cnt + 1'b1;
        end
      end

      DATA: begin
        // Apos cada periodo de bit completo, amostra no meio do bit
        if (baud_cnt == (BAUD_DIV - 1)) begin
          baud_cnt <= 13'd0;
          shift    <= {rx_sync2, shift[7:1]};      // LSB primeiro: novo bit entra no MSB
          if (bit_idx == 3'd7) begin
            state <= STOP;
          end else begin
            bit_idx <= bit_idx + 1'b1;
          end
        end else begin
          baud_cnt <= baud_cnt + 1'b1;
        end
      end

      STOP: begin
        // Espera o stop bit; ao fim do periodo entrega o byte montado
        if (baud_cnt == (BAUD_DIV - 1)) begin
          baud_cnt <= 13'd0;
          data_out <= shift;
          valid    <= 1'b1;                        // Pulso de 1 ciclo: byte pronto
          state    <= IDLE;
        end else begin
          baud_cnt <= baud_cnt + 1'b1;
        end
      end

      default: state <= IDLE;
    endcase
  end

endmodule
