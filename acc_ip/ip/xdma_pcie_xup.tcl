create_ip -name xdma -vendor xilinx.com -library ip -version 4.1 -module_name xdma_stream

## pcie 1.0 x8 initial config
set_property -dict [list CONFIG.Component_Name {xdma_stream} CONFIG.pl_link_cap_max_link_width {X8} CONFIG.axi_data_width {128_bit} CONFIG.axisten_freq {125} CONFIG.pf0_device_id {9018} CONFIG.xdma_axi_intf_mm {AXI_Stream} CONFIG.cfg_mgmt_if {false} CONFIG.PF0_DEVICE_ID_mqdma {9018} CONFIG.PF2_DEVICE_ID_mqdma {9218} CONFIG.PF3_DEVICE_ID_mqdma {9318} CONFIG.PF0_SRIOV_VF_DEVICE_ID {A038} CONFIG.PF1_SRIOV_VF_DEVICE_ID {A138} CONFIG.PF2_SRIOV_VF_DEVICE_ID {A238} CONFIG.PF3_SRIOV_VF_DEVICE_ID {A338}] [get_ips xdma_stream]

## pcie 2.0 x8 additional config
set_property -dict [list CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} CONFIG.axisten_freq {250} CONFIG.pf0_device_id {9028} CONFIG.plltype {QPLL1} CONFIG.PF0_DEVICE_ID_mqdma {9028} CONFIG.PF2_DEVICE_ID_mqdma {9228} CONFIG.PF3_DEVICE_ID_mqdma {9328}] [get_ips xdma_stream]

## pcie 3.0 x8 additional config
set_property -dict [list CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} CONFIG.axi_data_width {256_bit} CONFIG.pf0_device_id {9038} CONFIG.coreclk_freq {500} CONFIG.PF0_DEVICE_ID_mqdma {9038} CONFIG.PF2_DEVICE_ID_mqdma {9238} CONFIG.PF3_DEVICE_ID_mqdma {9338}] [get_ips xdma_stream]
