module multiplex_destino (
  // Entradas
  input  [4:0] reg_destino,                        // Registrador de destino padrão
  input        jal,                                 // Sinal de controle JAL
  input        jalr,                                // Sinal de controle JALR
  
  // Saídas
  output [4:0] escolhido_multiplexador_destino      // Registrador selecionado
);

  // Registrador interno para armazenar seleção
  reg [4:0] escolhido;
  
  // Lógica combinacional de seleção
  always @(*) begin
    if (jal || jalr) begin
      escolhido = 5'd30;                            // Registrador $30 para instruções de link
    end else begin
      escolhido = reg_destino;                      // Registrador de destino padrão
    end
  end
  
  // Atribuição da saída
  assign escolhido_multiplexador_destino = escolhido;

endmodule
