module modulo_input
(
  // Entradas
  input         clock,                            // Clock de 50 MHz
  input         botao,                            // Botão para confirmar entrada (IN)
  input         botao_continue,                   // Botão para continuar (OUT/PAUSE)
  input  [13:0] sw,                               // Switches de entrada
  input  [1:0]  pause,                            // Modo: 0=manual IN, 1=normal, 2=manual OUT
  input  [1:0]  in,                               // Sinal de entrada (não utilizado atualmente)
  
  // Saídas
  output [13:0] resultado_entrada,                // Valor capturado dos switches
  output        saida_botao,                      // Sinal debounced do botão IN
  output        saida_botao_continue,             // Sinal debounced do botão continue
  output        saida_clock                       // Clock gerado para o processador
);

  // Registradores internos
  reg [25:0] out;                                 // Contador para divisão de clock
  reg [13:0] resultado;                           // Armazena valor dos switches
  reg        reg_clock;                           // Clock gerado
  reg [3:0]  debouncer;                           // Contador de debounce para botao
  reg [3:0]  debouncer_continue;                  // Contador de debounce para botao_continue

  // Inicialização
  initial begin
    out               = 26'd0;
    resultado         = 14'd0;
    reg_clock         = 1'b0;
    debouncer         = 4'd0;
    debouncer_continue = 4'd0;
  end

  // Debounce para o botao (confirmar entrada de dados na instrução IN)
  always @(posedge clock) begin
    if ((botao == 0) && (debouncer[3] != 1))
      debouncer <= debouncer + 1;
    else if (botao == 1)
      debouncer <= 4'd0;
  end

  // Debounce para o botao_continue (avançar clock manualmente em PAUSE=2)
  always @(posedge clock) begin
    if ((botao_continue == 0) && (debouncer_continue[3] != 1))
      debouncer_continue <= debouncer_continue + 1;
    else if (botao_continue == 1)
      debouncer_continue <= 4'd0;
  end

  // Geração do clock do processador com 3 modos
  always @(posedge clock) begin
    if (pause == 1) begin
      // Modo 1: Normal/rápido (execução automática)
      // Clock de 64 Hz (781_250 ciclos de 50 MHz)
      if (out == 26'd781_250) begin
        out       <= 26'd0;
        reg_clock <= ~reg_clock;
      end else begin
        out <= out + 1;
      end
    end
    else if (pause == 0) begin
      // Modo 0: Manual para instrução IN
      // Aguarda botao ser pressionado para confirmar entrada de dados
      if (debouncer[3] == 1) begin
        if (out == 26'd25_000_000) begin
          out       <= 26'd0;
          reg_clock <= ~reg_clock;
        end else begin
          out <= out + 1;
        end
      end
    end
    else if (pause == 2) begin
      // Modo 2: Manual para instrução OUT (ou outras pausas)
      // Aguarda botao_continue ser pressionado para prosseguir
      if (debouncer_continue[3] == 1) begin
        if (out == 26'd25_000_000) begin
          out       <= 26'd0;
          reg_clock <= ~reg_clock;
        end else begin
          out <= out + 1;
        end
      end
    end
  end

  // Captura o valor dos switches quando SW[13] está ativo
  always @(*) begin
    if (sw[13] == 1)
      resultado = {1'd0, sw[12:0]};
  end

  // Atribuições de saída
  assign saida_botao          = debouncer[3];
  assign saida_botao_continue = debouncer_continue[3];
  assign saida_clock          = reg_clock;
  assign resultado_entrada    = resultado;

endmodule