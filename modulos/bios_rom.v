module bios_rom
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8,
    parameter INIT_FILE = "bios_init.txt"
)(
    input  [(ADDR_WIDTH-1):0] addr,
    input                     clk,
    output reg [(DATA_WIDTH-1):0] q
);

    // BIOS armazenada em memória ROM dedicada
    reg [DATA_WIDTH-1:0] rom [0:(1<<ADDR_WIDTH)-1];

    initial begin
        $readmemb(INIT_FILE, rom);
    end

    always @(*) begin
        q <= rom[addr];
    end

endmodule