module multiplex_memtoreg
#(
  parameter DATA_WIDTH = 32                       // Largura dos dados (padrão: 32 bits)
)
(
  // Entradas
  input  [DATA_WIDTH-1:0]  dado_lido_mem,         // Dado lido da memória RAM
  input  [DATA_WIDTH-1:0]  resultado_ula,         // Resultado da ULA
  input                    mem_to_reg,            // Sinal de controle (1: mem, 0: ULA)
  
  // Saídas
  output [DATA_WIDTH-1:0]  escolhido_multiplexador_mem_to_reg  // Valor selecionado
);

  // Registrador interno para armazenar seleção
  reg [DATA_WIDTH-1:0] escolhido;
  
  // Lógica combinacional de seleção
  always @(*) begin
    escolhido = mem_to_reg ? dado_lido_mem : resultado_ula;
  end
  
  // Atribuição da saída
  assign escolhido_multiplexador_mem_to_reg = escolhido;

endmodule
