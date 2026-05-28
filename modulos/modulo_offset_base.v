module modulo_offset_base
#(
  parameter ADDR_WIDTH = 13,                      // Largura do endereço (padrão: 13 bits)
  parameter DATA_WIDTH = 32                       // Largura dos dados (padrão: 32 bits)
)
(
  // Entradas
  input  wire [ADDR_WIDTH-1:0]  endereco_entrada, // Endereço calculado (do multiplex_jr)
  input  wire [DATA_WIDTH-1:0]  reg_base,         // Valor do registrador $24 (offset base)
  input  wire                   is_jump,          // Indica instrução JUMP ou JAL
  input  wire                   is_branch,        // Indica branch efetivo (ControlBranch)
  input  wire                   is_jr,            // Indica JR ou JALR
  input  wire                   user_mode,        // Indica se o sistema está em modo user
  
  // Saídas
  output wire [ADDR_WIDTH-1:0]  endereco_saida    // Endereço final com offset aplicado
);

  // Registrador interno
  reg [ADDR_WIDTH-1:0] resultado;
  
  // Lógica combinacional de aplicação de offset
  // user_mode é gerado em unidade_processamento.v como (pc_atual >= PROGRS_INIT),
  // onde PROGRS_INIT é o limiar SO/usuário (atualmente 2000). Quando ativo, o
  // offset_base ($24) é somado a jumps/branches; o SO é responsável por
  // configurá-lo via os_set_im_base antes de transferir controle ao programa.
  always @(*) begin
    if (is_jr & user_mode) begin
      // JR/JALR: o endereço já vem absoluto do registrador, não soma offset
      // O programador/SO é responsável por colocar o endereço correto em RS
      resultado = endereco_entrada;
    end else if (is_jump & user_mode) begin
      // JUMP/JAL: soma o offset base ao endereço de 26 bits da instrução
      resultado = endereco_entrada + reg_base[ADDR_WIDTH-1:0];
    end else if (is_branch & user_mode) begin
      // BEQ/BNE efetivo: o endereço já é o imediato, soma o offset base
      resultado = endereco_entrada + reg_base[ADDR_WIDTH-1:0];
    end else begin
      // Execução normal (PC+1): não aplica offset
      resultado = endereco_entrada;
    end
  end
  
  // Atribuição da saída
  assign endereco_saida = resultado;

endmodule
