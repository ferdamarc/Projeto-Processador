module modulo_output (
	input  [31:0] ValorSaida,
	input         halt,
	input         ClockCPU,
	input         EnableOut,
	input         EnableIn,
	input         SwitchEnable, // SW[13] para controlar LED 13
	output [13:0] Led,
	output [6:0] Display1,
	output [6:0] Display2,
	output [6:0] Display3,
	output [6:0] Display4,
	output [6:0] DisplayPC1,
	output [6:0] DisplayPC2,
	output [6:0] DisplayFP1,
	output [6:0] DisplayFP2,
	input  [9:0] PC,
	input [31:0] FP,
	input        clk
);

	// Registradores individuais por dígito (0-9) para os oito displays disponíveis
	reg [3:0] valorDisplay1;
	reg [3:0] valorDisplay2;
	reg [3:0] valorDisplay3;
	reg [3:0] valorDisplay4;
	reg [3:0] valorDisplayPC1;
	reg [3:0] valorDisplayPC2;
	reg [3:0] valorDisplayFP1;
	reg [3:0] valorDisplayFP2;
	reg       regLed13;  // LED 13 (status SW[13] - switches habilitados)
	reg [12:0] RegLeds;

	initial begin
		valorDisplay1 <= 4'd0;
		valorDisplay2 <= 4'd0;
		valorDisplay3 <= 4'd0;
		valorDisplay4 <= 4'd0;
		valorDisplayPC1 <= 4'd0;
		valorDisplayPC2 <= 4'd0;
		valorDisplayFP1 <= 4'd0;
		valorDisplayFP2 <= 4'd0;
		regLed13 <= 1'b0;
		RegLeds <= 13'd0;
	end

	reg [19:0] clk_240hz = 0;
	always @(posedge clk) begin
		clk_240hz <= (clk_240hz == 20'd208333) ? 20'd0 : clk_240hz + 1'b1;
	end

	always @(posedge ClockCPU) begin
		// Atualiza constantemente os dígitos do FP para os dois displays dedicados
		valorDisplayFP1 <= FP % 10;
		valorDisplayFP2 <= (FP % 100) / 10;

		if (EnableOut) begin
			// Exibe o valor da instrução OUT nos quatro primeiros displays
			valorDisplay1 <= ValorSaida % 10;
			valorDisplay2 <= (ValorSaida % 100) / 10;
			valorDisplay3 <= (ValorSaida % 1000) / 100;
			valorDisplay4 <= (ValorSaida % 10000) / 1000;
		end
	end

	always @(posedge clk_240hz) begin
		if (halt) begin
			// Envia padrão de display apagado durante HALT
			valorDisplayPC1 <= 4'b1111;
			valorDisplayPC2 <= 4'b1111;
		end else begin
			// Mostra dezena e unidade do PC nos displays livres
			valorDisplayPC1 <= PC % 10;
			valorDisplayPC2 <= (PC % 100) / 10;
		end

		// LED 13 indica se os switches estão habilitados (SW[13])
		regLed13 <= SwitchEnable;

		if (EnableIn) begin
			RegLeds <= ValorSaida[12:0];
		end
	end

	display_7segmentos bcd1 (
		valorDisplay1,
		Display1
	);

	display_7segmentos bcd2 (
		valorDisplay2,
		Display2
	);

	display_7segmentos bcd3 (
		valorDisplay3,
		Display3
	);

	display_7segmentos bcd4 (
		valorDisplay4,
		Display4
	);

	display_7segmentos bcd5 (
		valorDisplayPC1,
		DisplayPC1
	);

	display_7segmentos bcd6 (
		valorDisplayPC2,
		DisplayPC2
	);

	display_7segmentos bcd7 (
		valorDisplayFP1,
		DisplayFP1
	);

	display_7segmentos bcd8 (
		valorDisplayFP2,
		DisplayFP2
	);

	assign Led = {regLed13, RegLeds[12:0]}; // LED13=Status SW[13], LEDs 0-12=Funcionalidade original

	endmodule
