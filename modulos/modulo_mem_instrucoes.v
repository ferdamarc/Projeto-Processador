module modulo_mem_instrucoes
#(
  parameter DATA_WIDTH = 32,                      // Largura da instrução (32 bits)
  parameter ADDR_WIDTH = 13                       // Largura do endereço (8K instruções)
)
(
  // Entradas
  input  [ADDR_WIDTH-1:0] addr,                   // Endereço da instrução
  input                   clk,                    // Clock do sistema
  
  // Saídas
  output reg [DATA_WIDTH-1:0] q                   // Instrução lida
);

	// Declaração da memória ROM
	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];
	
	// Inicialização da ROM com arquivo de instruções
	initial
	begin
		$readmemb("single_port_rom_init.txt", rom);
	end
	
	always @ (*)
	begin
		q <= rom[addr];
	end

endmodule