module vip_example_wrapper #(
  parameter PL_LINK_CAP_MAX_LINK_WIDTH = 8,
  parameter C_DATA_WIDTH               = 64,
  parameter XDMA_TRANSFER_SIZE_OUT     = 64,
  parameter XDMA_TRANSFER_SIZE_IN      = 128
) (
  output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txp,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txn,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_rxp,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_rxn,

  input                                         sys_clk_p,
  input                                         sys_clk_n,
  input                                         sys_rst_n
);

  // Clock & reset
  logic  sys_clk;
  logic  sys_rst_n_c;
  logic  axi_clk;
  logic  axi_resetn;

  // XDMA AXI streaming ports
  logic [C_DATA_WIDTH-1:0]    m_axis_h2c_tdata_0;
  logic                       m_axis_h2c_tlast_0;
  logic                       m_axis_h2c_tvalid_0;
  logic                       m_axis_h2c_tready_0;
  logic [C_DATA_WIDTH/8-1:0]  m_axis_h2c_tkeep_0;
  logic [C_DATA_WIDTH-1:0]    s_axis_c2h_tdata_0;
  logic                       s_axis_c2h_tlast_0;
  logic                       s_axis_c2h_tvalid_0;
  logic                       s_axis_c2h_tready_0;
  logic [C_DATA_WIDTH/8-1:0]  s_axis_c2h_tkeep_0;

  // VIP ports
  logic                    vip_clk;

  logic [XDMA_TRANSFER_SIZE_OUT-1:0] vip_data_out;
  logic [XDMA_TRANSFER_SIZE_IN -1:0] vip_data_in;

  // Ref clock buffer
  IBUFDS_GTE2 refclk_ibuf (
    .I     ( sys_clk_p ),
    .IB    ( sys_clk_n ),
    .CEB   ( 1'b0      ),
    .O     ( sys_clk   ),
    .ODIV2 (           )
  );

  // Reset buffer
  IBUF sys_reset_n_ibuf (
    .I ( sys_rst_n   ),
    .O ( sys_rst_n_c )
  );


  //// Core Top Level Wrapper

  xdma_stream xdma_inst (
    .sys_rst_n           ( sys_rst_n_c         ),
    .sys_clk             ( sys_clk             ),

    .pci_exp_txn         ( pci_exp_txn         ),
    .pci_exp_txp         ( pci_exp_txp         ),
    .pci_exp_rxn         ( pci_exp_rxn         ),
    .pci_exp_rxp         ( pci_exp_rxp         ),

    .s_axis_c2h_tdata_0  ( s_axis_c2h_tdata_0  ),
    .s_axis_c2h_tlast_0  ( s_axis_c2h_tlast_0  ),
    .s_axis_c2h_tvalid_0 ( s_axis_c2h_tvalid_0 ),
    .s_axis_c2h_tready_0 ( s_axis_c2h_tready_0 ),
    .s_axis_c2h_tkeep_0  ( s_axis_c2h_tkeep_0  ),

    .m_axis_h2c_tdata_0  ( m_axis_h2c_tdata_0  ),
    .m_axis_h2c_tlast_0  ( m_axis_h2c_tlast_0  ),
    .m_axis_h2c_tvalid_0 ( m_axis_h2c_tvalid_0 ),
    .m_axis_h2c_tready_0 ( m_axis_h2c_tready_0 ),
    .m_axis_h2c_tkeep_0  ( m_axis_h2c_tkeep_0  ),

    .usr_irq_req         ( '0                  ),
    .usr_irq_ack         (                     ),
    .msi_enable          (                     ),
    .msi_vector_width    (                     ),

    .axi_aclk            ( axi_clk             ),
    .axi_aresetn         ( axi_resetn          ),
    .user_lnk_up         (                     )
  );

  //// VIP instance

  vip_axis #(
    .C_DATA_WIDTH           ( C_DATA_WIDTH            ),
    .XDMA_TRANSFER_SIZE_IN  ( XDMA_TRANSFER_SIZE_IN   ),
    .XDMA_TRANSFER_SIZE_OUT ( XDMA_TRANSFER_SIZE_OUT  )
  ) vip_inst(
    .axi_clk              ( axi_clk             ),
    .axi_aresetn          ( axi_resetn          ),
    .m_axis_c2h_tdata_0   ( s_axis_c2h_tdata_0  ),
    .m_axis_c2h_tlast_0   ( s_axis_c2h_tlast_0  ),
    .m_axis_c2h_tvalid_0  ( s_axis_c2h_tvalid_0 ),
    .m_axis_c2h_tready_0  ( s_axis_c2h_tready_0 ),
    .m_axis_c2h_tkeep_0   ( s_axis_c2h_tkeep_0  ),
    .s_axis_h2c_tdata_0   ( m_axis_h2c_tdata_0  ),
    .s_axis_h2c_tlast_0   ( m_axis_h2c_tlast_0  ),
    .s_axis_h2c_tvalid_0  ( m_axis_h2c_tvalid_0 ),
    .s_axis_h2c_tready_0  ( m_axis_h2c_tready_0 ),
    .s_axis_h2c_tkeep_0   ( m_axis_h2c_tkeep_0  ),
    .vip_clk              ( vip_clk             ),
    .vip_data_out         ( vip_data_out        ),
    .vip_data_in          ( vip_data_in         )
  );

  //// DUT & port asignments

  // gated clock
  assign ss_clk      = vip_clk;

  axi_s_cordic_abs DUT (
    // stream slave signals
    .ss_clk_i      ( ss_clk               ),
    .ss_aresetn_i  ( vip_data_in[69]      ),
    .ss_tvalid_i   ( vip_data_in[68]      ),
    .ss_tlast_i    ( vip_data_in[67]      ),
    .ss_tid_i      ( vip_data_in[66-:2]   ),
    .ss_tdata_re_i ( vip_data_in[64-:32]  ),
    .ss_tdata_im_i ( vip_data_in[32-:32]  ),
    .sm_tready_i   ( vip_data_in[0]       ),

    // stream master signals
    //.sm_clk_o     ( ),
    .sm_aresetn_o  ( vip_data_out[37]     ),
    .sm_tvalid_o   ( vip_data_out[36]     ),
    .sm_tlast_o    ( vip_data_out[35]     ),
    .sm_tid_o      ( vip_data_out[34-:2]  ),
    .sm_tdata_o    ( vip_data_out[32-:32] ),
    .ss_tready_o   ( vip_data_out[0]      )
);

//    ila_abs(
//      .clk     ( axi_clk     ),
//      .probe0  ( ss_tdata_re ),
//      .probe1  ( ss_tdata_im ),
//      .probe2  ( ss_tid      ),
//      .probe3  ( ss_tlast    ),
//      .probe4  ( ss_aresetn  ),
//      .probe5  ( ss_tvalid   ),
//      .probe6  ( ss_tready   ),
//      .probe7  ( ),
//      .probe8  ( sm_tdata    ),
//      .probe9  ( ),
//      .probe10 ( sm_tid      ),
//      .probe11 ( sm_tlast    ),
//      .probe12 ( sm_aresetn  ),
//      .probe13 ( sm_tvalid   ),
//      .probe14 ( sm_tready   ),
//      .probe15 ( )
//    );

endmodule