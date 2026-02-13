module scancode_decoder (
    input  wire       clk,
    input  wire [7:0] scan_code,
    output reg  [7:0] ascii_code
);

  // PS/2 Set 2 Make Codes (Single Byte)

  // Numbers 0-9
  localparam KEY_0 = 8'h45;
  localparam KEY_1 = 8'h16;
  localparam KEY_2 = 8'h1E;
  localparam KEY_3 = 8'h26;
  localparam KEY_4 = 8'h25;
  localparam KEY_5 = 8'h2E;
  localparam KEY_6 = 8'h36;
  localparam KEY_7 = 8'h3D;
  localparam KEY_8 = 8'h3E;
  localparam KEY_9 = 8'h46;

  // Letters A - F (Hexadecimal)
  localparam KEY_A = 8'h1C;
  localparam KEY_B = 8'h32;
  localparam KEY_C = 8'h21;
  localparam KEY_D = 8'h23;
  localparam KEY_E = 8'h24;
  localparam KEY_F = 8'h2B;

  // A Keyboard Enter Key (Can be any key, but this is a common one)
  localparam KEY_ENTER = 8'h5A;

  always @(*) begin
    case (scan_code)
      KEY_0: begin
        ascii_code = 8'h30;  // ASCII '0'
      end
      KEY_1: begin
        ascii_code = 8'h31;  // ASCII '1'
      end
      KEY_2: begin
        ascii_code = 8'h32;  // ASCII '2'
      end
      KEY_3: begin
        ascii_code = 8'h33;  // ASCII '3'
      end
      KEY_4: begin
        ascii_code = 8'h34;  // ASCII '4'
      end
      KEY_5: begin
        ascii_code = 8'h35;  // ASCII '5'
      end
      KEY_6: begin
        ascii_code = 8'h36;  // ASCII '6'
      end
      KEY_7: begin
        ascii_code = 8'h37;  // ASCII '7'
      end
      KEY_8: begin
        ascii_code = 8'h38;  // ASCII '8'
      end
      KEY_9: begin
        ascii_code = 8'h39;  // ASCII '9'
      end
      KEY_ENTER: begin
        ascii_code = 8'h0D;  // ASCII CR (Carriage Return)
      end
      KEY_A: begin
        ascii_code = 8'h41;  // ASCII 'A'
      end
      KEY_B: begin
        ascii_code = 8'h42;  // ASCII 'B'
      end
      KEY_C: begin
        ascii_code = 8'h43;  // ASCII 'C'
      end
      KEY_D: begin
        ascii_code = 8'h44;  // ASCII 'D'
      end
      KEY_E: begin
        ascii_code = 8'h45;  // ASCII 'E'
      end
      KEY_F: begin
        ascii_code = 8'h46;  // ASCII 'F'
      end

      default: begin
        ascii_code = scan_code;  // For debugging: output raw scan code
      end
    endcase
  end

endmodule