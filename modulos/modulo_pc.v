module modulo_pc 
#(
	parameter ADDR_WIDTH = 13  // Largura do endereço (padrão: 13 bits = 8192 posições)
)
(
	input wire Clock, PCFunct,
	input wire [ADDR_WIDTH-1:0] InstrucaoModificada,
	input wire halt, // Entrada para HALT
	input wire loop_enable, // Switch para controle de loop
	output wire [ADDR_WIDTH-1:0] Instrucao
);

	reg [ADDR_WIDTH-1:0] InstrucaoAtual;
	reg program_finished; // Flag para indicar que programa terminou
	integer primeiro = 1;
	
	initial begin
		/*
			Iniciar o PC com o valor 0 decimal
			(Primeira instrução)
		*/
		InstrucaoAtual = {ADDR_WIDTH{1'b0}};
		program_finished = 1'b0;
	
	end
	
	always @(posedge Clock) 
	begin	
		// Controle de execução baseado no estado de HALT e LOOP
		if (!halt) begin
			// Execução normal - não está em HALT
			if (primeiro != 1) begin
				InstrucaoAtual = InstrucaoModificada;	
			end
			else if(primeiro) begin
				primeiro = 0;	
				InstrucaoAtual = {ADDR_WIDTH{1'b0}};
				program_finished = 1'b0;
			end
		end
		else begin
			// Estado de HALT - verifica configuração de loop
			if (loop_enable) begin
				// Loop habilitado: reinicia programa do início
				InstrucaoAtual = {ADDR_WIDTH{1'b0}};
				program_finished = 1'b0;
				primeiro = 0; // Reset da flag de primeiro
			end else begin
				// Loop desabilitado: para a execução
				program_finished = 1'b1;
				// InstrucaoAtual mantém valor atual (execução parada)
			end
		end
	
	end
	
	// Envia o valor para a memória de instrução
	assign Instrucao = InstrucaoAtual; 

endmodule 

