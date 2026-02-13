module modulo_output_v2
(
  // Entradas de dados
  input  [31:0] valor_saida,                      // Valor a ser exibido (instrução OUT)
  input         halt,                             // Sinal de HALT (não utilizado atualmente)
  input         clock_cpu,                        // Clock sincronizado com CPU
  input         enable_out,                       // Habilita captura de valor de saída
  input         enable_in,                        // Habilita exibição em LEDs de entrada
  input         switch_enable,                    // SW[13] controla LED 13

  // Entradas de monitoramento
  input  [9:0]  pc,                               // Program Counter atual
  input  [31:0] fp,                               // Frame Pointer ($29)
  
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

  // Saídas PS2
  output [7:0] seg,
  output [3:0] dig,

  // Clock
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
  
  wire [7:0] _seg;
  reg  [3:0] _dig;

  reg [1:0] digit_sel = 0;
  reg [3:0] digit_values [3:0];
  reg [19:0] clk_240hz_counter;

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
    clk_240hz_counter <= 20'd0;
  end

  always @(posedge clk) begin
    // Contador para gerar enable a ~240Hz (50MHz / 240 ≈ 208333)
    if (clk_240hz_counter >= 208333) begin
      clk_240hz_counter <= 20'd0;
      digit_sel <= digit_sel + 1; // Alterna entre os dígitos
    end else begin
      clk_240hz_counter <= clk_240hz_counter + 1;
    end
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

    digit_values[0] <= valor_display_1;
    digit_values[1] <= valor_display_2;
    digit_values[2] <= valor_display_3;
    digit_values[3] <= valor_display_4;
  end

  // Atualização dos displays de PC e LEDs (usando clock de 50MHz)
  always @(posedge clk_240hz_counter) begin
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

  always @(posedge clk) begin
    case (digit_sel)
      2'b00: _dig <= 4'b1110; // Ativa o primeiro dígito
      2'b01: _dig <= 4'b1101; // Ativa o segundo dígito
      2'b10: _dig <= 4'b1011; // Ativa o terceiro dígito
      2'b11: _dig <= 4'b0111; // Ativa o quarto dígito
      default: begin
        _dig <= 4'b1111; // Desativa todos os dígitos
      end
    endcase
  end

  // Instâncias dos conversores BCD para valores de saída
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

  display_7segmentos bcd_pc_1 (
    .bcd(valor_display_pc_1),
    .seg(display_pc_1)
  );

  display_7segmentos bcd_pc_2 (
    .bcd(valor_display_pc_2),
    .seg(display_pc_2)
  );

  display_7segmentos bcd_fp_1 (
    .bcd(valor_display_fp_1),
    .seg(display_fp_1)
  );

  display_7segmentos bcd_fp_2 (
    .bcd(valor_display_fp_2),
    .seg(display_fp_2)
  );

  display_7segmentos bcd_seg (
    .bcd(digit_values[digit_sel]),
    .seg(_seg)
  );

  // Atribuição dos LEDs (LED13 = status SW[13], LEDs 0-12 = dados)
  assign led = {reg_led_13, reg_leds[12:0]};
  assign seg = {1'd1, _seg[6:0]};
  assign dig = _dig;

endmodule
