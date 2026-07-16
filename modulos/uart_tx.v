module uart_tx
#(
  parameter BAUD_DIV = 5208                        // Ciclos de clock por bit
)
(
  input            clk,                            // Clock de 50 MHz
  input            start,                          // Pulso de 1 ciclo: inicia a transmissao
  input      [7:0] data_in,                        // Byte a transmitir
  output reg       tx,                             // Linha serial (idle = 1)
  output reg       busy                            // 1 enquanto transmite
);

  // Estados da maquina
  localparam IDLE  = 2'd0;
  localparam START = 2'd1;
  localparam DATA  = 2'd2;
  localparam STOP  = 2'd3;

  reg [1:0]  state;
  reg [12:0] baud_cnt;                             // Conta ate BAUD_DIV-1 (5207 cabe em 13 bits)
  reg [2:0]  bit_idx;                              // Indice do bit atual (0..7)
  reg [7:0]  shift;                                // Registrador de deslocamento (LSB primeiro)

  initial begin
    state    = IDLE;
    baud_cnt = 13'd0;
    bit_idx  = 3'd0;
    shift    = 8'd0;
    tx       = 1'b1;                               // Linha ociosa em nivel alto
    busy     = 1'b0;
  end

  always @(posedge clk) begin
    case (state)
      IDLE: begin
        tx       <= 1'b1;
        busy     <= 1'b0;
        baud_cnt <= 13'd0;
        bit_idx  <= 3'd0;
        if (start) begin
          shift <= data_in;                        // Captura o byte
          busy  <= 1'b1;
          state <= START;
        end
      end

      START: begin
        tx   <= 1'b0;                              // Start bit
        busy <= 1'b1;
        if (baud_cnt == BAUD_DIV - 1) begin
          baud_cnt <= 13'd0;
          state    <= DATA;
        end else begin
          baud_cnt <= baud_cnt + 1'b1;
        end
      end

      DATA: begin
        tx   <= shift[0];                          // Bit de dados, LSB primeiro
        busy <= 1'b1;
        if (baud_cnt == BAUD_DIV - 1) begin
          baud_cnt <= 13'd0;
          shift    <= {1'b0, shift[7:1]};          // Desloca para o proximo bit
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
        tx   <= 1'b1;                              // Stop bit
        busy <= 1'b1;
        if (baud_cnt == BAUD_DIV - 1) begin
          baud_cnt <= 13'd0;
          state    <= IDLE;
        end else begin
          baud_cnt <= baud_cnt + 1'b1;
        end
      end

      default: state <= IDLE;
    endcase
  end

endmodule
