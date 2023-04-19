# See LICENSE.md for license details

set SRC $::env(SRC)
set HDK $::env(HDK)
set DUT [lindex ${argv} 0]
set TOP [lindex ${argv} 1]

source ../run.tcl

add_files -norecurse [list                 \
    ../top.sv                              \
    ${DUT}                                 \
    ${SRC}/SPSRAM.sv                       \
    ${SRC}/DPSRAM.sv                       \
    ${HDK}/design/lib/lib_pipe.sv          \
    ${HDK}/design/sh_ddr/synth/ccf_ctl.v   \
    ${HDK}/design/sh_ddr/synth/flop_ccf.sv \
    ${HDK}/design/sh_ddr/synth/sh_ddr.sv   \
    ${HDK}/design/sh_ddr/synth/sync.v      \
]

foreach ip [list    \
    clk_wiz         \
    axi_clk_ocl     \
    axi_clk_dma     \
    axi_clk_mem     \
] {
    set xci ../ip/${ip}/${ip}.srcs/sources_1/ip/${ip}/${ip}.xci
    add_files -norecurse ${xci}

    # disable the xdc from clk_wiz
    # see: https://docs.xilinx.com/r/en-US/ug939-vivado-designing-with-ip-tutorial/Step-5-Disable-the-IP-XDC-Files
    if {${ip} == {clk_wiz}} {
        set xdc [get_files -of_objects [get_files ${xci}] -filter {FILE_TYPE == XDC}]
        set_property is_enabled false  [get_files ${xdc}]
    }
}

foreach ip [list    \
    cl_debug_bridge \
] {
    add_files -norecurse ${HDK}/design/ip/${ip}/${ip}.xci
}

add_files -fileset constrs_1 -norecurse [list \
    ../top.xdc                                \
    ${HDK}/build/constraints/cl_ddr.xdc       \
    ${HDK}/build/constraints/cl_synth_aws.xdc \
]

set_property -dict [list                              \
    PROCESSING_ORDER EARLY                            \
    USED_IN {synthesis implementation OUT_OF_CONTEXT} \
] [get_files ../top.xdc]

update_compile_order -fileset sources_1

synth_design                               \
    -include_dirs ${HDK}/design/interfaces \
    -top          top                      \
    -mode         out_of_context           \
    -directive    $::env(DIR_SYNTH)
write_checkpoint -force ${TOP}
report synth no yes
