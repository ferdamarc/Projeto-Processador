module PS2Key (
    input            clk,        
    input            PS2_clk,    
    input            PS2_DAT,    
    output reg [7:0] data,       
    output reg       data_valid  
);
  reg  [7:0] raw_scancode;  
  wire [7:0] decoded_ascii;  

  
  reg ps2_clk_sync1, ps2_clk_sync2;
  reg ps2_dat_sync1, ps2_dat_sync2;
  wire ps2_clk_synced = ps2_clk_sync2;  
  wire ps2_dat_synced = ps2_dat_sync2;  

  always @(posedge clk) begin
    ps2_clk_sync1 <= PS2_clk;
    ps2_clk_sync2 <= ps2_clk_sync1;
    ps2_dat_sync1 <= PS2_DAT;
    ps2_dat_sync2 <= ps2_dat_sync1;
  end

  
  reg  ps2_clk_prev;
  wire ps2_clk_falling_edge;
  always @(posedge clk) begin
    ps2_clk_prev <= ps2_clk_synced;
  end
  assign ps2_clk_falling_edge = ps2_clk_prev & ~ps2_clk_synced;

  
  parameter IDLE = 0;
  parameter RECEIVING = 1;
  parameter CHECK_STOP = 2;
  parameter DECODE_WAIT = 3;

  reg [1:0] state;
  reg [3:0] bit_count;
  reg [7:0] data_buffer;
  reg       parity_bit;
  reg       error_flag;
  reg       decode_pending;  

  
  reg [7:0] last_make_code;  
  reg       break_code_expected;  

  initial begin
    state               = IDLE;
    bit_count           = 0;
    data_buffer         = 0;
    parity_bit          = 0;
    raw_scancode        = 0;
    data                = 0;  
    data_valid          = 0;  
    error_flag          = 0;
    ps2_clk_prev        = 0;  
    last_make_code      = 0;  
    break_code_expected = 0;  
    decode_pending      = 0;
  end

  
  always @(posedge clk) begin
    data_valid <= 0;  

    if (decode_pending) begin
      data <= decoded_ascii;
      data_valid <= 1'b1;
      decode_pending <= 0;
    end

    if (ps2_clk_falling_edge) begin
      case (state)
        IDLE: begin
          if (ps2_dat_synced == 0) begin  
            state       <= RECEIVING;
            bit_count   <= 0;
            data_buffer <= 0;
            error_flag  <= 0;
          end
        end

        RECEIVING: begin
          if (bit_count < 8) begin  
            data_buffer[bit_count] <= ps2_dat_synced;
            bit_count              <= bit_count + 1;
          end else if (bit_count == 8) begin  
            parity_bit <= ps2_dat_synced;
            bit_count  <= bit_count + 1;
            state      <= CHECK_STOP;
          end else begin  
            state      <= IDLE;
            error_flag <= 1;
          end
        end

        CHECK_STOP: begin
          if (ps2_dat_synced == 1) begin  
            
            raw_scancode <= data_buffer;  

            if (break_code_expected) begin
              
              if (data_buffer == last_make_code) begin
                last_make_code <= 8'h00;  
              end

              break_code_expected <= 1'b0;
            end else if (data_buffer == 8'hF0) begin
              
              break_code_expected <= 1'b1;
            end else if (data_buffer != last_make_code) begin
              
              last_make_code <= data_buffer;  
              decode_pending <= 1;  
              

              
            end
          end else begin
            
            error_flag <= 1;
          end

          state     <= IDLE;  
          bit_count <= 0;
        end


        default: begin
          state <= IDLE;
        end
      endcase
    end  

  end  

  
  scancode_decoder i_scancode_decoder (
      .clk(clk),
      .scan_code(raw_scancode),  
      .ascii_code(decoded_ascii)  
  );

endmodule