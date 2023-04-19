# See LICENSE.md for license details

create_ip -name axi_clock_converter -vendor xilinx.com -library ip -version 2.1 -module_name axi_clk_dma

set_property -dict [list  \
    CONFIG.ADDR_WIDTH 64  \
    CONFIG.DATA_WIDTH 512 \
    CONFIG.ID_WIDTH   6   \
    CONFIG.ACLK_ASYNC 1   \
] [get_ips axi_clk_dma]
