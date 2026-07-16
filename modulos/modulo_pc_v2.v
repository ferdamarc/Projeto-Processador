module modulo_pc_v2
#(
  parameter ADDR_WIDTH = 13,                      // Largura do endereço (8192 posições)
  parameter PC_INIT    = 0                        // PC inicial (0 = SO normal; sobrescreva no testbench)
)
(
  // Entradas
  input  wire                     clock,          // Clock do sistema
  input  wire                     pc_funct,       // Habilita atualização do PC
  input  wire [ADDR_WIDTH-1:0]    instrucao_modificada, // Novo valor do PC
  input  wire                     halt,           // int_halt: interrupção por HALT
  input  wire                     int_clk,        // int_clk: interrupção por timer
  input  wire                     loop_enable,    // Switch externo (habilita execução)
  input  wire [ADDR_WIDTH-1:0]    pc_retorno_so,  // Endereço de retorno ao SO

  // Saídas
  output wire [ADDR_WIDTH-1:0]    instrucao       // Endereço da instrução atual
);

  // Registrador do PC
  reg [ADDR_WIDTH-1:0] instrucao_atual;

  // Inicialização: usa PC_INIT (padrão 0 = SO; testbench pode sobrescrever)
  initial begin
    instrucao_atual = PC_INIT[ADDR_WIDTH-1:0];
  end

  // Lógica de atualização do PC
  always @(posedge clock) begin
    if (!loop_enable) begin
      // Loop desabilitado: congela o PC
      // instrucao_atual <= instrucao_atual;
    end else begin
      // INTERRUPÇÕES: Voltam automaticamente para o SO
      if (halt || int_clk) begin
        instrucao_atual <= pc_retorno_so;
      end else if (pc_funct) begin
        // Caminho normal: sempre seguir instrucao_modificada
        instrucao_atual <= instrucao_modificada;
      end
      // Se pc_funct == 0: mantém PC
    end
  end

  // Atribuição da saída
  assign instrucao = instrucao_atual;

endmodule
