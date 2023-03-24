create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name mmcm_dut
set_property -dict [list CONFIG.PRIM_IN_FREQ {125.000} CONFIG.USE_SAFE_CLOCK_STARTUP {true} CONFIG.CLKIN1_JITTER_PS {80.0} CONFIG.CLKOUT1_DRIVES {BUFGCE} CONFIG.CLKOUT2_DRIVES {BUFGCE} CONFIG.CLKOUT3_DRIVES {BUFGCE} CONFIG.CLKOUT4_DRIVES {BUFGCE} CONFIG.CLKOUT5_DRIVES {BUFGCE} CONFIG.CLKOUT6_DRIVES {BUFGCE} CONFIG.CLKOUT7_DRIVES {BUFGCE} CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} CONFIG.MMCM_CLKIN1_PERIOD {8.000} CONFIG.CLKOUT1_JITTER {124.615} CONFIG.CLKOUT1_PHASE_ERROR {96.948}] [get_ips mmcm_dut]
set_property -dict [list CONFIG.PRIM_SOURCE {Global_buffer}] [get_ips mmcm_dut]