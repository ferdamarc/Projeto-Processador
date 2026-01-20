module unidade_controle (
  // Entradas
  input  [5:0] opcode,                            // Opcode da instrução (bits 31-26)
  input        clock,                             // Clock do sistema
  input        button,                            // Botão de entrada
  
  // Saídas - Sinais de Controle
  output [2:0] alu_op,                            // Operação da ULA
  output [1:0] in,                                // Sinal de entrada (IN)
  output       reg_dst,                           // Seleção do registrador de destino
  output       mem_to_reg,                        // Memória para registrador
  output       mem_write,                         // Escrita na memória
  output       alu_src,                           // Fonte da ULA (imediato/registrador)
  output       reg_write,                         // Habilita escrita no banco de registradores
  output       pc_funct,                          // Função do PC
  output       beq,                               // Branch if Equal
  output       bne,                               // Branch if Not Equal
  output       control_jump,                      // Controle de Jump
  output       halt,                              // Sinal de parada
  output       out,                               // Sinal de saída (OUT)
  output [1:0] enable_clock,                      // Controle de clock (0, 1 ou 2)
  output       jal,                               // Jump and Link
  output       disp,                              // Display
  output       save_pc,                           // Salva PC
  output       get_pc_interrup,                   // Obtém PC de interrupção
  output       set_clock,                         // Configura clock
  output       get_interruption,                  // Obtém interrupção
  output       os_jump_to,                        // Jump do SO
  output       os_save_return                     // Salva retorno do SO
);

  // Registradores internos de controle
  reg reg_reg_dst;
  reg reg_mem_read;
  reg reg_mem_to_reg;
  reg reg_mem_write;
  reg reg_alu_src;
  reg reg_reg_write;
  reg reg_pc_funct;
  reg reg_beq;
  reg reg_bne;
  reg reg_control_jump;
  reg reg_halt;
  reg reg_out;
  reg reg_jal;
  reg reg_disp;
  reg reg_save_pc;
  reg reg_get_pc_interrup;
  reg reg_set_clock;
  reg reg_get_interruption;
  reg reg_os_jump_to;
  reg reg_os_save_return;
  reg [1:0] reg_in;
  reg [2:0] reg_alu_op;
  reg [1:0] reg_enable;                           // 2 bits para valores 0, 1 e 2

  // Lógica combinacional de decodificação do opcode
  always @(*) begin
    // Valores padrão para todos os sinais de controle
    reg_reg_write <= 1'b0;
    reg_mem_read <= 1'b0;
    reg_mem_write <= 1'b0;
    reg_mem_to_reg <= 1'b0;
    reg_alu_src <= 1'b0;
    reg_reg_dst <= 1'b0;
    reg_pc_funct <= 1'b1;
    reg_alu_op <= 3'b000;
    reg_beq <= 1'b0;
    reg_bne <= 1'b0;
    reg_control_jump <= 1'b0;
    reg_halt <= 1'b0;
    reg_in <= 2'b00;
    reg_out <= 1'b0;
    reg_enable <= 2'd1;
    reg_jal <= 1'b0;
    reg_disp <= 1'b0;
    reg_save_pc <= 1'b0;
    reg_get_pc_interrup <= 1'b0;
    reg_set_clock <= 1'b0;
    reg_get_interruption <= 1'b0;
    reg_os_jump_to <= 1'b0;
    reg_os_save_return <= 1'b0;

    case (opcode)
      6'b000000: begin  // R type
        reg_reg_write <= 1'b1;
        reg_alu_op <= 3'b010;                     // func field determines operation
      end

      6'b100011: begin  // lw
        reg_reg_write <= 1'b1;
        reg_mem_read <= 1'b1;
        reg_mem_to_reg <= 1'b1;
        reg_alu_src <= 1'b1;
        reg_reg_dst <= 1'b1;
      end

      6'b101011: begin  // sw
        reg_mem_write <= 1'b1;
        reg_mem_to_reg <= 1'b1;
        reg_alu_src <= 1'b1;
        reg_reg_dst <= 1'b1;
      end

      6'b001000: begin  // addi
        reg_reg_write <= 1'b1;
        reg_alu_src <= 1'b1;
        reg_reg_dst <= 1'b1;
      end

      6'b001001: begin  // subi
        reg_reg_write <= 1'b1;
        reg_alu_src <= 1'b1;
        reg_reg_dst <= 1'b1;
        reg_alu_op <= 3'b001;                     // sub
      end

      6'b001100: begin  // andi
        reg_reg_write <= 1'b1;
        reg_alu_src <= 1'b1;
        reg_reg_dst <= 1'b1;
        reg_alu_op <= 3'b011;                     // and
      end

      6'b001101: begin  // ori
        reg_reg_write <= 1'b1;
        reg_alu_src <= 1'b1;
        reg_reg_dst <= 1'b1;
        reg_alu_op <= 3'b100;                     // or
      end

      6'b000100: begin  // beq
        reg_alu_op <= 3'b001;                     // sub
        reg_beq <= 1'b1;
      end

      6'b000101: begin  // bne
        reg_alu_op <= 3'b001;                     // sub
        reg_bne <= 1'b1;
      end

      6'b001010: begin  // slti
        reg_reg_write <= 1'b1;
        reg_alu_src <= 1'b1;
        reg_reg_dst <= 1'b1;
        reg_alu_op <= 3'b101;                     // slt
      end

      6'b011111: begin  // in
        reg_reg_write <= 1'b1;
        reg_reg_dst <= 1'b1;
        reg_in <= 2'd1;
        reg_enable <= 2'd0;
      end

      6'b011110: begin  // output
        reg_out <= 1'b1;
        reg_enable <= 2'd2;                       // Espera button 0 ser pressionado
      end

      6'b000010: begin  // j
        reg_control_jump <= 1'b1;
      end

      6'b000011: begin  // jal
        reg_reg_write <= 1'b1;
        reg_control_jump <= 1'b1;
        reg_jal <= 1'b1;
      end

      6'b111111: begin  // halt
        reg_pc_funct <= 1'b0;
        reg_halt <= 1'b1;
      end

      6'b001110: begin  // xori
        reg_reg_write <= 1'b1;
        reg_alu_src <= 1'b1;
        reg_reg_dst <= 1'b1;
        reg_alu_op <= 3'b110;                     // XOR
      end

      6'b011101: begin  // show_lcd
        reg_disp <= 1'b1;
      end

      6'b100100: begin  // pc
        reg_reg_write <= 1'b1;
        reg_reg_dst <= 1'b1;
        reg_save_pc <= 1'b1;
      end

      6'b010100: begin  // get_pc
        reg_reg_write <= 1'b1;
        reg_reg_dst <= 1'b1;
        reg_get_pc_interrup <= 1'b1;
      end

      6'b010010: begin  // os_jump_to
        reg_os_jump_to <= 1'b1;                   // Sinaliza jump via SO
      end

      6'b010011: begin  // os_save_return
        reg_os_save_return <= 1'b1;               // Salva PC+1 como retorno do SO
      end

      6'b010101: begin  // set_interr_timer
        reg_set_clock <= 1'b1;
      end

      6'b010110: begin  // get_interr_type
        reg_reg_write <= 1'b1;
        reg_reg_dst <= 1'b1;
        reg_get_interruption <= 1'b1;
      end
    endcase
  end

  // Atribuição dos sinais de saída
  assign jal = reg_jal;
  assign enable_clock = reg_enable;
  assign halt = reg_halt;
  assign reg_dst = reg_reg_dst;
  assign mem_to_reg = reg_mem_to_reg;
  assign mem_write = reg_mem_write;
  assign alu_src = reg_alu_src;
  assign reg_write = reg_reg_write;
  assign pc_funct = reg_pc_funct;
  assign alu_op = reg_alu_op;
  assign beq = reg_beq;
  assign bne = reg_bne;
  assign control_jump = reg_control_jump;
  assign in = reg_in;
  assign out = reg_out;
  assign disp = reg_disp;
  assign save_pc = reg_save_pc;
  assign get_pc_interrup = reg_get_pc_interrup;
  assign set_clock = reg_set_clock;
  assign get_interruption = reg_get_interruption;
  assign os_jump_to = reg_os_jump_to;
  assign os_save_return = reg_os_save_return;

endmodule
