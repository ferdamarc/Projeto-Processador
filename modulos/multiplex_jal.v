module multiplex_jal
#(
  parameter DATA_WIDTH = 32,                      // Largura dos dados (padrão: 32 bits)
  parameter ADDR_WIDTH = 13                       // Largura do endereço (padrão: 13 bits)
)
(
  // Entradas
  input  [ADDR_WIDTH-1:0]  proximo_pc,            // Próximo valor do PC (PC+1)
  input  [DATA_WIDTH-1:0]  escolhido_mem_to_reg,  // Valor do multiplexador MemToReg
  input                    jalr,                  // Sinal de controle JALR
  input                    jump_al,               // Sinal de controle JAL
  
  // Saídas
  output [DATA_WIDTH-1:0]  escolhido_multiplexador_jal  // Valor selecionado
);

  // Registrador interno para armazenar seleção
  reg [DATA_WIDTH-1:0] escolhido;
  
  // Lógica combinacional de seleção
  always @(*) begin
    if (jalr || jump_al) begin
      // Salva PC+1 no registrador de retorno
      escolhido = {{(DATA_WIDTH-ADDR_WIDTH){1'b0}}, proximo_pc};
    end else begin
      escolhido = escolhido_mem_to_reg;
    end
  end
  
  // Atribuição da saída
  assign escolhido_multiplexador_jal = escolhido;

endmodule
