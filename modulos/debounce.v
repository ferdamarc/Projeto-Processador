module debounce (
  // Entradas
  input  pb_1,                                    // Sinal do botão (push button)
  input  clk,                                     // Clock de entrada (100 MHz)
  
  // Saídas
  output pb_out                                   // Sinal do botão estabilizado
);

  // Sinais internos
  wire slow_clk;                                  // Clock dividido
  wire Q0, Q1, Q2, Q2_bar;                        // Saídas dos flip-flops
  
  // Instanciação dos módulos
  clock_div u1 (
    .Clk_100M(clk),
    .slow_clk(slow_clk)
  );
  
  my_dff d0 (
    .DFF_CLOCK(slow_clk),
    .D(pb_1),
    .Q(Q0)
  );
  
  my_dff d1 (
    .DFF_CLOCK(slow_clk),
    .D(Q0),
    .Q(Q1)
  );
  
  my_dff d2 (
    .DFF_CLOCK(slow_clk),
    .D(Q1),
    .Q(Q2)
  );
  
  // Lógica de detecção de borda
  assign Q2_bar = ~Q2;
  assign pb_out = Q1 & Q2_bar;                    // Pulso na transição
  
endmodule


module clock_div (
  // Entradas
  input      Clk_100M,                            // Clock de entrada (100 MHz)
  
  // Saídas
  output reg slow_clk                             // Clock dividido
);

  // Contador para divisão de clock
  reg [26:0] counter = 27'd0;
  
  // Lógica de divisão
  always @(posedge Clk_100M) begin
    counter  <= (counter >= 27'd249999) ? 27'd0 : counter + 27'd1;
    slow_clk <= (counter < 27'd125000) ? 1'b0 : 1'b1;
  end
  
endmodule

module my_dff (
  // Entradas
  input      DFF_CLOCK,                           // Clock do flip-flop
  input      D,                                   // Entrada de dados
  
  // Saídas
  output reg Q                                    // Saída do flip-flop
);

  // Lógica do flip-flop D
  always @(posedge DFF_CLOCK) begin
    Q <= D;
  end
  
endmodule