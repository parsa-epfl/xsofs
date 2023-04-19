# See LICENSE.md for license details

# core 0
create_pblock pblock_c0

add_cells_to_pblock [get_pblocks pblock_c0] [get_cells           \
    WRAPPER_INST/CL/u_dut/top/sim/target/Dut_/u_top/core_with_l2 \
]
resize_pblock [get_pblocks pblock_c0] -add {CLOCKREGION_X0Y0:CLOCKREGION_X2Y9}
resize_pblock [get_pblocks pblock_c0] -add {SLICE_X88Y0:SLICE_X107Y599}
resize_pblock [get_pblocks pblock_c0] -add {LAGUNA_X12Y0:LAGUNA_X15Y479}
resize_pblock [get_pblocks pblock_c0] -add {RAMB18_X7Y0:RAMB18_X7Y239}
resize_pblock [get_pblocks pblock_c0] -add {RAMB36_X7Y0:RAMB36_X7Y119}
resize_pblock [get_pblocks pblock_c0] -add {URAM288_X2Y0:URAM288_X2Y159}
resize_pblock [get_pblocks pblock_c0] -add {DSP48E2_X11Y0:DSP48E2_X13Y239}

set_property -dict [list        \
    EXCLUDE_PLACEMENT FALSE     \
    CONTAIN_ROUTING   TRUE      \
    SNAPPING_MODE     ON        \
    PARENT            pblock_CL \
] [get_pblocks pblock_c0]

# core 1
create_pblock pblock_c1

add_cells_to_pblock [get_pblocks pblock_c1] [get_cells             \
    WRAPPER_INST/CL/u_dut/top/sim/target/Dut_/u_top/core_with_l2_1 \
]
resize_pblock [get_pblocks pblock_c1] -add {CLOCKREGION_X0Y10:CLOCKREGION_X5Y14}

set_property -dict [list        \
    EXCLUDE_PLACEMENT FALSE     \
    CONTAIN_ROUTING   TRUE      \
    SNAPPING_MODE     ON        \
    PARENT            pblock_CL \
] [get_pblocks pblock_c1]
