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
  (* mark_debug = "true" *) logic [C_DATA_WIDTH-  1:0] m_axis_h2c_tdata_0;
  (* mark_debug = "true" *) logic                      m_axis_h2c_tlast_0;
  (* mark_debug = "true" *) logic                      m_axis_h2c_tvalid_0;
  (* mark_debug = "true" *) logic                      m_axis_h2c_tready_0;
  (* mark_debug = "true" *) logic [C_DATA_WIDTH/8-1:0] m_axis_h2c_tkeep_0;
  (* mark_debug = "true" *) logic [C_DATA_WIDTH  -1:0] s_axis_c2h_tdata_0;
  (* mark_debug = "true" *) logic                      s_axis_c2h_tlast_0;
  (* mark_debug = "true" *) logic                      s_axis_c2h_tvalid_0;
  (* mark_debug = "true" *) logic                      s_axis_c2h_tready_0;
  (* mark_debug = "true" *) logic [C_DATA_WIDTH/8-1:0] s_axis_c2h_tkeep_0;



// https://support.xilinx.com/s/question/0D52E00006iHkTaSAK/axi-bridge-for-pci-express-gen3-subsystem-sysclkgt-use?language=en_US
//PG194 says, for the "refclk" port: "UltraScale: DRP Clock and Internal System Clock (Half frequency from sys_clk_gt frequency). Should be driven by the ODIV2 port of reference clock IBUFDS_GTE3". (emphasis added.)
//However, by default, the output of the IBUFDS_GTE3 port called "ODIV2" is the same as the output on the the port called "O".  (Both are divide-by-one versions of the input to the buffer.) 
//Furthermore, the KCU105 PCIe TRD assigns the same fequency to both clocks when creating the constraints for those signals (in trd01.xdc):
//--------------------------------------------------------------------------
//create_clock -period 10.000 -name sys_clk [get_pins refclk_ibuf/ODIV2]
//create_clock -period 10.000 -name sys_clk_gt [get_pins refclk_ibuf/O]
//--------------------------------------------------------------------------
  
  logic pcie_ref_clk_odiv2;
  
  // Ref clock buffer
  IBUFDS_GTE4 i_refclk_ibuf (
    .I     (pcie_clk_p  ),
    .IB    (pcie_clk_n  ),
    .CEB   (1'b0        ),
    .O     (pcie_ref_clk),
    .ODIV2 (pcie_ref_clk_odiv2            )
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
    .sys_clk             (pcie_ref_clk_odiv2       ),
    .sys_clk_gt          (pcie_ref_clk       ),

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


  // logic h2c_handshake;
  // logic c2h_handshake;

  // assign h2c_handshake = m_axis_h2c_tvalid_0 & m_axis_h2c_tready_0;
  // assign c2h_handshake = s_axis_c2h_tvalid_0 & s_axis_c2h_tready_0;

  // (* mark_debug = "true" *) logic h2c_write_last_ff;
  // logic h2c_write_last_next;
  // logic h2c_write_last_en;

  // assign h2c_write_last_next = h2c_handshake & m_axis_h2c_tlast_0;
  // assign h2c_write_last_en   = (h2c_handshake & m_axis_h2c_tlast_0) 
  //                            | (c2h_handshake & s_axis_c2h_tlast_0);

  // always_ff @ (posedge axi_clk or negedge axi_resetn)
  //   if (~axi_resetn)
  //     h2c_write_last_ff <= '0;
  //   else if (h2c_write_last_en)
  //     h2c_write_last_ff <= h2c_write_last_next;

  // (* mark_debug = "true" *) logic write_filter;
  // assign write_filter = h2c_write_last_ff & m_axis_h2c_tvalid_0;

  //(* mark_debug = "true" *) logic block_double_writes;
  //assign block_double_writes = (s_axis_c2h_tdata_0 == m_axis_h2c_tdata_0);

  // (* mark_debug = "true" *) logic hc2_tvalid_masked;
  // assign hc2_tvalid_masked = m_axis_h2c_tvalid_0 & ~h2c_write_last_ff;


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

//(* mark_debug = "true" *) logic smth_gone_wrong;
//assign smth_gone_wrong = s_axis_c2h_tvalid_0 & m_axis_h2c_tvalid_0;

endmodule
