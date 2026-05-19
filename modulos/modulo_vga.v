module modulo_vga #(
    parameter PIXEL_SCALING_FACTOR = 8,
    parameter HSYNC_END  = 10'd95,
    parameter HDAT_BEGIN = 10'd144,
    parameter HDAT_END   = 10'd784,
    parameter HPIXEL_END = 10'd799,
    parameter VSYNC_END  = 10'd2,
    parameter VDAT_BEGIN = 10'd34,
    parameter VDAT_END   = 10'd514,
    parameter VLINE_END  = 10'd524
)(
    input  wire       clock,
    input  wire       write_clk,
    input  wire       wr_en,
    input  wire [16:0] wr_addr,
    input  wire [2:0] wr_data,
    output wire       hsync,
    output wire       vsync,
    output wire       vga_clk_out,
    output wire       vga_blank_n,
    output wire       vga_sync_n,
    output wire [7:0] vga_r,
    output wire [7:0] vga_g,
    output wire [7:0] vga_b
);

    localparam BASE_FB_LOGICAL_WIDTH  = 640;
    localparam BASE_FB_LOGICAL_HEIGHT = 480;
    localparam ACTUAL_FB_WIDTH = BASE_FB_LOGICAL_WIDTH / PIXEL_SCALING_FACTOR;
    localparam ACTUAL_FB_HEIGHT = BASE_FB_LOGICAL_HEIGHT / PIXEL_SCALING_FACTOR;
    localparam ACTUAL_FB_ADDR_WIDTH = $clog2(ACTUAL_FB_WIDTH * ACTUAL_FB_HEIGHT);

    reg [9:0] hcount;
    reg [9:0] vcount;
    reg vga_clk;

    wire hcount_ov;
    wire vcount_ov;
    wire dat_act;
    wire [ACTUAL_FB_ADDR_WIDTH-1:0] rd_addr_internal;
    wire [ACTUAL_FB_ADDR_WIDTH-1:0] wr_addr_internal;
    wire [2:0] fb_data;
    wire [2:0] disp_rgb;
    wire [9:0] screen_h_coord;
    wire [9:0] screen_v_coord;
    wire [9:0] fb_access_h_idx;
    wire [9:0] fb_access_v_idx;
    assign wr_addr_internal = wr_addr[ACTUAL_FB_ADDR_WIDTH-1:0];

    framebuffer #(
        .DATA_WIDTH(3),
        .ADDR_WIDTH(ACTUAL_FB_ADDR_WIDTH)
    ) fb (
        .write_clk(write_clk),
        .read_clk(vga_clk),
        .we(wr_en),
        .write_addr(wr_addr_internal),
        .data(wr_data),
        .read_addr(rd_addr_internal),
        .q(fb_data)
    );

    assign screen_h_coord = dat_act ? (hcount - HDAT_BEGIN) : 10'd0;
    assign screen_v_coord = dat_act ? (vcount - VDAT_BEGIN) : 10'd0;
    assign fb_access_h_idx = screen_h_coord / PIXEL_SCALING_FACTOR;
    assign fb_access_v_idx = screen_v_coord / PIXEL_SCALING_FACTOR;
    assign rd_addr_internal = (fb_access_v_idx * ACTUAL_FB_WIDTH) + fb_access_h_idx;

    initial begin
        vga_clk = 1'b0;
        hcount = 10'd0;
        vcount = 10'd0;
    end

    always @(posedge clock) begin
        vga_clk <= ~vga_clk;
    end

    always @(posedge vga_clk) begin
        if (hcount_ov) begin
            hcount <= 10'd0;
        end else begin
            hcount <= hcount + 10'd1;
        end
    end

    assign hcount_ov = (hcount == HPIXEL_END);

    always @(posedge vga_clk) begin
        if (hcount_ov) begin
            if (vcount_ov) begin
                vcount <= 10'd0;
            end else begin
                vcount <= vcount + 10'd1;
            end
        end
    end

    assign vcount_ov = (vcount == VLINE_END);
    assign dat_act = ((hcount >= HDAT_BEGIN) && (hcount < HDAT_END)) &&
                     ((vcount >= VDAT_BEGIN) && (vcount < VDAT_END));

    assign hsync = ~((hcount >= 10'd0) && (hcount < HSYNC_END));
    assign vsync = ~((vcount >= 10'd0) && (vcount < VSYNC_END));
    assign disp_rgb = dat_act ? fb_data : 3'b000;

    assign vga_clk_out = vga_clk;
    assign vga_sync_n  = 1'b0;
    assign vga_blank_n = ~((hcount < HDAT_BEGIN) | (hcount >= HDAT_END) |
                            (vcount < VDAT_BEGIN) | (vcount >= VDAT_END));
    assign vga_r = {8{disp_rgb[2]}};
    assign vga_g = {8{disp_rgb[1]}};
    assign vga_b = {8{disp_rgb[0]}};

endmodule
