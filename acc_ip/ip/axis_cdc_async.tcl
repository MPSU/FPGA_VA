create_ip -name axis_clock_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_cdc_async
set_property -dict [list CONFIG.TDATA_NUM_BYTES {16} CONFIG.IS_ACLK_ASYNC {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_cdc_async}] [get_ips axis_cdc_async]
