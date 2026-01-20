module modulo_ula
#(
  parameter DATA_WIDTH = 32                       // Largura dos dados (padrão: 32 bits)
)
(
  // Entradas
  input  wire [DATA_WIDTH-1:0] input_1,           // Operando 1
  input  wire [DATA_WIDTH-1:0] input_2,           // Operando 2
  input  wire [4:0]            shamt,             // Shift amount (quantidade de deslocamento)
  input  wire [3:0]            control_alu,       // Código de controle da operação
  
  // Saídas
  output wire [DATA_WIDTH-1:0] output_resultado,  // Resultado da operação
  output wire                  zero               // Flag zero (resultado = 0)
);

  // Registradores internos
  reg [DATA_WIDTH-1:0] resultado;
  reg                  reg_zero;
  
  // Inicialização
  initial begin
    resultado = {DATA_WIDTH{1'b0}};
  end
  
  // Lógica combinacional da ULA
  always @(*) begin
    // Valores padrão
    resultado = {DATA_WIDTH{1'b0}};
    reg_zero  = 1'b0;
    
    // Decodificação da operação
    case (control_alu)
      4'b0000: resultado = input_1 & input_2;                    // AND
      4'b0001: resultado = input_1 | input_2;                    // OR
      4'b0010: resultado = input_1 + input_2;                    // ADD (Soma)
      4'b0011: resultado = input_1 ^ input_2;                    // XOR
      4'b0110: resultado = input_1 - input_2;                    // SUB (Subtração)
      4'b0111: resultado = (input_1 < input_2) ? 32'd1 : 32'd0;  // SLT (Set on Less Than)
      4'b1000: resultado = input_1 * input_2;                    // MUL (Multiplicação)
      4'b1001: resultado = input_1 / input_2;                    // DIV (Divisão)
      4'b1100: resultado = ~(input_1 | input_2);                 // NOR
      4'b1101: resultado = input_1 >> shamt;                     // SRL (Shift Right Logical)
      4'b1111: resultado = input_1 << shamt;                     // SLL (Shift Left Logical)
      default: resultado = {DATA_WIDTH{1'b0}};                   // Operação indefinida
    endcase
    
    // Geração da flag Zero
    reg_zero = (resultado == {DATA_WIDTH{1'b0}});
  end
  
  // Atribuição das saídas
  assign output_resultado = resultado;
  assign zero = reg_zero;

endmodule
