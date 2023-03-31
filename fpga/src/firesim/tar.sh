#!/bin/bash

set -e

hash=($(sha256sum ${1}.encrypted))
time=($(date +"%y_%m_%d-%H%M%S"))

ln -s ${1}.encrypted ${time}.${1}

cat << EOF > ${time}.manifest.txt
manifest_format_version=2
pci_vendor_id=0x1D0F
pci_device_id=0xF000
pci_subsystem_id=0x1D51
pci_subsystem_vendor_id=0xFEDD
dcp_hash=${hash}
shell_version=0x04261818
dcp_file_name=${time}.${1}
hdk_version=1.4.24
tool_version=v2020.2
date=${time}
clock_recipe_a=A1
clock_recipe_b=B0
clock_recipe_c=C0
EOF

tar chf ${2}             \
    ${time}.manifest.txt \
    ${time}.${1}

rm -rf                   \
    ${time}.manifest.txt \
    ${time}.${1}
