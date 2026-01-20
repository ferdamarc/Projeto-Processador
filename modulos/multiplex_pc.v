module multiplex_pc
#(
  parameter DATA_WIDTH = 32,                      // Largura dos dados (padrão: 32 bits)
  parameter ADDR_WIDTH = 13                       // Largura do endereço (padrão: 13 bits)
)
(
  // Entradas
  input  [ADDR_WIDTH-1:0]  valor_pc,              // Valor atual do PC
  input  [ADDR_WIDTH-1:0]  pc_interrup,           // Endereço de retorno de interrupção
  input  [DATA_WIDTH-1:0]  dado,                  // Dado padrão
  input  [DATA_WIDTH-1:0]  qual_interrupcao,      // Identificador da interrupção
  input                    save_pc,               // Salva PC atual
  input                    get_pc_interrup,       // Lê PC de interrupção
  input                    get_interruption,      // Lê qual interrupção ocorreu
  
  // Saídas
  output [DATA_WIDTH-1:0]  escolhido_multiplexador_pc  // Valor selecionado
);

  // Registrador interno para armazenar seleção
  reg [DATA_WIDTH-1:0] escolhido;
  
  // Lógica combinacional de seleção (prioridade)
  always @(*) begin
    if (save_pc) begin
      // Salva o valor atual do PC
      escolhido = {{(DATA_WIDTH-ADDR_WIDTH){1'b0}}, valor_pc};
    end else if (get_pc_interrup) begin
      // Recupera o endereço de retorno da interrupção
      escolhido = {{(DATA_WIDTH-ADDR_WIDTH){1'b0}}, pc_interrup};
    end else if (get_interruption) begin
      // Retorna qual interrupção ocorreu
      escolhido = qual_interrupcao;
    end else begin
      // Valor padrão
      escolhido = dado;
    end
  end
  
  // Atribuição da saída
  assign escolhido_multiplexador_pc = escolhido;

endmodule


