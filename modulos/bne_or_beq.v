module bne_or_beq (
  // Entradas
  input  control_beq,                              // Sinal de controle BEQ (Branch if Equal)
  input  control_bne,                              // Sinal de controle BNE (Branch if Not Equal)
  input  zero,                                     // Flag Zero da ULA
  
  // Saídas
  output control_branch                            // Sinal de branch ativo
);

  // Registradores internos
  reg resultado_beq;
  reg resultado_bne;
  reg resultado;
  
  // Lógica combinacional de branch
  always @(*) begin
    resultado_beq = zero & control_beq;            // Branch se Zero=1 e BEQ ativo
    resultado_bne = ~zero & control_bne;           // Branch se Zero=0 e BNE ativo
    resultado     = resultado_beq | resultado_bne; // Combinação OR dos resultados
  end
  
  // Atribuição da saída
  assign control_branch = resultado;

endmodule

