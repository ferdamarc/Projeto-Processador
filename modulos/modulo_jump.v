module modulo_jump
#(
  parameter ADDR_WIDTH = 13                       // Largura do endereço (padrão: 13 bits)
)
(
  // Entradas
  input  [25:0]            imediato_26bits,       // Campo de 26 bits da instrução JUMP
  
  // Saídas
  output [ADDR_WIDTH-1:0]  instrucao              // Endereço extraído
);

  // Registrador interno
  reg [ADDR_WIDTH-1:0] reg_imediato;
  
  // Lógica combinacional de extração
  always @(*) begin
    reg_imediato = imediato_26bits[ADDR_WIDTH-1:0];
  end
  
  // Atribuição da saída
  assign instrucao = reg_imediato;

endmodule
	
