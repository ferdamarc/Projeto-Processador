module tela_lcd
(
  // Entradas do sistema
  input wire        clock_50,                     // Clock de 50 MHz
  input wire [17:0] switches,                     // Switches (não utilizados atualmente)
  
  // Saídas para o display LCD
  output wire       lcd_on,                       // Liga o display LCD
  output wire       lcd_blon,                     // Liga o backlight do LCD
  output wire       lcd_rw,                       // Read/Write (0=write)
  output wire       lcd_en,                       // Enable
  output wire       lcd_rs,                       // Register Select (0=comando, 1=dados)
  inout  wire [7:0] lcd_data,                     // Barramento de dados bidirecional
  
  // Entradas de dados
  input wire [15:0] immediate,                    // Imediato da instrução display_lcd
  input wire        clock,                        // Clock do processador
  input wire        enable_display,               // Sinal de habilitação do display
  input wire [31:0] data_1,                       // Primeiro valor a ser exibido
  input wire [31:0] data_2                        // Segundo valor a ser exibido
);

  // Dígitos BCD para data_1
  wire [3:0] thousands_bin_1;                     // Milhares
  wire [3:0] hundreds_bin_1;                      // Centenas
  wire [3:0] tens_bin_1;                          // Dezenas
  wire [3:0] ones_bin_1;                          // Unidades
  
  // Dígitos BCD para data_2
  wire [3:0] thousands_bin_2;                     // Milhares
  wire [3:0] hundreds_bin_2;                      // Centenas
  wire [3:0] tens_bin_2;                          // Dezenas
  wire [3:0] ones_bin_2;                          // Unidades
  
  // Registradores internos
  reg [15:0] choice;                              // Armazena o imediato (tipo de exibição)
  reg [31:0] reg_data_1;                          // Registra data_1
  reg [31:0] reg_data_2;                          // Registra data_2
  reg        display_first;                       // Flag indicando primeira ativação
  
  // Inicialização
  initial begin
    display_first = 1'b0;
  end
  
  // Captura os dados quando enable_display é ativado
  always @(negedge clock) begin
    if (enable_display) begin
      display_first <= 1'b1;                      // Trava o flag em 1 no primeiro comando
      choice        <= immediate;
      reg_data_1    <= data_1;
      reg_data_2    <= data_2;
    end
  end
  
  // Conversores binário para BCD (13 bits LSB de cada valor)
  bcd bcd_1 (
    .binary(reg_data_1[12:0]),
    .thousands(thousands_bin_1),
    .hundreds(hundreds_bin_1),
    .tens(tens_bin_1),
    .ones(ones_bin_1)
  );
  
  bcd bcd_2 (
    .binary(reg_data_2[12:0]),
    .thousands(thousands_bin_2),
    .hundreds(hundreds_bin_2),
    .tens(tens_bin_2),
    .ones(ones_bin_2)
  );
  
  wire GPIO_0;
  wire GPIO_1;

  // Instância do controlador LCD
  // Se display_first=0, envia 0xFFFF (desligado)
  // Se display_first=1, envia choice para controlar o tipo de exibição
  lcdlab3 lcd (
    .CLOCK_50(clock_50),
    .KEY(4'b0000),
    .Choice(display_first ? choice : 16'hFFFF),
    .ThousandsBin1(thousands_bin_1),
    .HundredsBin1(hundreds_bin_1),
    .TensBin1(tens_bin_1),
    .OnesBin1(ones_bin_1),
    .ThousandsBin2(thousands_bin_2),
    .HundredsBin2(hundreds_bin_2),
    .TensBin2(tens_bin_2),
    .OnesBin2(ones_bin_2),
    .GPIO_0(GPIO_0),
    .GPIO_1(GPIO_1),
    .LCD_ON(lcd_on),
    .LCD_BLON(lcd_blon),
    .LCD_RW(lcd_rw),
    .LCD_EN(lcd_en),
    .LCD_RS(lcd_rs),
    .LCD_DATA(lcd_data)
  );

endmodule
