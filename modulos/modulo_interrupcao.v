module modulo_interrupcao
#(
  parameter ADDR_WIDTH = 13                       // Largura do endereço do PC
)
(
  // Entradas
  input                    halt,                  // Sinal de parada do processo
  input                    clk,                   // Clock do sistema
  input                    set,                   // Sinal para configurar o tempo de interrupção
  input  [ADDR_WIDTH-1:0]  pc,                    // Program Counter atual
  input  [15:0]            int_time,              // Tempo de interrupção (quantum)
  
  // Saídas
  output reg               int_halt,              // Interrupção por HALT
  output reg               int_clk                // Interrupção por timer
);

  // Registradores internos
  reg [15:0] timer;                               // Timer para interrupção (16 bits)
  reg [15:0] reg_int_time;                        // Registrador para o tempo de interrupção
  reg        start;                               // Controla se o timer está ativo
  
  // Inicialização
  initial begin
    timer = 16'd0;
    start = 1'b0;
    int_clk = 1'b0;
    int_halt = 1'b0;
  end
  
  // Timer de quantum para Round Robin com preempção
  // - Após set, conta até int_time e gera int_clk=1
  // - Timer para automaticamente após expirar (não é periódico)
  // - SO deve chamar set_interr_timer novamente antes de cada os_jump_to
  always @(negedge clk) begin
    // Configuração do timer
    if (set) begin
      timer <= 16'd0;
      start <= 1'b1;
      reg_int_time <= int_time;
    end
    
    // Contagem do timer (modo quantum único)
    if (start) begin
      timer <= timer + 16'd1;
      if (timer >= reg_int_time) begin
        int_clk <= 1'b1;                          // Ativa interrupção por 1 ciclo
        timer <= 16'd0;                           // Reseta contador
        start <= 1'b0;                            // Desliga timer após interrupção
      end
    end else begin
      int_clk <= 1'b0;
      timer <= 16'd0;
    end
    
    // Interrupção por halt (desliga o timer imediatamente)
    if (halt) begin
      int_halt <= 1'b1;
      start <= 1'b0;                              // Halt desliga o timer
    end else begin
      int_halt <= 1'b0;
    end
  end

endmodule


