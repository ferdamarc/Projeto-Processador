module unidade_controle_ula (
  // Entradas
  input  [5:0] funct,                             // Campo funct da instrução (bits 5-0)
  input  [2:0] alu_op,                            // Código de operação da UC principal
  
  // Saídas
  output [3:0] controle_alu,                      // Código de controle da ULA
  output       jalr,                              // Sinal JALR (Jump and Link Register)
  output       jr                                 // Sinal JR (Jump Register)
);

  // Registradores internos
  reg [3:0] reg_controle;
  reg       reg_jalr;
  reg       reg_jr;
	
// Lógica combinacional de decodificação
  always @(*) begin
    // Valores padrão
    reg_controle = 4'b0010;                       // SOMA (padrão)
    reg_jalr = 1'b0;
    reg_jr = 1'b0;

    case (alu_op)
      3'b000: begin 
        // SOMA - já é o padrão
      end

      3'b001: begin
        reg_controle = 4'b0110;                   // SUB
      end

      3'b010: begin                               // FUNCT
        case (funct)
          6'b100000: begin 
            // SOMA - já é o padrão
          end

          6'b100010: begin 
            reg_controle = 4'b0110;               // SUB
          end

          6'b100100: begin
            reg_controle = 4'b0000;               // AND
          end

          6'b101101: begin 
            reg_controle = 4'b0011;               // XOR
          end

          6'b100101: begin
            reg_controle = 4'b0001;               // OR
          end

          6'b001000: begin                        // JR
            reg_jr = 1'b1;
          end

          6'b001001: begin                        // JALR
            reg_controle = 4'b0000;
            reg_jalr = 1'b1;
          end

          6'b101010: begin
            reg_controle = 4'b0111;               // SLT
          end

          6'b100111: begin
            reg_controle = 4'b1100;               // NOR
          end

          6'b000000: begin
            reg_controle = 4'b1111;               // SLL
          end

          6'b000010: begin
            reg_controle = 4'b1101;               // SRL
          end

          6'b011010: begin
            reg_controle = 4'b1001;               // DIV
          end

          6'b011000: begin
            reg_controle = 4'b1000;               // MULT
          end
        endcase
      end

      3'b011: begin
        reg_controle = 4'b0000;                   // AND
      end

      3'b100: begin
        reg_controle = 4'b0001;                   // OR
      end

      3'b101: begin
        reg_controle = 4'b0111;                   // SLT
      end

      3'b110: begin
        reg_controle = 4'b0011;                   // XOR
      end
    endcase
  end
  
  // Atribuição dos sinais de saída
  assign controle_alu = reg_controle;
  assign jalr = reg_jalr;
  assign jr = reg_jr;

endmodule 

