create_ip -name xdma -vendor xilinx.com -library ip -version 4.1 -module_name xdma_stream

# initial pcie 2.0 x8
set_property -dict [list CONFIG.Component_Name {xdma_stream} CONFIG.pl_link_cap_max_link_width {X8} CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} CONFIG.axi_data_width {128_bit} CONFIG.axisten_freq {250} CONFIG.pf0_device_id {7028} CONFIG.plltype {QPLL1} CONFIG.xdma_axi_intf_mm {AXI_Stream} CONFIG.cfg_mgmt_if {false} CONFIG.PF0_DEVICE_ID_mqdma {9028} CONFIG.PF2_DEVICE_ID_mqdma {9228} CONFIG.PF3_DEVICE_ID_mqdma {9328} CONFIG.PF0_SRIOV_VF_DEVICE_ID {A038} CONFIG.PF1_SRIOV_VF_DEVICE_ID {A138} CONFIG.PF2_SRIOV_VF_DEVICE_ID {A238} CONFIG.PF3_SRIOV_VF_DEVICE_ID {A338}] [get_ips xdma_stream]

# set to pcie 1.0 x8
set_property -dict [list CONFIG.pl_link_cap_max_link_width {X8} CONFIG.pl_link_cap_max_link_speed {2.5_GT/s} CONFIG.axi_data_width {128_bit} CONFIG.axisten_freq {125} CONFIG.pf0_device_id {7018} CONFIG.plltype {CPLL} CONFIG.PF0_DEVICE_ID_mqdma {9018} CONFIG.PF2_DEVICE_ID_mqdma {9218} CONFIG.PF3_DEVICE_ID_mqdma {9318} CONFIG.PF0_SRIOV_VF_DEVICE_ID {A038} CONFIG.PF1_SRIOV_VF_DEVICE_ID {A138} CONFIG.PF2_SRIOV_VF_DEVICE_ID {A238} CONFIG.PF3_SRIOV_VF_DEVICE_ID {A338}] [get_ips xdma_stream]
