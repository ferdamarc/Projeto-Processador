module unidade_pc_output(
    input [10:0] PC,                 // PC de 11 bits para compatibilidade com CPU.v
    input clock, 
    input reset,                     // Sinal de reset para inicialização adequada
    output [6:0] DisplayPC_Unidade,  // Display das unidades (0-9)
    output [6:0] DisplayPC_Dezena    // Display das dezenas (0-9)
);

    reg [3:0] auxDisplayUnidade;
    reg [3:0] auxDisplayDezena;
    
    // Lógica simples para conversão decimal
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            auxDisplayUnidade <= 4'd0;
            auxDisplayDezena <= 4'd0;
        end
        else begin
            // Unidades: PC % 10 (truncado para 4 bits)
            auxDisplayUnidade <= PC % 10;
            // Dezenas: (PC / 10) % 10 (truncado para 4 bits)
            auxDisplayDezena <= (PC / 10) % 10;
        end
    end

    // Instanciar os displays de 7 segmentos usando o módulo correto
    display_7segmentos displayUnidade (.bcd(auxDisplayUnidade), .seg(DisplayPC_Unidade));
    display_7segmentos displayDezena (.bcd(auxDisplayDezena), .seg(DisplayPC_Dezena));

endmodule