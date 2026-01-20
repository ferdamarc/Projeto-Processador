module multiplex_ALUSrc
#(
  parameter DATA_WIDTH = 32                       // Largura dos dados (padrão: 32 bits)
)
(
  // Entradas
  input  [DATA_WIDTH-1:0] imediato,               // Valor imediato da instrução
  input  [DATA_WIDTH-1:0] br_dado2,               // Dado do banco de registradores
  input                   alu_src,                // Sinal de controle de seleção
  
  // Saídas
  output [DATA_WIDTH-1:0] escolhido_multiplexador_alu_src  // Valor selecionado
);

  // Registrador interno para armazenar seleção
  reg [DATA_WIDTH-1:0] escolhido;
  
  // Lógica combinacional de seleção
  always @(*) begin
    escolhido = alu_src ? imediato : br_dado2;    // Operador ternário para seleção
  end
  
  // Atribuição da saída
  assign escolhido_multiplexador_alu_src = escolhido;

endmodule
