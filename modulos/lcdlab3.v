module lcdlab3(
  input CLOCK_50,	//	50 MHz clock
  input [3:0] KEY,      //	Pushbutton[3:0]
  input [15:0] Choice,	//	Toggle Switch[17:0]
  input [3:0] ThousandsBin1, 
  input [3:0] HundredsBin1, 
  input [3:0] TensBin1, 
  input [3:0] OnesBin1,
  input [3:0] ThousandsBin2, 
  input [3:0] HundredsBin2, 
  input [3:0] TensBin2, 
  input [3:0] OnesBin2,
  //output [6:0]	HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7,  // Seven Segment Digits[
  inout [35:0] GPIO_0,GPIO_1,	//	GPIO Connections
//	LCD Module 16X2
  output LCD_ON,	// LCD Power ON/OFF
  output LCD_BLON,	// LCD Back Light ON/OFF
  output LCD_RW,	// LCD Read/Write Select, 0 = Write, 1 = Read
  output LCD_EN,	// LCD Enable
  output LCD_RS,	// LCD Command/Data Select, 0 = Command, 1 = Data
  inout [7:0] LCD_DATA	// LCD Data bus 8 bits
);

//	All inout port turn to tri-state
assign	GPIO_0		=	36'hzzzzzzzzz;
assign	GPIO_1		=	36'hzzzzzzzzz;

wire [6:0] myclock;
wire RST;
assign RST = KEY[0];

// reset delay gives some time for peripherals to initialize
wire DLY_RST;
reset_Delay  r0(.iCLK(CLOCK_50),.oRESET(DLY_RST) );

// Send switches to red leds 

// turn LCD ON
assign	LCD_ON		=	1'b1;
assign	LCD_BLON	=	1'b1;

wire [3:0] hex3_Num2, hex2_Num2, hex1_Num2, hex0_Num2, hex3_Num1, hex2_Num1, hex1_Num1, hex0_Num1;

assign hex3_Num2 = ThousandsBin2;
assign hex2_Num2 = HundredsBin2;
assign hex1_Num2 = TensBin2;
assign hex0_Num2 = OnesBin2;
assign hex3_Num1 = ThousandsBin1;
assign hex2_Num1 = HundredsBin1;
assign hex1_Num1 = TensBin1;
assign hex0_Num1 = OnesBin1;

display_lcd  u1(
// Host Side
   .iCLK_50MHZ(CLOCK_50),
   .iRST_N(DLY_RST),
	.hex3_Num2(hex3_Num2), 
	.hex2_Num2(hex2_Num2), 
	.hex1_Num2(hex1_Num2), 
	.hex0_Num2(hex0_Num2), 
	.hex3_Num1(hex3_Num1), 
	.hex2_Num1(hex2_Num1), 
	.hex1_Num1(hex1_Num1), 
	.hex0_Num1(hex0_Num1),
	.Choice(Choice),
// LCD Side
   .DATA_BUS(LCD_DATA),
   .LCD_RW(LCD_RW),
   .LCD_E(LCD_EN),
   .LCD_RS(LCD_RS)
);


// blank unused 7-segment digits

endmodule