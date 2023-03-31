# a1 recipe
create_clock -period 4.0 -name clk_main_a0 -waveform {0.0 2.0} [get_ports clk_main_a0]

set_false_path -from [get_ports rst_main_n]
