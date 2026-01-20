module modulo_branch
#(
  parameter ADDR_WIDTH = 13,                      // Largura do endereço (padrão: 13 bits)
  parameter DATA_WIDTH = 32                       // Largura dos dados (padrão: 32 bits)
)
(
  // Entradas
  input  [DATA_WIDTH-1:0]  imediato,              // Valor imediato da instrução
  input  [ADDR_WIDTH-1:0]  pc_atual,              // Valor atual do PC
  input                    mux_branch,            // Sinal de controle de branch
  
  // Saídas
  output [ADDR_WIDTH-1:0]  novo_endereco          // Novo endereço calculado
);

  // Registrador interno
  reg [ADDR_WIDTH-1:0] instrucao_modificada;
  
  // Lógica combinacional de seleção
  always @(*) begin
    if (mux_branch == 1'b1) begin
      // Branch ativo: usa endereço do imediato
      instrucao_modificada = imediato[ADDR_WIDTH-1:0];
    end else begin
      // Branch não ativo: PC + 1
      instrucao_modificada = pc_atual + 1'b1;
    end
  end
  
  // Atribuição da saída
  assign novo_endereco = instrucao_modificada;

endmodule
