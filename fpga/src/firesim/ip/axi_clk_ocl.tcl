create_ip -name axi_clock_converter -vendor xilinx.com -library ip -version 2.1 -module_name axi_clk_ocl

set_property -dict [list       \
    CONFIG.PROTOCOL   AXI4LITE \
    CONFIG.ADDR_WIDTH 32       \
    CONFIG.DATA_WIDTH 32       \
    CONFIG.ACLK_ASYNC 1        \
] [get_ips axi_clk_ocl]
