module modulo_offset_base
#(
  parameter ADDR_WIDTH = 13,                      // Largura do endereço (padrão: 13 bits)
  parameter DATA_WIDTH = 32                       // Largura dos dados (padrão: 32 bits)
)
(
  // Entradas
  input  wire [ADDR_WIDTH-1:0]  endereco_entrada, // Endereço calculado (do multiplex_jr)
  input  wire [ADDR_WIDTH-1:0]  pc_atual,         // PC atual
  input  wire [DATA_WIDTH-1:0]  reg_base,         // Valor do registrador $24 (offset base)
  input  wire                   is_jump,          // Indica instrução JUMP ou JAL
  input  wire                   is_branch,        // Indica branch efetivo (ControlBranch)
  input  wire                   is_jr,            // Indica JR ou JALR
  
  // Saídas
  output wire [ADDR_WIDTH-1:0]  endereco_saida    // Endereço final com offset aplicado
);

  // Registrador interno
  reg [ADDR_WIDTH-1:0] resultado;
  
  // Lógica combinacional de aplicação de offset
  // pc_atual >= 1000 implica o sistema estar em modo user
  // Neste caso, o offset é aplicado pois o SO está em controle absoluto
  // e é o primeiro programa na memória de instruções
  always @(*) begin
    if (is_jr & (pc_atual >= 13'd1000)) begin
      // JR/JALR: o endereço já vem absoluto do registrador, não soma offset
      // O programador/SO é responsável por colocar o endereço correto em RS
      resultado = endereco_entrada;
    end else if (is_jump & (pc_atual >= 13'd1000)) begin
      // JUMP/JAL: soma o offset base ao endereço de 26 bits da instrução
      resultado = endereco_entrada + reg_base[ADDR_WIDTH-1:0];
    end else if (is_branch & (pc_atual >= 13'd1000)) begin
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
