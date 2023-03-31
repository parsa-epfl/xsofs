proc report {step {dcp {yes}} {syn {yes}}} {
    if {${dcp} == {yes}} {
        write_checkpoint -force ${step}.dcp
    }

    if {${syn} == {yes}} {
        report_timing -delay_type max -max_paths 10 -sort_by group -input_pins -file ${step}.timing.max.rpt
        report_timing -delay_type min -max_paths 10 -sort_by group -input_pins -file ${step}.timing.min.rpt
        report_utilization                                                     -file ${step}.util.rpt
    } else {
        report_timing -cells WRAPPER_INST/CL -delay_type max -max_paths 10 -sort_by group -input_pins -file ${step}.timing.max.rpt
        report_timing -cells WRAPPER_INST/CL -delay_type min -max_paths 10 -sort_by group -input_pins -file ${step}.timing.min.rpt
        report_utilization -pblock [get_pblocks pblock_CL]                                            -file ${step}.util.rpt
    }

    report_timing_summary -file ${step}.timing.sum.rpt
    report_route_status   -file ${step}.route.rpt
}

proc appear {file {timeout 240}} {
    set wait 0

    for {set i 0} {${i} < ${timeout}} {incr i} {
        if {[file exists ${file}]} {
            break
        }

        puts "waiting..."
        after 60000

        set wait 1
    }

    if {![file exists ${file}]} {
        puts "ERROR: ${file} does not show up, existing..."
        exit
    }

    if {${wait} == 1} {
        # wait for another 3 min so that the file is correct
        after 180000
    }
}


puts "Directives:"
puts "  synth:  $::env(DIR_SYNTH)"
puts "  place:  $::env(DIR_PLACE)"
puts "  route:  $::env(DIR_ROUTE)"
puts "  pblock: $::env(PBLOCK)"


create_project -part xcvu9p-flgb2104-2-i -in_memory

set_param general.maxThreads                                  12

set_param hd.clockRoutingWireReduction                        false
set_param hd.supportClockNetCrossDiffReconfigurablePartitions 1
set_param project.replaceDontTouchWithKeepHierarchySoft       false
set_param sta.enableAutoGenClkNamePersistence                 0
