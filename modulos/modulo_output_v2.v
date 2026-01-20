module modulo_output_v2
(
  // Entradas de dados
  input  [31:0] valor_saida,                      // Valor a ser exibido (instrução OUT)
  input         halt,                             // Sinal de HALT (não utilizado atualmente)
  input         clock_cpu,                        // Clock sincronizado com CPU
  input         enable_out,                       // Habilita captura de valor de saída
  input         enable_in,                        // Habilita exibição em LEDs de entrada
  input         switch_enable,                    // SW[13] controla LED 13
  
  // Saídas para LEDs e displays
  output [13:0] led,                              // 14 LEDs
  output [6:0]  display_1,                        // Display 1 (unidades do valor)
  output [6:0]  display_2,                        // Display 2 (dezenas do valor)
  output [6:0]  display_3,                        // Display 3 (centenas do valor)
  output [6:0]  display_4,                        // Display 4 (milhares do valor)
  output [6:0]  display_pc_1,                     // Display 1 do PC (unidades)
  output [6:0]  display_pc_2,                     // Display 2 do PC (dezenas)
  output [6:0]  display_fp_1,                     // Display 1 do FP (unidades)
  output [6:0]  display_fp_2,                     // Display 2 do FP (dezenas)
  
  // Entradas de monitoramento
  input  [9:0]  pc,                               // Program Counter atual
  input  [31:0] fp,                               // Frame Pointer ($29)
  input         clk                               // Clock de 50 MHz
);

  // Registradores para dígitos BCD (0-9) dos displays
  reg [3:0] valor_display_1;                      // Unidades do valor de saída
  reg [3:0] valor_display_2;                      // Dezenas do valor de saída
  reg [3:0] valor_display_3;                      // Centenas do valor de saída
  reg [3:0] valor_display_4;                      // Milhares do valor de saída
  reg [3:0] valor_display_pc_1;                   // Unidades do PC
  reg [3:0] valor_display_pc_2;                   // Dezenas do PC
  reg [3:0] valor_display_fp_1;                   // Unidades do FP
  reg [3:0] valor_display_fp_2;                   // Dezenas do FP

  // Registradores para LEDs
  reg        reg_led_13;                          // LED 13 (status SW[13])
  reg [12:0] reg_leds;                            // LEDs 0-12 (dados)
  reg [31:0] valor_registrado;                    // Armazena valor capturado para exibição
  
  // Inicialização
  initial begin
    valor_display_1   <= 4'd0;
    valor_display_2   <= 4'd0;
    valor_display_3   <= 4'd0;
    valor_display_4   <= 4'd0;
    valor_display_pc_1 <= 4'd0;
    valor_display_pc_2 <= 4'd0;
    valor_display_fp_1 <= 4'd0;
    valor_display_fp_2 <= 4'd0;
    reg_led_13        <= 1'b0;
    reg_leds          <= 13'd0;
    valor_registrado  <= 32'd0;
  end

  // Atualização dos displays de valor e FP (sincronizado com clock_cpu)
  always @(posedge clock_cpu) begin
    // Atualiza constantemente os dígitos do FP
    valor_display_fp_1 <= fp % 10;
    valor_display_fp_2 <= (fp % 100) / 10;

    // Captura e armazena valor quando enable_out e switch_enable ativos
    if (enable_out && switch_enable) begin
      valor_registrado <= valor_saida;
    end
    
    // Atualiza os displays com o valor armazenado (decomposição BCD)
    valor_display_1 <= valor_registrado % 10;
    valor_display_2 <= (valor_registrado % 100) / 10;
    valor_display_3 <= (valor_registrado % 1000) / 100;
    valor_display_4 <= (valor_registrado % 10000) / 1000;
  end

  // Atualização dos displays de PC e LEDs (usando clock de 50MHz)
  always @(posedge clk) begin
    // Mostra os últimos dois dígitos do PC
    valor_display_pc_1 <= pc % 10;
    valor_display_pc_2 <= (pc % 100) / 10;

    // LED 13 indica se os switches estão habilitados
    reg_led_13 <= switch_enable;

    // LEDs 0-12 mostram os 13 bits menos significativos quando enable_in ativo
    if (enable_in) begin
      reg_leds <= valor_saida[12:0];
    end else begin
      reg_leds <= 13'd0;
    end
  end

  // Instâncias dos conversores BCD → 7 segmentos para valores de saída
  display_7segmentos bcd_1 (
    .bcd(valor_display_1),
    .seg(display_1)
  );

  display_7segmentos bcd_2 (
    .bcd(valor_display_2),
    .seg(display_2)
  );

  display_7segmentos bcd_3 (
    .bcd(valor_display_3),
    .seg(display_3)
  );

  display_7segmentos bcd_4 (
    .bcd(valor_display_4),
    .seg(display_4)
  );

  // Conversores BCD → 7 segmentos para PC
  display_7segmentos bcd_pc_1 (
    .bcd(valor_display_pc_1),
    .seg(display_pc_1)
  );

  display_7segmentos bcd_pc_2 (
    .bcd(valor_display_pc_2),
    .seg(display_pc_2)
  );

  // Conversores BCD → 7 segmentos para FP
  display_7segmentos bcd_fp_1 (
    .bcd(valor_display_fp_1),
    .seg(display_fp_1)
  );

  display_7segmentos bcd_fp_2 (
    .bcd(valor_display_fp_2),
    .seg(display_fp_2)
  );

  // Atribuição dos LEDs (LED13 = status SW[13], LEDs 0-12 = dados)
  assign led = {reg_led_13, reg_leds[12:0]};

endmodule
