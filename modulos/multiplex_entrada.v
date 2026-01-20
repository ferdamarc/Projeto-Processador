module multiplex_entrada
#(
  parameter DATA_WIDTH = 32                       // Largura dos dados (padrão: 32 bits)
)
(
  // Entradas
  input  [13:0]            dado_lido_entrada,     // Dado de entrada dos switches
  input  [DATA_WIDTH-1:0]  dado_memoria_ula,      // Dado da memória ou ULA
  input  [1:0]             in,                    // Sinal de controle (0: mem/ula, 1: entrada)
  
  // Saídas
  output [DATA_WIDTH-1:0]  escolhido_multiplexador_entrada  // Valor selecionado
);

  // Registrador interno para armazenar seleção
  reg [DATA_WIDTH-1:0] escolhido;
  
  // Lógica combinacional de seleção
  always @(*) begin
    if (in == 2'd1) begin
      escolhido = {{(DATA_WIDTH-14){1'b0}}, dado_lido_entrada};
    end else begin
      escolhido = dado_memoria_ula;
    end
  end
  
  // Atribuição da saída
  assign escolhido_multiplexador_entrada = escolhido;

endmodule
