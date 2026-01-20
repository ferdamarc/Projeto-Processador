module multiplex_jr
#(
  parameter ADDR_WIDTH = 13,                      // Largura do endereço (padrão: 13 bits)
  parameter DATA_WIDTH = 32                       // Largura dos dados (padrão: 32 bits)
)
(
  // Entradas
  input  [DATA_WIDTH-1:0]  dado1,                 // Dado do banco de registradores
  input  [ADDR_WIDTH-1:0]  jump,                  // Endereço de jump normal
  input                    jalr,                  // Sinal de controle JALR
  input                    j_reg,                 // Sinal de controle JR
  
  // Saídas
  output [ADDR_WIDTH-1:0]  escolhido_multiplexador_jump_reg  // Endereço selecionado
);

  // Registrador interno para armazenar seleção
  reg [ADDR_WIDTH-1:0] escolhido;
  
  // Lógica combinacional de seleção
  always @(*) begin
    if (jalr || j_reg) begin
      // Usa endereço do registrador para jump
      escolhido = dado1[ADDR_WIDTH-1:0];
    end else begin
      escolhido = jump;
    end
  end
  
  // Atribuição da saída
  assign escolhido_multiplexador_jump_reg = escolhido;

endmodule
