# Restrição para o clock principal de 50MHz da placa DE2-115
# Assumindo que a porta de entrada do clock no seu módulo de topo se chama entrada_clock
create_clock -name {CLK_50M} -period 20.0 [get_ports {entrada_clock}]

# Deriva automaticamente outros clocks (se o Quartus os inferir de PLLs ou divisores)
derive_pll_clocks
derive_clock_uncertainty