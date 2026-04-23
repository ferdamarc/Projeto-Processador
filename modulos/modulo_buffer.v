module framebuffer
#(
    parameter DATA_WIDTH = 3,
    parameter ADDR_WIDTH = 17
)
(
    input  wire [(DATA_WIDTH-1):0] data,
    input  wire [(ADDR_WIDTH-1):0] read_addr,
    input  wire [(ADDR_WIDTH-1):0] write_addr,
    input  wire                    we,
    input  wire                    clk,
    output reg  [(DATA_WIDTH-1):0] q
);

    localparam RAM_DEPTH = (1 << ADDR_WIDTH);
    reg [DATA_WIDTH-1:0] ram[0:RAM_DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < RAM_DEPTH; i = i + 1) begin
            ram[i] = {DATA_WIDTH{1'b0}};
        end
        q = {DATA_WIDTH{1'b0}};
    end

    always @(posedge clk) begin
        if (we) begin
            ram[write_addr] <= data;
        end
        q <= ram[read_addr];
    end

endmodule
