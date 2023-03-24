module pcie_vip_wrapper
#(
  parameter PCIE_WIDTH         = 8,
  parameter C_DATA_WIDTH       = 128,
  parameter VIP2DUT_WORDS_NUM  = 1,
  parameter DUT2VIP_WORDS_NUM  = 1
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

  // Local declarations

  localparam VIP2DUT_WIDTH = C_DATA_WIDTH * VIP2DUT_WORDS_NUM;
  localparam DUT2VIP_WIDTH = C_DATA_WIDTH * DUT2VIP_WORDS_NUM;

  // Clock & reset
  logic                      pcie_ref_clk;
  logic                      pcie_perst_ls_c;

  logic                      xdma_clk;
  logic                      xdma_resetn;

  logic                      dut_clk;
  logic                      dut_resetn;

  // XDMA AXI streaming ports
  logic [C_DATA_WIDTH  -1:0] xdma2cdc_tdata;
  logic                      xdma2cdc_tlast;
  logic                      xdma2cdc_tvalid;
  logic                      xdma2cdc_tready;
  logic [C_DATA_WIDTH/8-1:0] xdma2cdc_tkeep;


  logic [C_DATA_WIDTH  -1:0] cdc2probe_tdata;
  logic                      cdc2probe_tlast;
  logic                      cdc2probe_tvalid;
  logic                      cdc2probe_tready;
  logic [C_DATA_WIDTH/8-1:0] cdc2probe_tkeep;


  logic [C_DATA_WIDTH  -1:0] probe2cdc_tdata;
  logic                      probe2cdc_tlast;
  logic                      probe2cdc_tvalid;
  logic                      probe2cdc_tready;
  logic [C_DATA_WIDTH/8-1:0] probe2cdc_tkeep;


  logic [C_DATA_WIDTH  -1:0] cdc2xdma_tdata;
  logic                      cdc2xdma_tlast;
  logic                      cdc2xdma_tvalid;
  logic                      cdc2xdma_tready;
  logic [C_DATA_WIDTH/8-1:0] cdc2xdma_tkeep;

  logic                      probe_bad_packet;

  logic                      vip2dut_clk;
  logic [VIP2DUT_WIDTH -1:0] vip2dut_bus;
  logic [DUT2VIP_WIDTH -1:0] dut2vip_bus;


  // Ref clock buffer
  IBUFDS_GTE2 i_refclk_ibuf
  (
    .I     (pcie_clk_p  ),
    .IB    (pcie_clk_n  ),
    .CEB   ('0          ),
    .O     (pcie_ref_clk),
    .ODIV2 (            )
  );


  // Reset buffer
  IBUF i_sys_reset_n_ibuf
  (
    .I (pcie_perst_ls  ),
    .O (pcie_perst_ls_c)
  );


  // Core Top Level Wrapper
  xdma_stream i_xdma
  (
    .sys_rst_n           (pcie_perst_ls_c),
    .sys_clk             (pcie_ref_clk   ),

    .pci_exp_txn         (pcie_txn       ),
    .pci_exp_txp         (pcie_txp       ),
    .pci_exp_rxn         (pcie_rxn       ),
    .pci_exp_rxp         (pcie_rxp       ),

    .s_axis_c2h_tdata_0  (cdc2xdma_tdata ),
    .s_axis_c2h_tlast_0  (cdc2xdma_tlast ),
    .s_axis_c2h_tvalid_0 (cdc2xdma_tvalid),
    .s_axis_c2h_tready_0 (cdc2xdma_tready),
    .s_axis_c2h_tkeep_0  (cdc2xdma_tkeep ),

    .m_axis_h2c_tdata_0  (xdma2cdc_tdata ),
    .m_axis_h2c_tlast_0  (xdma2cdc_tlast ),
    .m_axis_h2c_tvalid_0 (xdma2cdc_tvalid),
    .m_axis_h2c_tready_0 (xdma2cdc_tready),
    .m_axis_h2c_tkeep_0  (xdma2cdc_tkeep ),

    .usr_irq_req         ('0             ),
    .usr_irq_ack         (               ),
    .msi_enable          (               ),
    .msi_vector_width    (               ),

    .axi_aclk            (xdma_clk       ),
    .axi_aresetn         (xdma_resetn    ),
    .user_lnk_up         (               )
  );



  // PLL to divide xdma_clk
  mmcm_dut i_mmcm_dut
  (
    .reset    ('0      ),
    .clk_in1  (xdma_clk),
    .clk_out1 (dut_clk ),
    .locked   (        )
  );

  assign dut_resetn = xdma_resetn;


  // pcie to VIP CDC
  axis_cdc_async i_cdc_xdma2probe
  (
    .s_axis_aresetn (xdma_resetn     ),
    .s_axis_aclk    (xdma_clk        ),
    .s_axis_tvalid  (xdma2cdc_tvalid ),
    .s_axis_tready  (xdma2cdc_tready ),
    .s_axis_tdata   (xdma2cdc_tdata  ),
    .s_axis_tkeep   (xdma2cdc_tkeep  ),
    .s_axis_tlast   (xdma2cdc_tlast  ),

    .m_axis_aresetn (dut_resetn      ),
    .m_axis_aclk    (dut_clk         ),
    .m_axis_tvalid  (cdc2probe_tvalid),
    .m_axis_tready  (cdc2probe_tready),
    .m_axis_tdata   (cdc2probe_tdata ),
    .m_axis_tkeep   (cdc2probe_tkeep ),
    .m_axis_tlast   (cdc2probe_tlast )
  );


  // VIP probe
  axis_probe
  #(
    .C_DATA_WIDTH      (C_DATA_WIDTH     ),
    .VIP2DUT_WORDS_NUM (VIP2DUT_WORDS_NUM),
    .DUT2VIP_WORDS_NUM (DUT2VIP_WORDS_NUM)
  )
  i_axis_probe
  (
    .s_axis_aresetn    (dut_resetn      ),
    .s_axis_aclk       (dut_clk         ),

    .s_axis_tvalid     (cdc2probe_tvalid),
    .s_axis_tready     (cdc2probe_tready),
    .s_axis_tdata      (cdc2probe_tdata ),
    .s_axis_tkeep      (cdc2probe_tkeep ),
    .s_axis_tlast      (cdc2probe_tlast ),

    .m_axis_tvalid     (probe2cdc_tvalid),
    .m_axis_tready     (probe2cdc_tready),
    .m_axis_tdata      (probe2cdc_tdata ),
    .m_axis_tkeep      (probe2cdc_tkeep ),
    .m_axis_tlast      (probe2cdc_tlast ),

    .s_axis_bad_packet (probe_bad_packet),

    .dut2vip_bus       (dut2vip_bus     ),
    .vip2dut_clk       (vip2dut_clk     ),
    .vip2dut_bus       (vip2dut_bus     )

  );


  // VIP to pcie CDC
  axis_cdc_async i_cdc_probe2xdma
  (
    .s_axis_aresetn (xdma_resetn     ),
    .s_axis_aclk    (dut_clk         ),
    .s_axis_tvalid  (probe2cdc_tvalid),
    .s_axis_tready  (probe2cdc_tready),
    .s_axis_tdata   (probe2cdc_tdata ),
    .s_axis_tkeep   (probe2cdc_tkeep ),
    .s_axis_tlast   (probe2cdc_tlast ),

    .m_axis_aresetn (xdma_resetn     ),
    .m_axis_aclk    (xdma_clk        ),
    .m_axis_tvalid  (cdc2xdma_tvalid ),
    .m_axis_tready  (cdc2xdma_tready ),
    .m_axis_tdata   (cdc2xdma_tdata  ),
    .m_axis_tkeep   (cdc2xdma_tkeep  ),
    .m_axis_tlast   (cdc2xdma_tlast  )
  );


  // DUT
  inverse
  #(.SIG_WIDTH (C_DATA_WIDTH),
    .STAGES    (128         )
  )
  i_inverse
  (
    .clk (vip2dut_clk),
    .in  (vip2dut_bus),
    .out (dut2vip_bus)
  );


endmodule
