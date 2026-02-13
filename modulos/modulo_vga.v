module VGA (
    input wire clock,         // System clock (e.g., 50 MHz)
    input wire wr_en,         // Write enable for framebuffer
    input wire [16:0] wr_addr, // Write address for framebuffer
    input wire [2:0] wr_data,  // Write data for framebuffer
    output wire [2:0] disp_RGB,// RGB data to display
    output wire hsync,        // Horizontal sync
    output wire vsync         // Vertical sync
);

    // Parameter to control pixel scaling.
    // This factor scales down from the BASE_FB_LOGICAL_WIDTH/HEIGHT.
    // PIXEL_SCALING_FACTOR = 1: Framebuffer is 640x480 (each FB pixel is 1x1 screen pixels)
    // PIXEL_SCALING_FACTOR = 2: Framebuffer is 320x240 (each FB pixel is 2x2 screen pixels)
    // PIXEL_SCALING_FACTOR = 4: Framebuffer is 160x120 (each FB pixel is 4x4 screen pixels)
    // PIXEL_SCALING_FACTOR = 8: Framebuffer is 80x60 (each FB pixel is 8x8 screen pixels)
    // Ensure BASE_FB_LOGICAL_WIDTH/HEIGHT are divisible by this factor.
    parameter PIXEL_SCALING_FACTOR = 16;

    // Base logical framebuffer dimensions (before PIXEL_SCALING_FACTOR is applied)
    localparam BASE_FB_LOGICAL_WIDTH = 640;
    localparam BASE_FB_LOGICAL_HEIGHT = 480;

    // Actual framebuffer dimensions after applying PIXEL_SCALING_FACTOR
    localparam ACTUAL_FB_WIDTH = BASE_FB_LOGICAL_WIDTH / PIXEL_SCALING_FACTOR;
    localparam ACTUAL_FB_HEIGHT = BASE_FB_LOGICAL_HEIGHT / PIXEL_SCALING_FACTOR;
    localparam ACTUAL_FB_ADDR_WIDTH = $clog2(ACTUAL_FB_WIDTH * ACTUAL_FB_HEIGHT);

    reg [9:0] hcount, vcount; // Horizontal and vertical screen counters (pixel clock rate)
    wire hcount_ov, vcount_ov, dat_act;
    reg vga_clk; // VGA pixel clock

    // Framebuffer signals
    wire [ACTUAL_FB_ADDR_WIDTH-1:0] rd_addr_internal; // Read address for the new smaller framebuffer
    wire [2:0] fb_data;          // Data read from framebuffer

    // Timing parameters (standard 640x480 @ 60Hz, pixel clock ~25MHz)
    parameter hsync_end  = 10'd95,
              hdat_begin = 10'd143,
              hdat_end   = 10'd783,
              hpixel_end = 10'd799;

    parameter vsync_end  = 10'd1,
              vdat_begin = 10'd34,
              vdat_end   = 10'd514,
              vline_end  = 10'd524;


    framebuffer #(
        .DATA_WIDTH(3),
        .ADDR_WIDTH(ACTUAL_FB_ADDR_WIDTH)
    ) fb (
        .clk(vga_clk), // Use the VGA pixel clock for framebuffer operations
        .we(wr_en),
        .write_addr(wr_addr), 
        .data(wr_data),       
        .read_addr(rd_addr_internal),
        .q(fb_data)
    );

    // Read address calculation
    // screen_h_coord: 0-639 (current horizontal pixel on screen within active area)
    // screen_v_coord: 0-479 (current vertical line on screen within active area)
    wire [9:0] screen_h_coord = (hcount >= hdat_begin && hcount < hdat_end) ? (hcount - hdat_begin) : 0;
    wire [9:0] screen_v_coord = (vcount >= vdat_begin && vcount < vdat_end) ? (vcount - vdat_begin) : 0;

    // fb_access_h_idx/v_idx: coordinates for the actual (scaled) framebuffer
    // These are derived by scaling the screen coordinates by PIXEL_SCALING_FACTOR.
    wire [9:0] fb_access_h_idx = screen_h_coord / PIXEL_SCALING_FACTOR;
    wire [9:0] fb_access_v_idx = screen_v_coord / PIXEL_SCALING_FACTOR;

    // Calculate the 1D address for the framebuffer read
    assign rd_addr_internal = fb_access_v_idx * ACTUAL_FB_WIDTH + fb_access_h_idx;

    // Clock divider for VGA pixel clock (e.g., 50MHz system clock to 25MHz VGA clock)
    always @(posedge clock) begin
        vga_clk <= ~vga_clk;
    end

    // Horizontal counter (counts at vga_clk rate)
    always @(posedge vga_clk) begin
        if (hcount_ov) hcount <= 10'd0;
        else hcount <= hcount + 10'd1;
    end
    assign hcount_ov = (hcount == hpixel_end);

    // Vertical counter (increments when a horizontal line ends)
    always @(posedge vga_clk) begin
        if (hcount_ov) begin
            if (vcount_ov) vcount <= 10'd0;
            else vcount <= vcount + 10'd1;
        end
    end
    assign vcount_ov = (vcount == vline_end);

    // Sync signals and active data region
    assign dat_act = ((hcount >= hdat_begin) && (hcount < hdat_end))
                  && ((vcount >= vdat_begin) && (vcount < vdat_end));
    assign hsync = !((hcount >= 0) && (hcount < hsync_end)); // Active low
    assign vsync = !((vcount >= 0) && (vcount < vsync_end)); // Active low

    // RGB output: display framebuffer data during active region, else black
    assign disp_RGB = dat_act ? fb_data : 3'h0;

endmodule