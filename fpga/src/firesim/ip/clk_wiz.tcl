# See LICENSE.md for license details

create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz

set_property -dict [list                         \
    CONFIG.PRIMARY_PORT               clk_in     \
    CONFIG.PRIM_IN_FREQ               250.000    \
    CONFIG.CLK_OUT1_PORT              clk_out    \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 40.000     \
    CONFIG.RESET_PORT                 rst_n      \
    CONFIG.RESET_TYPE                 ACTIVE_LOW \
    CONFIG.USE_LOCKED                 false      \
] [get_ips clk_wiz]

set_property generate_synth_checkpoint false [get_files \
    clk_wiz.srcs/sources_1/ip/clk_wiz/clk_wiz.xci       \
]
