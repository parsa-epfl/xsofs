# See LICENSE.md for license details

proc get_high_fanout_nets {top min {max 100000}} {
    # TODO: -cells doesn't work
    set out [split [report_high_fanout_nets         \
                        -fanout_greater_than ${min} \
                        -fanout_lesser_than  ${max} \
                        -max_nets            100000 \
                        -return_string] "\n"]
    set ret {}

    foreach o ${out} {
        if {[string match "| ${top}*" ${o}]} {
            set s [split ${o} "|"]
            set n [string trim [lindex ${s} 1]]
            set l [string trim [lindex ${s} 3]]

            if {[string match "RAM*" ${l}]} {
                continue
            }

            lappend ret ${n}
        }
    }

    return ${ret}
}


set HDK $::env(HDK)
set TOP [lindex ${argv} 0]
set DCP [lindex ${argv} 1]

source ../run.tcl

# wait for the TOP to appear
appear ${TOP}

add_files -norecurse [list                                \
    ${TOP}                                                \
    ${HDK}/build/checkpoints/from_aws/SH_CL_BB_routed.dcp \
]

set_property SCOPED_TO_CELLS {WRAPPER_INST/CL} [get_files ${TOP}]

if {$::env(PBLOCK) == {yes}} {
    read_xdc ../pnr.xdc
    set_property PROCESSING_ORDER late [get_files ../pnr.xdc]
}

link_design                      \
    -top                  top_sp \
    -reconfig_partitions {WRAPPER_INST/SH WRAPPER_ISNT/CL}

# promote high-fanout resets to global routing
# https://docs.xilinx.com/r/en-US/ug949-vivado-design-methodology/Promote-High-Fanout-Nets-to-Global-Routing
report_high_fanout_nets -fanout_greater_than 500 -max_nets 100000

set nets [list                                                \
    [get_high_fanout_nets WRAPPER_INST/CL/u_dut/top/sim 1145] \
    [get_high_fanout_nets WRAPPER_INST/CL/u_dut/top/sim/target/Dut_/u_top/core_with_l2*/core/memBlock/dcache/dcache/mainPipe 830 845] \
    [get_high_fanout_nets WRAPPER_INST/CL/u_dut/top/sim/target/Dut_/u_top/core_with_l2*/core/memBlock/dcache/dcache/mainPipe 730 760] \
]

foreach s ${nets} {
    foreach n ${s} {
        puts "marking BUFG on ${n}"

        set_property CLOCK_BUFFER_TYPE BUFG [get_nets ${n}]
    }
}

# recipe a1
set clk_inst WRAPPER_INST/SH/kernel_clks_i/clkwiz_sys_clk/inst/CLK_CORE_DRP_I/clk_inst

set_property -dict [list \
    CLKFBOUT_MULT_F  6   \
    DIVCLK_DIVIDE    1   \
    CLKOUT0_DIVIDE_F 6   \
    CLKOUT1_DIVIDE   12  \
    CLKOUT2_DIVIDE   4   \
    CLKOUT3_DIVIDE   3   \
] [get_cells ${clk_inst}/mmcme3_adv_inst]

# highly discouraged but fine
# https://repost.aws/questions/QUuep9IsqQRBilAEXD63ZY_A/use-a-mmcm-to-generate-arbitrary-frequencies-in-cl
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets ${clk_inst}/clk_out1]

# contain the unused clk in a single clock region
# https://repost.aws/questions/QUtcHFRAQRT4mC0bXSBtmCAA/the-clock-nets-need-to-use-the-same-clock-routing-resource
set_property CLOCK_LOW_FANOUT TRUE [get_nets ${clk_inst}/clk_out2]

opt_design
report opt

place_design -directive $::env(DIR_PLACE)
report place

route_design -directive $::env(DIR_ROUTE)

# cdc
set_false_path -to [get_cells WRAPPER_INST/CL/flr_q_reg*]
set_false_path -to [get_cells WRAPPER_INST/CL/rst_cl_q_reg*]

write_checkpoint -force          ${DCP}
write_checkpoint -force -encrypt ${DCP}.encrypted
report route no no
