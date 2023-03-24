create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_loopback_fifo
set_property -dict [list CONFIG.TDATA_NUM_BYTES {16} CONFIG.FIFO_DEPTH {512} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_loopback_fifo}] [get_ips axis_loopback_fifo]
