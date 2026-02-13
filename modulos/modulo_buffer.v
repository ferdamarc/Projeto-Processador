module framebuffer
#(
    parameter DATA_WIDTH = 3,
    parameter ADDR_WIDTH = 17 // Default, will be overridden by instantiation
)
(
    input wire [(DATA_WIDTH-1):0] data,
    input wire [(ADDR_WIDTH-1):0] read_addr, write_addr,
    input wire we, clk,
    output reg [(DATA_WIDTH-1):0] q
);

    // Declare the RAM variable. Size is now based on ADDR_WIDTH.
    // RAM_DEPTH = 2^ADDR_WIDTH
    localparam RAM_DEPTH = (1 << ADDR_WIDTH);
    reg [DATA_WIDTH-1:0] ram[RAM_DEPTH-1:0];

    // Initial contents.
    // IMPORTANT: If using $readmemb, the .hex file must match the
    // new (potentially smaller) framebuffer resolution defined by ADDR_WIDTH.
    // For example, if ADDR_WIDTH corresponds to 160x120, the hex file
    // should contain 19200 entries.
    initial
    begin : INIT_RAM
        // Example: $readmemb("your_pattern_for_new_resolution.hex", ram);
        // The original file "vga_pattern_pong.hex" was for 320x240 (76800 entries).
        // You will need to generate a new hex file if PIXEL_SCALING_FACTOR > 1.
        // For simulation, you might want to initialize to a default color or pattern here if not using $readmemb.
        integer i;
		integer color;
		integer aux;
		aux = 0;
        for (i = 0; i < RAM_DEPTH; i = i + 1) begin
			// if (i % 40 == 0) // Example: Create a pattern every 40 pixels
			// 	aux = aux + 1; // White color for every 40th pixel
			// color = (i + aux) % 8; // Example: Cycle through colors 0-7
			// ram[i] = color[2:0]; // Assign a color value, e.g., cycling through 0-7
            ram[i] = 3'h0; // Initialize all pixels to black (0,0,0)
        end
        $display("Framebuffer initialized: ADDR_WIDTH = %0d, RAM_DEPTH = %0d", ADDR_WIDTH, RAM_DEPTH);
        // $readmemb("vga_pattern_8.hex", ram); // This line would cause issues if RAM_DEPTH is smaller
    end

    always @ (posedge clk)
    begin
        // Write operation
        if (we) begin
            ram[write_addr] <= data;
        end

        // Read operation
        // If read_addr == write_addr during a write cycle, this returns OLD data due to non-blocking assignment.
        // To return NEW data (read-during-write), use blocking assignment for write OR implement bypass logic.
        // For VGA display, reading old data during write is usually fine as writes are infrequent or timed outside reads.
        q <= ram[read_addr];
    end

endmodule