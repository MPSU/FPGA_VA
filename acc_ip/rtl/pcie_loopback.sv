module pcie_loopback
#(parameter PCIE_WIDTH   = 8,
  parameter C_DATA_WIDTH = 128
)
(
  input  logic                  pcie_clk_p,
  input  logic                  pcie_clk_n,
  input  logic                  pcie_perst_ls,

  output logic [PCIE_WIDTH-1:0] pcie_txp,
  output logic [PCIE_WIDTH-1:0] pcie_txn,
  input  logic [PCIE_WIDTH-1:0] pcie_rxp,
  input  logic [PCIE_WIDTH-1:0] pcie_rxn
);


  // Clock & reset
  logic  pcie_ref_clk;
  logic  pcie_perst_ls_c;
  logic  axi_clk;

  logic  axi_resetn;

  // XDMA AXI streaming ports
  logic [C_DATA_WIDTH-  1:0] m_axis_h2c_tdata_0;
  logic                      m_axis_h2c_tlast_0;
  logic                      m_axis_h2c_tvalid_0;
  logic                      m_axis_h2c_tready_0;
  logic [C_DATA_WIDTH/8-1:0] m_axis_h2c_tkeep_0;
  logic [C_DATA_WIDTH  -1:0] s_axis_c2h_tdata_0;
  logic                      s_axis_c2h_tlast_0;
  logic                      s_axis_c2h_tvalid_0;
  logic                      s_axis_c2h_tready_0;
  logic [C_DATA_WIDTH/8-1:0] s_axis_c2h_tkeep_0;


  // Ref clock buffer
  IBUFDS_GTE2 i_refclk_ibuf (
    .I     (pcie_clk_p  ),
    .IB    (pcie_clk_n  ),
    .CEB   (1'b0        ),
    .O     (pcie_ref_clk),
    .ODIV2 (            )
  );


  // Reset buffer
  IBUF sys_reset_n_ibuf
  (
    .I (pcie_perst_ls  ),
    .O (pcie_perst_ls_c)
  );


  // Core Top Level Wrapper
  xdma_stream i_xdma
  (
    .sys_rst_n           (pcie_perst_ls_c    ),
    .sys_clk             (pcie_ref_clk       ),

    .pci_exp_txn         (pcie_txn           ),
    .pci_exp_txp         (pcie_txp           ),
    .pci_exp_rxn         (pcie_rxn           ),
    .pci_exp_rxp         (pcie_rxp           ),

    .s_axis_c2h_tdata_0  (s_axis_c2h_tdata_0 ),
    .s_axis_c2h_tlast_0  (s_axis_c2h_tlast_0 ),
    .s_axis_c2h_tvalid_0 (s_axis_c2h_tvalid_0),
    .s_axis_c2h_tready_0 (s_axis_c2h_tready_0),
    .s_axis_c2h_tkeep_0  (s_axis_c2h_tkeep_0 ),

    .m_axis_h2c_tdata_0  (m_axis_h2c_tdata_0 ),
    .m_axis_h2c_tlast_0  (m_axis_h2c_tlast_0 ),
    .m_axis_h2c_tvalid_0 (m_axis_h2c_tvalid_0),
    .m_axis_h2c_tready_0 (m_axis_h2c_tready_0),
    .m_axis_h2c_tkeep_0  (m_axis_h2c_tkeep_0 ),

    .usr_irq_req         ('0                 ),
    .usr_irq_ack         (                   ),
    .msi_enable          (                   ),
    .msi_vector_width    (                   ),

    .axi_aclk            (axi_clk            ),
    .axi_aresetn         (axi_resetn         ),
    .user_lnk_up         (                   )
  );


  // Loopback fifo
  axis_loopback_fifo i_fifo
  (
    .s_axis_aresetn (axi_resetn         ),
    .s_axis_aclk    (axi_clk            ),
    .s_axis_tvalid  (m_axis_h2c_tvalid_0),
    .s_axis_tready  (m_axis_h2c_tready_0),
    .s_axis_tdata   (m_axis_h2c_tdata_0 ),
    .s_axis_tkeep   (m_axis_h2c_tkeep_0 ),
    .s_axis_tlast   (m_axis_h2c_tlast_0 ),
    .m_axis_tvalid  (s_axis_c2h_tvalid_0),
    .m_axis_tready  (s_axis_c2h_tready_0),
    .m_axis_tdata   (s_axis_c2h_tdata_0 ),
    .m_axis_tkeep   (s_axis_c2h_tkeep_0 ),
    .m_axis_tlast   (s_axis_c2h_tlast_0 )
  );

endmodule
