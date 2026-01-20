module bcd (
  // Entradas
  input  [12:0] binary,                           // Valor binário (0-8191)
  
  // Saídas
  output reg [3:0] thousands,                     // Dígito dos milhares
  output reg [3:0] hundreds,                      // Dígito das centenas
  output reg [3:0] tens,                          // Dígito das dezenas
  output reg [3:0] ones                           // Dígito das unidades
);

  // Variável para iteração
  integer i;
  
  // Algoritmo de conversão Double Dabble
  always @(binary) begin
    // Inicialização dos dígitos BCD
    thousands = 4'd0;
    hundreds  = 4'd0;
    tens      = 4'd0;
    ones      = 4'd0;
    
    // Itera sobre cada bit do número binário (MSB para LSB)
    for (i = 12; i >= 0; i = i - 1) begin
      // Adiciona 3 aos dígitos BCD que são >= 5 (correção BCD)
      if (thousands >= 4'd5)
        thousands = thousands + 4'd3;
      if (hundreds >= 4'd5)
        hundreds = hundreds + 4'd3;
      if (tens >= 4'd5)
        tens = tens + 4'd3;
      if (ones >= 4'd5)
        ones = ones + 4'd3;
      
      // Shift left de todos os dígitos com propagação entre eles
      thousands    = thousands << 1;
      thousands[0] = hundreds[3];
      hundreds     = hundreds << 1;
      hundreds[0]  = tens[3];
      tens         = tens << 1;
      tens[0]      = ones[3];
      ones         = ones << 1;
      ones[0]      = binary[i];
    end
  end

endmodule