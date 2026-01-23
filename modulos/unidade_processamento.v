module unidade_processamento 
#(
    parameter DATA_WIDTH = 32,          // Largura dos dados
    parameter INSTR_ADDR_WIDTH = 13,     // Largura do endereço da ROM/MI
    parameter DATA_ADDR_WIDTH = 13      // Largura do endereço da RAM/MD
)
(
    // Entradas Principais
    input           entrada_clock,       // Clock principal de 50MHz da placa
    input           botao,               // Botão de entrada para outras funções
    input           botao_continue,      // Novo botão dedicado ao avanço manual (continue)
    input [13:0]    sw,                  // Switches para entrada de dados
	input           loop_enable,          // Switch que permite a execução em loop do programa; não reinicia o sistema

    /* diff */
    // Entradas para teclado PS/2
    input           ps2_clk_in,          // Clock do teclado PS/2'
    input           ps2_data_in,         // Dados do teclado PS/2

    // Saídas para LEDs e Displays
	output          led_loop_status,      // LED utilizado apenas para mostrar que o modo loop está ativado
    output [13:0]   led,                 // LEDs para saída de dados e status
    output [6:0]    display1,            // Displays de 7 segmentos
    output [6:0]    display2,
    output [6:0]    display3,
    output [6:0]    display4,
    output [6:0]    display_pc1,
    output [6:0]    display_pc2,
    output [6:0]    display_fp1,
    output [6:0]    display_fp2,
      
    // Interface com o Display LCD
    output          LCD_ON,
    output          LCD_BLON,
    output          LCD_RW,
    output          LCD_EN,
    output          LCD_RS,
    inout  [7:0]    LCD_DATA

    /* diff */
    // Saídas para VGA
    output [2:0]    disp_rgb,            // Saída RGB para VGA
    output          hsync,               // Sinal de sincronização horizontal
    output          vsync,               // Sinal de sincronização vertical
    output [7:0]    seg,               // segmentos do display 7-segmentos
    output [3:0]    dig                // dígitos do display 7-segmentos
);

  // DECLARAÇÃO DE SINAIS INTERNOS
  // Registradores Internos
  reg [DATA_WIDTH-1:0] imediato_extendido;
  reg init_done;
  reg [INSTR_ADDR_WIDTH-1:0] novo_valor_pc;
  reg [DATA_WIDTH-1:0] qual_interrupcao;
  reg [INSTR_ADDR_WIDTH-1:0] pc_interrup;
  reg [INSTR_ADDR_WIDTH-1:0] pc_retorno_so;

  // Clock e Controle
  wire clock;
  wire inv_clock;
  
  // Sinais da Unidade de Controle
  wire reg_write, mem_to_reg, mem_write, alu_src;
  wire reg_dst, pc_funct, control_jump, beq, bne, halt;
  wire out, jal, disp, save_pc;
  wire get_pc_interrup, set_clock, get_interruption;
  wire os_jump_to, os_save_return, frame_buffer_write;    // diff
  wire [1:0] in;
  wire [1:0] enable_clock;
  wire [2:0] alu_op;

  // Sinais da Unidade de Controle da ULA
  wire [3:0] control_alu;
  wire jalr, jr;

  // Sinais da ULA
  wire [DATA_WIDTH-1:0] saida_ula;
  wire zero;

  // Sinais do Banco de Registradores
  wire [DATA_WIDTH-1:0] br_dado1, br_dado2;
  wire [DATA_WIDTH-1:0] fp;
  wire [DATA_WIDTH-1:0] offset_base;
  wire [DATA_WIDTH-1:0] s0;  // Saída S0 do banco (não utilizado externamente)

  // Sinais de Memória
  wire [DATA_WIDTH-1:0] dado_memoria_ram;
  wire [DATA_WIDTH-1:0] instrucao;
  wire [DATA_ADDR_WIDTH-1:0] addr_logico;

  // Sinais de Controle de Fluxo (PC, Branch, Jump)
  wire [INSTR_ADDR_WIDTH-1:0] endereco_instrucao;
  wire [INSTR_ADDR_WIDTH-1:0] novo_endereco;
  wire [INSTR_ADDR_WIDTH-1:0] endereco_com_offset;
  wire [DATA_WIDTH-1:0] endereco_do_jump;
  wire control_branch;
  wire pc_funct_final;

  // Sinais de Interrupção
  wire int_halt, int_clk;

  // Sinais de Entrada/Saída
  wire [13:0] resultado_entrada;
  wire saida_botao;

  // Sinais dos Multiplexadores
  wire [DATA_WIDTH-1:0] escolhido_multiplexador_mem_to_reg;
  wire [DATA_WIDTH-1:0] escolhido_multiplexador_alu_src;
  wire [4:0] escolhido_multiplexador_reg_dst;
  wire [INSTR_ADDR_WIDTH-1:0] escolhido_multiplexador_jump;
  wire [DATA_WIDTH-1:0] escolhido_multiplexador_entrada;
  wire [DATA_WIDTH-1:0] escolhido_multiplexador_saida;
  wire [4:0] escolhido_multiplexador_destino;
  wire [DATA_WIDTH-1:0] escolhido_multiplexador_jal;
  wire [INSTR_ADDR_WIDTH-1:0] escolhido_multiplexador_jump_reg;
  wire [DATA_WIDTH-1:0] escolhido_multiplexador_pc;

  // ASSIGNS
  assign addr_logico = saida_ula[DATA_ADDR_WIDTH-1:0];
  assign led_loop_status = loop_enable;
  assign inv_clock = ~clock;
  assign pc_funct_final = os_jump_to ? 1'b1 : pc_funct;

  // LÓGICA COMBINACIONAL E SEQUENCIAL
  // Inicialização de registradores
  initial begin
    init_done = 1'b0;
    novo_valor_pc = {INSTR_ADDR_WIDTH{1'b0}};
    qual_interrupcao = {DATA_WIDTH{1'b0}};
    pc_interrup = {INSTR_ADDR_WIDTH{1'b0}};
    pc_retorno_so = {INSTR_ADDR_WIDTH{1'b0}};
  end
  
  // Extensor de Imediato: estende imediato de 16 para 32 bits
  always @(instrucao[15:0]) begin
    imediato_extendido = {{(DATA_WIDTH-16){1'b0}}, instrucao[15:0]};
  end

  // Bloco de inicialização e controle
  always @(posedge clock) begin
    // Bloco de inicialização na primeira execução
    if (!init_done) begin
        init_done <= 1'b1;  // marca que já inicializou

        qual_interrupcao <= {DATA_WIDTH{1'b0}};
        pc_interrup <= {INSTR_ADDR_WIDTH{1'b0}};
        pc_retorno_so <= {INSTR_ADDR_WIDTH{1'b0}};
    end

    if (os_jump_to) begin
        // Salva automaticamente o PC+1 de retorno
        pc_retorno_so <= endereco_instrucao + 1;
    end

    if (int_halt) begin
        qual_interrupcao <= {{(DATA_WIDTH-2){1'b0}}, 2'd2};
    end
    else if (int_clk) begin
        qual_interrupcao <= {{(DATA_WIDTH-1){1'b0}}, 1'd1};
        end
    
    // O PC de retorno agora é salvo automaticamente pelo os_jump_to
    // Usada para override manual se necessário
    if (os_save_return) begin
        pc_retorno_so <= endereco_instrucao + 1;  // Override manual: salva PC+1
    end

    if (get_interruption) begin
        qual_interrupcao <= {DATA_WIDTH{1'b0}};
    end

    if (int_clk) begin
      pc_interrup <= endereco_com_offset;
    end
  end


  // Controle do valor do PC (sem tratamento de interrupção)
  always @(*) begin
    // Jump especial do SO - usa registrador de índice 22
    if (os_jump_to) begin
      novo_valor_pc = br_dado1[INSTR_ADDR_WIDTH-1:0];
    end
    // Operação normal
    else begin
      // Usa endereco_com_offset que já tem o offset base aplicado
      novo_valor_pc = endereco_com_offset;
    end
  end

  // INSTANCIAÇÃO DOS MÓDULOS
  modulo_output_v2 exit (
      .valor_saida(escolhido_multiplexador_saida),
      .halt(halt),
      .clock_cpu(clock),
      .enable_out(out),
      .enable_in(in),
      .switch_enable(sw[13]),
      .led(led),
      .display_1(display1),
      .display_2(display2),
      .display_3(display3),
      .display_4(display4),
      .display_pc_1(display_pc1),
      .display_pc_2(display_pc2),
      .display_fp_1(display_fp1),
      .display_fp_2(display_fp2),
      .pc(endereco_instrucao),
      .seg(seg),    // diff
      .dig(dig),    // diff
      .fp(fp),
      .clk(entrada_clock)
  );

  modulo_input enter (
      .clock(entrada_clock),
      .botao(botao),
      .botao_continue(botao_continue),
      .sw(sw),
      .ps2_clk(ps2_clk_in),    // diff
      .ps2_data(ps2_data_in),    // diff
      .pause(enable_clock),
      .in(in),
      .resultado_entrada(resultado_entrada),
      .resultadoKeyBoard(resultadoKeyBoard),    // diff
      .saida_botao(saida_botao),
      .saida_botao_continue(),
      .saida_clock(clock)
  );

  unidade_controle uc (
      .opcode(instrucao[31:26]),
      .clock(clock),
      .button(saida_botao),
      .alu_op(alu_op),
      .reg_dst(reg_dst),
      .mem_to_reg(mem_to_reg),
      .mem_write(mem_write),
      .alu_src(alu_src),
      .reg_write(reg_write),
      .pc_funct(pc_funct),
      .beq(beq),
      .bne(bne),
      .control_jump(control_jump),
      .halt(halt),
      .in(in),
      .out(out),
      .enable_clock(enable_clock),
      .jal(jal),
      .disp(disp),
      .save_pc(save_pc),
	  .get_pc_interrup(get_pc_interrup),
      .set_clock(set_clock),
      .get_interruption(get_interruption),
      .os_jump_to(os_jump_to),
      .os_save_return(os_save_return),
      .frame_buffer_write(frame_buffer_write)    // diff
  );

  unidade_controle_ula ucula (
      .funct(instrucao[5:0]),
      .alu_op(alu_op),
      .controle_alu(control_alu),
      .jalr(jalr),
      .jr(jr)
  );

  banco_registradores #(
      .DATA_WIDTH(DATA_WIDTH),
      .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH)
  ) br (
      .clock(clock),
      .reg1(instrucao[25:21]),
      .reg2(instrucao[20:16]),
      .reg_escrita(escolhido_multiplexador_destino),
      .reg_write(reg_write),
      .clear_offset_base(0),//int_halt | int_clk),  // Zera $24 automaticamente
      .dado1(br_dado1),
      .dado2(br_dado2),
      .escreve_dado(escolhido_multiplexador_pc),
      .fp(fp),
      .s0(s0),  // Conectado mas não utilizado externamente
      .offset_base(offset_base)
  );

  modulo_ula #(
      .DATA_WIDTH(DATA_WIDTH)
  ) ula (
      .input_1(br_dado1),
      .input_2(escolhido_multiplexador_alu_src),
      .control_alu(control_alu),
      .output_resultado(saida_ula),
      .zero(zero),
      .shamt(instrucao[10:6])
  );

  modulo_mem_dados #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(DATA_ADDR_WIDTH)
  ) ram_dados (
      .data(br_dado2),
      .read_addr(addr_logico),
      .write_addr(addr_logico),
      .we(mem_write),
      .read_clock(inv_clock),
      .write_clock(clock),
      .q(dado_memoria_ram)
  );

  multiplex_memtoreg #(
      .DATA_WIDTH(DATA_WIDTH)
  ) mult_mrm (
      .dado_lido_mem(dado_memoria_ram),
      .resultado_ula(saida_ula),
      .mem_to_reg(mem_to_reg),
      .escolhido_multiplexador_mem_to_reg(escolhido_multiplexador_mem_to_reg)
  );

  multiplex_ALUSrc #(
      .DATA_WIDTH(DATA_WIDTH)
  ) mas (
      .imediato(imediato_extendido),
      .br_dado2(br_dado2),
      .alu_src(alu_src),
      .escolhido_multiplexador_alu_src(escolhido_multiplexador_alu_src)
  );

  multiplex_regdst mrd (
      .reg_t(instrucao[20:16]),
      .reg_d(instrucao[15:11]),
      .reg_dst(reg_dst),
      .escolhido_multiplexador_reg_dst(escolhido_multiplexador_reg_dst)
  );

  modulo_pc_v2 #(
    .ADDR_WIDTH(INSTR_ADDR_WIDTH)
) pc (
    .clock(clock),
    .pc_funct(pc_funct_final),
    .instrucao_modificada(novo_valor_pc),
    .halt(int_halt),
    .int_clk(int_clk),
    .loop_enable(loop_enable),
    .pc_retorno_so(pc_retorno_so),
    .instrucao(endereco_instrucao)
);

  modulo_mem_instrucoes #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(INSTR_ADDR_WIDTH)
  ) rom (
      .addr(endereco_instrucao),
      .clk(clock),
      .q(instrucao)
  );

  modulo_branch #(
      .ADDR_WIDTH(INSTR_ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) branch (
      .imediato(imediato_extendido),
      .pc_atual(endereco_instrucao),
      .mux_branch(control_branch),
      .novo_endereco(novo_endereco)
  );

  modulo_jump #(
      .ADDR_WIDTH(INSTR_ADDR_WIDTH)
  ) jump (
      .imediato_26bits(instrucao[25:0]),
      .instrucao(endereco_do_jump)
  );

  multiplex_jump #(
      .ADDR_WIDTH(INSTR_ADDR_WIDTH)
  ) mj (
      .normal_ou_branch(novo_endereco),
      .jump(endereco_do_jump),
      .control_jump(control_jump),
      .escolhido_multiplexador_jump(escolhido_multiplexador_jump)
  );

  bne_or_beq bob (
      .control_beq(beq),
      .control_bne(bne),
      .zero(zero),
      .control_branch(control_branch)
  );

  multiplex_entrada #(
      .DATA_WIDTH(DATA_WIDTH)
  ) mentr (
      .dado_lido_entrada(resultado_entrada),
      .dado_memoria_ula(escolhido_multiplexador_jal),
      .in(in),
      .KeyboardInput(resultadoKeyBoard),    // diff
      .escolhido_multiplexador_entrada(escolhido_multiplexador_entrada)
  );

  multiplex_saida #(
      .DATA_WIDTH(DATA_WIDTH)
  ) msaid (
      .dado_lido_entrada(resultado_entrada),
      .resultado_ula(saida_ula),
      .in(in),
      .out(out),
      .escolhido_multiplexador_saida(escolhido_multiplexador_saida)
  );

  multiplex_destino mdest (
      .reg_destino(escolhido_multiplexador_reg_dst),
      .jal(jal),
      .jalr(jalr),
      .escolhido_multiplexador_destino(escolhido_multiplexador_destino)
  );

  multiplex_jal #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(INSTR_ADDR_WIDTH)
  ) mjal (
      novo_endereco,
      escolhido_multiplexador_mem_to_reg,
      jalr,
      jal,
      escolhido_multiplexador_jal
  );

  multiplex_jr #(
      .ADDR_WIDTH(INSTR_ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) mjr (
      br_dado1,
      escolhido_multiplexador_jump,
      jalr,
      jr,
      escolhido_multiplexador_jump_reg
  );

  modulo_offset_base #(
      .ADDR_WIDTH(INSTR_ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) offset_base_module (
      .endereco_entrada(escolhido_multiplexador_jump_reg),
      .pc_atual(endereco_instrucao),
      .reg_base(offset_base),
      .is_jump(control_jump),         // JUMP ou JAL
      .is_branch(control_branch),     // BEQ ou BNE efetivo
      .is_jr(jr | jalr),              // JR ou JALR
      .endereco_saida(endereco_com_offset)
  );

  multiplex_pc #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(INSTR_ADDR_WIDTH)
  ) mpc (
      .valor_pc(endereco_instrucao),
      .pc_interrup(pc_interrup),
      .dado(escolhido_multiplexador_entrada),
      .save_pc(save_pc),
      .get_pc_interrup(get_pc_interrup),
      .escolhido_multiplexador_pc(escolhido_multiplexador_pc),
      .get_interruption(get_interruption),
      .qual_interrupcao(qual_interrupcao)
  );

  tela_lcd tlcd (
      .clock_50(entrada_clock),
      .switches(resultado_entrada),
      .lcd_on(LCD_ON),
      .lcd_blon(LCD_BLON),
      .lcd_rw(LCD_RW),
      .lcd_en(LCD_EN),
      .lcd_rs(LCD_RS),
      .lcd_data(LCD_DATA),
      .immediate(instrucao[15:0]),
      .clock(clock),
      .enable_display(disp),
      .data_1(br_dado1),
      .data_2(br_dado2)
  );

  modulo_interrupcao #(
      .ADDR_WIDTH(INSTR_ADDR_WIDTH)
  ) inter (
      .halt(halt),
      .clk(clock),
      .set(set_clock),
      .pc(endereco_instrucao),
      .int_halt(int_halt),
      .int_clk(int_clk),
      .int_time(instrucao[15:0])
  );

  /* diff */
  modulo_vga mvga (
      .clock(entrada_clock),
      .wr_en(frame_buffer_write),
      .wr_addr(saida_ula[16:0]), // Assuming saida_ula[16:0] is the address for framebuffer
      .wr_data(br_dado2[2:0]), // We want to display the lower 3 bits of the ULA output
      .disp_rgb(disp_rgb),
      .hsync(hsync),
      .vsync(vsync)
  );

endmodule
