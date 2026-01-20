module banco_registradores
#(
  parameter DATA_WIDTH = 32,                      // Largura dos dados (padrão: 32 bits)
  parameter DATA_ADDR_WIDTH = 13                  // Largura do endereço de dados
)
(
  // Entradas
  input  wire                   clock,            // Clock do sistema
  input  wire                   reg_write,        // Habilita escrita
  input  wire [4:0]             reg1,             // Endereço do registrador 1 (leitura)
  input  wire [4:0]             reg2,             // Endereço do registrador 2 (leitura)
  input  wire [4:0]             reg_escrita,      // Endereço do registrador de escrita
  input  wire [DATA_WIDTH-1:0]  escreve_dado,     // Dado a ser escrito
  input  wire                   clear_offset_base,// Zera $24 (retorno ao SO)
  
  // Saídas
  output wire [DATA_WIDTH-1:0]  dado1,            // Dado lido do registrador 1
  output wire [DATA_WIDTH-1:0]  dado2,            // Dado lido do registrador 2
  output wire [DATA_WIDTH-1:0]  fp,              // Frame Pointer ($29)
  output wire [DATA_WIDTH-1:0]  s0,              // Saved register ($23)
  output wire [DATA_WIDTH-1:0]  offset_base      // Offset base ($24)
);

  // Banco de 32 registradores
  reg [DATA_WIDTH-1:0] registradores [31:0];
  
  // Inicialização do banco de registradores
  initial begin
    integer i;
    for (i = 0; i < 32; i = i + 1) begin
      registradores[i] = {DATA_WIDTH{1'b0}};
    end
  end
  
  // Lógica de escrita (borda de subida do clock)
  always @(posedge clock) begin
    // Limpar $24 tem prioridade (retorno ao SO)
    if (clear_offset_base) begin
      registradores[5'd24] <= {DATA_WIDTH{1'b0}};
    end else if ((reg_write == 1'b1) && (reg_escrita != 5'd31)) begin
      // Escreve no registrador (exceto $31 que é sempre zero)
      registradores[reg_escrita] <= escreve_dado;
    end
  end
  
  // Leituras assíncronas
  assign dado1 = registradores[reg1];
  assign dado2 = registradores[reg2];
  assign fp = registradores[5'd29];               // $29 - Frame Pointer
  assign s0 = registradores[5'd23];               // $23 - Saved register
  assign offset_base = registradores[5'd24];      // $24 - Offset base do programa

endmodule 