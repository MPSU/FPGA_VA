module dumb_vip_axis_tb();

  localparam C_DATA_WIDTH = 128;
  localparam WORDS_NUM = 10;

  logic                      s_axis_aresetn;
  logic                      s_axis_aclk;

  logic                      s_axis_tvalid;
  logic                      s_axis_tready;
  logic [C_DATA_WIDTH-1  :0] s_axis_tdata;
  logic [C_DATA_WIDTH/8-1:0] s_axis_tkeep;
  logic                      s_axis_tlast;

  logic                      m_axis_tvalid;
  logic                      m_axis_tready;
  logic [C_DATA_WIDTH-1  :0] m_axis_tdata;
  logic [C_DATA_WIDTH/8-1:0] m_axis_tkeep;
  logic                      m_axis_tlast;

  logic                                vip2dut_clk;
  logic [(C_DATA_WIDTH*WORDS_NUM)-1:0] vip2dut_bus;
  logic [(C_DATA_WIDTH*WORDS_NUM)-1:0] dut2vip_bus;


  initial begin
    s_axis_aclk = 1;
    forever
      #5 s_axis_aclk = ~s_axis_aclk;
  end

  initial begin
    s_axis_aresetn <= 0;
    s_axis_tvalid <= 0;
    s_axis_tkeep <= 0;
    s_axis_tdata <= 0;
    s_axis_tlast <= 0;

    m_axis_tready <= 1;

    dut2vip_bus <= '1;

    #100
    s_axis_aresetn <= 1;
    #10
    s_axis_tvalid <= 1;
    s_axis_tdata <= '0;
    #10 // 1
    #10 // 2
    #10 // 3
    #10 // 4
    #10 // 5
    #10 // 6
    #10 // 7
    #10 // 8
    #10 // 9
    s_axis_tlast <= 1;
    #10 // 10
    s_axis_tlast <= 0;
    s_axis_tvalid <= 0;
  end



vip_axis
#(.C_DATA_WIDTH (C_DATA_WIDTH),
  .VIP2DUT_WORDS_NUM    (WORDS_NUM),
  .DUT2VIP_WORDS_NUM    (WORDS_NUM))
UUT
(
  .s_axis_aresetn (s_axis_aresetn),
  .s_axis_aclk    (s_axis_aclk),

  .s_axis_tvalid  (s_axis_tvalid),
  .s_axis_tready  (s_axis_tready),
  .s_axis_tdata   (s_axis_tdata),
  .s_axis_tkeep   (s_axis_tkeep),
  .s_axis_tlast   (s_axis_tlast),

  .m_axis_tvalid  (m_axis_tvalid),
  .m_axis_tready  (m_axis_tready),
  .m_axis_tdata   (m_axis_tdata),
  .m_axis_tkeep   (m_axis_tkeep),
  .m_axis_tlast   (m_axis_tlast),

  .vip2dut_clk      (vip2dut_clk),
  .vip2dut_bus     (vip2dut_bus),
  .dut2vip_bus     (dut2vip_bus)
);






endmodule
