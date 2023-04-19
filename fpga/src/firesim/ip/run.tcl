# See LICENSE.md for license details

set name [lindex ${argv} 0]

create_project ${name} . -force -part xcvu9p-flgb2104-2-i

if {[file exist ../${name}.tcl]} {
    source ../${name}.tcl
} else {
    puts "ERROR: invalid IP: ${name}"
    exit
}

set xci ${name}.srcs/sources_1/ip/${name}/${name}.xci

generate_target all [get_files ${xci}]

export_ip_user_files -of_objects [get_files ${xci}] -no_script -sync -force -quiet

if {[get_property generate_synth_checkpoint [get_files ${xci}]]} {
    create_ip_run [get_files ${xci}]

    launch_runs ${name}_synth_1
    wait_on_run ${name}_synth_1
}
