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
    input  wire                    write_clk,
    input  wire                    read_clk,
    output reg  [(DATA_WIDTH-1):0] q
);

    localparam RAM_DEPTH = (1 << ADDR_WIDTH);
    reg [DATA_WIDTH-1:0] ram[0:RAM_DEPTH-1];

    // Inicializacao da memoria
    initial begin
        q = {DATA_WIDTH{1'b0}};
    end

    always @(posedge write_clk) begin
        if (we) begin
            ram[write_addr] <= data;
        end
    end

    always @(posedge read_clk) begin
        q <= ram[read_addr];
    end

endmodule
