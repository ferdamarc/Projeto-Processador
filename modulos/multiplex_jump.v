module multiplex_jump
#(
  parameter ADDR_WIDTH = 13                       // Largura do endereço (padrão: 13 bits)
)
(
  // Entradas
  input  [ADDR_WIDTH-1:0]  normal_ou_branch,      // Endereço normal ou com branch
  input  [ADDR_WIDTH-1:0]  jump,                  // Endereço de jump
  input                    control_jump,          // Sinal de controle de jump
  
  // Saídas
  output [ADDR_WIDTH-1:0]  escolhido_multiplexador_jump  // Endereço selecionado
);

  // Registrador interno para armazenar seleção
  reg [ADDR_WIDTH-1:0] escolhido;
  
  // Lógica combinacional de seleção
  always @(*) begin
    escolhido = control_jump ? jump : normal_ou_branch;
  end
  
  // Atribuição da saída
  assign escolhido_multiplexador_jump = escolhido;

endmodule
