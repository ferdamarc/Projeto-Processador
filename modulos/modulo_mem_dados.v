module modulo_mem_dados
#(
  parameter DATA_WIDTH = 32,                      // Largura dos dados (padrão: 32 bits)
  parameter ADDR_WIDTH = 13                       // Largura do endereço (padrão: 13 bits)
)
(
  // Entradas
  input  [DATA_WIDTH-1:0]  data,                  // Dado a ser escrito
  input  [ADDR_WIDTH-1:0]  read_addr,             // Endereço de leitura
  input  [ADDR_WIDTH-1:0]  write_addr,            // Endereço de escrita
  input                    we,                    // Write Enable (habilita escrita)
  input                    read_clock,            // Clock de leitura
  input                    write_clock,           // Clock de escrita
  
  // Saídas
  output reg [DATA_WIDTH-1:0]  q                  // Dado lido
);

  // Declaração da memória RAM
  reg [DATA_WIDTH-1:0] ram [0:2**ADDR_WIDTH-1];
  
  // Lógica de escrita (borda de subida do write_clock)
  always @(posedge write_clock) begin
    if (we) begin
      ram[write_addr] <= data;
    end
  end
  
  // Lógica de leitura (borda de subida do read_clock)
  always @(posedge read_clock) begin
    q <= ram[read_addr];
  end

endmodule
