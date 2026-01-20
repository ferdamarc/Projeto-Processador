module multiplex_saida
#(
  parameter DATA_WIDTH = 32                       // Largura dos dados (padrão: 32 bits)
)
(
  // Entradas
  input  [13:0]            dado_lido_entrada,     // Dado de entrada dos switches
  input  [DATA_WIDTH-1:0]  resultado_ula,         // Resultado da ULA
  input                    in,                    // Sinal de controle IN
  input                    out,                   // Sinal de controle OUT
  
  // Saídas
  output [DATA_WIDTH-1:0]  escolhido_multiplexador_saida  // Valor selecionado
);

  // Registrador interno para armazenar seleção
  reg [DATA_WIDTH-1:0] escolhido;
  
  // Lógica combinacional de seleção
  always @(*) begin
    escolhido = {DATA_WIDTH{1'b0}};
    
    if (in == 1'b1) begin
      escolhido = {{(DATA_WIDTH-14){1'b0}}, dado_lido_entrada};
    end else if (out == 1'b1) begin
      escolhido = resultado_ula;
    end
  end
  
  // Atribuição da saída
  assign escolhido_multiplexador_saida = escolhido;

endmodule
