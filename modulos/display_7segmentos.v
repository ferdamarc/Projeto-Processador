module display_7segmentos (
  // Entradas
  input      [3:0] bcd,                           // Dígito BCD de entrada (0-15)
  
  // Saídas
  output reg [6:0] seg                            // Segmentos do display (a-g)
);

  // Inicialização (display apagado)
  initial begin
    seg = 7'b1111111;
  end
  
  // Lógica de decodificação BCD para 7 segmentos
  // Segmentos: {g, f, e, d, c, b, a} (bit 6 a bit 0)
  always @(*) begin
    case (bcd)
      4'h0:    seg = 7'b1000000;                  // Display: 0
      4'h1:    seg = 7'b1111001;                  // Display: 1
      4'h2:    seg = 7'b0100100;                  // Display: 2
      4'h3:    seg = 7'b0110000;                  // Display: 3
      4'h4:    seg = 7'b0011001;                  // Display: 4
      4'h5:    seg = 7'b0010010;                  // Display: 5
      4'h6:    seg = 7'b0000010;                  // Display: 6
      4'h7:    seg = 7'b1111000;                  // Display: 7
      4'h8:    seg = 7'b0000000;                  // Display: 8
      4'h9:    seg = 7'b0011000;                  // Display: 9
      4'hF:    seg = 7'b0001001;                  // Display: H (Halt)
      default: seg = 7'b1111111;                  // Display apagado
    endcase
  end

endmodule