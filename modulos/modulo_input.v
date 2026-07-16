module modulo_input
(
  // Entradas
  input         clock,                            // Clock de 50 MHz
  input         botao,                            // Botão para confirmar entrada (IN)
  input         botao_continue,                   // Botão para continuar (OUT/PAUSE)
  input  [13:0] sw,                               // Switches de entrada
  input  [1:0]  pause,                            // Modo: 0=manual IN, 1=normal, 2=manual OUT
  input  [1:0]  in,                               // Sinal de entrada

  // PS/2
  input         ps2_clk,
  input         ps2_data,

  // Saídas
  output [13:0] resultado_entrada,                // Valor capturado dos switches
  output        saida_botao,                      // Sinal debounced do botão IN
  output        saida_botao_continue,             // Sinal debounced do botão continue
  output        saida_clock,                      // Clock gerado para o processador
  output [7:0]  ps2_data_out                      // Último byte válido do teclado PS/2
);

  // Registradores internos
  reg [25:0] out;                                 // Contador para divisão de clock
  reg [13:0] resultado;                           // Armazena valor dos switches
  reg        reg_clock;                           // Clock gerado
  reg [5:0]  debouncer;                           // Contador de debounce para botao
  reg [5:0]  debouncer_continue;                  // Contador de debounce para botao_continue
  reg        ready_clean;                         // Sinal para limpar o buffer do teclado
  reg [7:0]  ps2_data_out_reg;                       // Saída do último byte válido do teclado PS/2

  // Buffer do teclado PS/2
  reg [7:0] ps2_keyboard_buffer;
  wire [7:0] ps2_keyboard_data;
  wire data_valid;

  // Inicialização
  initial begin
    out                 = 26'd0;
    resultado           = 14'd0;
    reg_clock           = 1'b0;
    debouncer           = 6'd0;
    debouncer_continue  = 6'd0;
    ps2_keyboard_buffer = 8'd0;
    ready_clean         = 1'b0;
  end

  // Receptor PS/2
  PS2Key ps2_inst (
      .clk(clock),
      .PS2_clk(ps2_clk),
      .PS2_DAT(ps2_data),
      .data(ps2_keyboard_data),
      .data_valid(data_valid)
  );

  // Debounce para o botao (confirmar entrada de dados na instrução IN)
  always @(posedge clock) begin
    if ((botao == 1'b0) && (debouncer[5] != 1'b1))
      debouncer <= debouncer + 1'b1;
    else if (botao == 1'b1)
      debouncer <= 6'd0;
  end

  // Debounce para o botao_continue (avançar clock manualmente em PAUSE=2)
  always @(posedge clock) begin
    if ((botao_continue == 1'b0) && (debouncer_continue[5] != 1'b1))
      debouncer_continue <= debouncer_continue + 1'b1;
    else if (botao_continue == 1'b1)
      debouncer_continue <= 6'd0;
  end

  // Geração do clock do processador com 3 modos
  always @(posedge clock) begin
    if (pause == 2'd1) begin
      // Modo 1: Normal/rápido (execução automática)
      // Clock de 2MHz (25 ciclos de 50 MHz)
      if (out == 26'd25) begin
        out       <= 26'd0;
        reg_clock <= ~reg_clock;
      end else begin
        out <= out + 1'b1;
      end
    end
    else if (pause == 2'd0) begin
      // Modo 0: Manual para instrução IN
      if (debouncer[5] == 1'b1) begin
        // Clock de 1Hz (25 milhões de ciclos de 50 MHz)
        if (out == 26'd25_000_000) begin
          out       <= 26'd0;
          reg_clock <= ~reg_clock;
        end else begin
          out <= out + 1'b1;
        end
      end
    end
    else if (pause == 2'd2) begin
      // Modo 2: Manual para instrução OUT (ou outras pausas)
      if (debouncer_continue[5] == 1'b1) begin
        // Clock de 1Hz (25 milhões de ciclos de 50 MHz)
        if (out == 26'd25_000_000) begin
          out       <= 26'd0;
          reg_clock <= ~reg_clock;
        end else begin
          out <= out + 1'b1;
        end
      end
    end
  end

  // Captura o valor dos switches quando SW[13] está ativo
  always @(*) begin
    if (sw[13] == 1'b1)
      resultado = {1'b0, sw[12:0]};
    else
      resultado = 14'd0;
  end

  always @(negedge reg_clock) begin
    if (in == 2'd2) begin
      ps2_data_out_reg <= ps2_keyboard_buffer;
      ready_clean <= 1'b1;
    end
    else begin
      ps2_data_out_reg <= 8'd0;
      ready_clean <= 1'b0;
    end
  end

  // Armazena a última tecla válida recebida e limpa após consumo pela CPU
  always @(posedge clock) begin
    if (data_valid) begin
      ps2_keyboard_buffer <= ps2_keyboard_data;
    end 
    if (ready_clean) begin
      ps2_keyboard_buffer <= 8'd0;
    end
  end

  // Atribuições de saída
  assign saida_botao          = debouncer[5];
  assign saida_botao_continue = debouncer_continue[5];
  assign saida_clock          = reg_clock;
  assign resultado_entrada    = resultado;
  assign ps2_data_out         = ps2_data_out_reg;
endmodule
