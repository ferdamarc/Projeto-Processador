module multiplex_regdst (
  // Entradas
  input  [4:0] reg_t,                              // Registrador RT (bits 20-16)
  input  [4:0] reg_d,                              // Registrador RD (bits 15-11)
  input        reg_dst,                            // Sinal de controle de seleção
  
  // Saídas
  output [4:0] escolhido_multiplexador_reg_dst     // Registrador selecionado
);

  // Registrador interno para armazenar seleção
  reg [4:0] escolhido;
  
  // Lógica combinacional de seleção
  always @(*) begin
    escolhido = reg_dst ? reg_t : reg_d;           // Operador ternário para seleção
  end
  
  // Atribuição da saída
  assign escolhido_multiplexador_reg_dst = escolhido;

endmodule
