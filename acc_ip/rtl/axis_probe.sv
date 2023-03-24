module axis_probe
#(
  parameter C_DATA_WIDTH         = 128,
  parameter VIP2DUT_WORDS_NUM    = 10,
  parameter DUT2VIP_WORDS_NUM    = 10
)
(
  input  logic                      s_axis_aresetn,
  input  logic                      s_axis_aclk,

  input  logic                      s_axis_tvalid,
  output logic                      s_axis_tready,
  input  logic [C_DATA_WIDTH-1  :0] s_axis_tdata,
  input  logic [C_DATA_WIDTH/8-1:0] s_axis_tkeep,
  input  logic                      s_axis_tlast,

  output logic                      m_axis_tvalid,
  input  logic                      m_axis_tready,
  output logic [C_DATA_WIDTH-1  :0] m_axis_tdata,
  output logic [C_DATA_WIDTH/8-1:0] m_axis_tkeep,
  output logic                      m_axis_tlast,

  output logic                      s_axis_bad_packet,

  input  logic [(C_DATA_WIDTH*DUT2VIP_WORDS_NUM)-1:0] dut2vip_bus,

  output logic                                        vip2dut_clk,
  output logic [(C_DATA_WIDTH*VIP2DUT_WORDS_NUM)-1:0] vip2dut_bus

);

  // Local declarations
  logic                                 s_axis_handshake;
  logic                                 m_axis_handshake;

  logic                                 vip_clk_en_ff;
  logic                                 vip_clk_en_next;

  logic                                 dut2vip_capture_ff;

  logic [C_DATA_WIDTH             -1:0] s_axis_shreg_ff   [VIP2DUT_WORDS_NUM-1:0];
  logic [C_DATA_WIDTH             -1:0] s_axis_shreg_next [VIP2DUT_WORDS_NUM-1:0];
  logic                                 s_axis_shreg_en;

  logic [$clog2(VIP2DUT_WORDS_NUM)-1:0] s_axis_word_cnt_ff;
  logic [$clog2(VIP2DUT_WORDS_NUM)-1:0] s_axis_word_cnt_next;
  logic                                 s_axis_word_cnt_en;

  logic                                 s_axis_bad_packet_ff;
  logic                                 s_axis_bad_packet_next;
  logic                                 s_axis_bad_packet_en;

  logic [C_DATA_WIDTH             -1:0] dut2vip_bus_mda   [DUT2VIP_WORDS_NUM-1:0];
  logic [C_DATA_WIDTH             -1:0] m_axis_shreg_ff   [DUT2VIP_WORDS_NUM-1:0];
  logic [C_DATA_WIDTH             -1:0] m_axis_shreg_next [DUT2VIP_WORDS_NUM-1:0];
  logic                                 m_axis_shreg_en;

  logic [$clog2(DUT2VIP_WORDS_NUM)-1:0] m_axis_word_cnt_ff;
  logic [$clog2(DUT2VIP_WORDS_NUM)-1:0] m_axis_word_cnt_next;
  logic                                 m_axis_word_cnt_en;

  logic                                 m_axis_actv_ff;
  logic                                 m_axis_actv_next;
  logic                                 m_axis_actv_en;


  // AXI Stream handshakes
  assign s_axis_handshake = s_axis_tvalid & s_axis_tready;
  assign m_axis_handshake = m_axis_tvalid & m_axis_tready;


  // vip2dut shift register
  // This register accepts 128 bits of data every s_axis handshake
  generate;
    assign s_axis_shreg_next[0] = s_axis_tdata;
    for (genvar i = 1; i < VIP2DUT_WORDS_NUM; i++)
      assign s_axis_shreg_next[i] = s_axis_shreg_ff[i-1];
  endgenerate

  assign s_axis_shreg_en = s_axis_handshake;

  always_ff @(posedge s_axis_aclk) begin
    if (s_axis_shreg_en)
      s_axis_shreg_ff <= s_axis_shreg_next;
  end


  // To keep track on transaction count s_axis_word_cnt_ff increments
  // at every transaction and goes to 0 at s_axis_tlast
  assign s_axis_word_cnt_next = s_axis_tlast ? '0
                                             : s_axis_word_cnt_ff + 1;

  assign s_axis_word_cnt_en = s_axis_handshake;

  always_ff @(posedge s_axis_aclk or negedge s_axis_aresetn) begin
    if (~s_axis_aresetn)
      s_axis_word_cnt_ff <= '0;
    else if (s_axis_word_cnt_en)
      s_axis_word_cnt_ff <= s_axis_word_cnt_next;
  end


  // The expected packet size is equal to shift register size
  // "bad packet size" flag rises if:
  // - No s_axis_tlast when expected
  // - Unexpected s_axis_tlast arrived
  assign s_axis_bad_packet_next = ((s_axis_word_cnt_ff == VIP2DUT_WORDS_NUM-1) & ~s_axis_tlast)
                                     | ((s_axis_word_cnt_ff != VIP2DUT_WORDS_NUM-1) &  s_axis_tlast);

  assign s_axis_bad_packet_en = s_axis_handshake;

  always_ff @(posedge s_axis_aclk or negedge s_axis_aresetn) begin
    if (~s_axis_aresetn)
      s_axis_bad_packet_ff <= '0;
    else if (s_axis_bad_packet_en)
      s_axis_bad_packet_ff <= s_axis_bad_packet_next;
  end

  assign s_axis_bad_packet = s_axis_bad_packet_ff;

  // s_axis_tready currently deasserts after s_axis_tlast and before
  // whole packet is read at m_axis side
  assign s_axis_tready = ~vip_clk_en_ff
                       & ~dut2vip_capture_ff
                       & ~m_axis_actv_ff;


  // Flatten s_axis_shreg_ff MDA to vip2dut_bus vector
  generate;
    for (genvar i = 0; i < VIP2DUT_WORDS_NUM; i++)
      assign vip2dut_bus[((i+1)*C_DATA_WIDTH)-1:(i*C_DATA_WIDTH)] = s_axis_shreg_ff[i];
  endgenerate


  // Clock and capture strobe logics
  // Capture starts after s_axis transaction with tlast
  assign vip_clk_en_next = s_axis_handshake & s_axis_tlast;

  // DUT Clock enable
  // Due to glitch-free syncronous clock-gating, actually
  // clock is enabled next cycle after vip_clk_en_ff was active
  always_ff @(posedge s_axis_aclk or negedge s_axis_aresetn) begin
    if (~s_axis_aresetn)
      vip_clk_en_ff <= '0;
    else
      vip_clk_en_ff <= vip_clk_en_next;
  end

  // VIP input capture strobe
  always_ff @(posedge s_axis_aclk or negedge s_axis_aresetn) begin
    if (~s_axis_aresetn)
      dut2vip_capture_ff <= '0;
    else
      dut2vip_capture_ff <= vip_clk_en_ff;
  end


  // Input shift register
  // Unflatten dut2vip_bus to MDA
  generate;
    for (genvar i = 0; i < DUT2VIP_WORDS_NUM; i++)
      assign dut2vip_bus_mda[i] = dut2vip_bus[((i+1)*C_DATA_WIDTH)-1:(i*C_DATA_WIDTH)];
  endgenerate

  // dut2vip shift register with data capture
  generate;
    // It is possible to zero-out m_axis_shreg_next[0] when we don't capture anything.
    // But as far as control FSM guarantees that "trash data" from m_axis_shreg_next[0]
    // will not make it's way to m_axis_tdata we actually don't care about it and can simplify logics

    // assign m_axis_shreg_next[0] = dut2vip_capture_ff ? dut2vip_bus_mda[0]
    //                                                  : '0;
    assign m_axis_shreg_next[0] = dut2vip_bus_mda[0];

    for (genvar i = 1; i < DUT2VIP_WORDS_NUM; i++)
      assign m_axis_shreg_next[i] = dut2vip_capture_ff ? dut2vip_bus_mda[i]
                                                       : m_axis_shreg_ff[i-1];
  endgenerate


  assign m_axis_shreg_en = dut2vip_capture_ff
                         | m_axis_handshake;

  always_ff @(posedge s_axis_aclk) begin
    if (m_axis_shreg_en)
      m_axis_shreg_ff <= m_axis_shreg_next;
  end

  // m_axis_tdata assignment
  assign m_axis_tdata  = m_axis_shreg_ff[DUT2VIP_WORDS_NUM-1];


  // Simple FSM to control m_valid

  // To form m_axis_valid a counter is used. After data capture
  // it is set to zero and increments at every m_axis transaction.
  assign m_axis_word_cnt_next = dut2vip_capture_ff ? '0
                                                   : m_axis_word_cnt_ff + 1;

  assign m_axis_word_cnt_en = dut2vip_capture_ff
                            | m_axis_handshake;

  always_ff @(posedge s_axis_aclk or negedge s_axis_aresetn) begin
    if (~s_axis_aresetn)
       m_axis_word_cnt_ff <= '0;
    else if ( m_axis_word_cnt_en)
       m_axis_word_cnt_ff <=  m_axis_word_cnt_next;
  end

  // m_axis_actv flag is used as a simple FSM
  // m_axis_actv_ff == "1" means that m_axis part
  // has some data to transfer to XDMA after capture.
  // So it is acts as a source for m_tvalid.

  assign m_axis_actv_next =  dut2vip_capture_ff                         ? '1
                          : (m_axis_word_cnt_ff == DUT2VIP_WORDS_NUM-1) ? '0
                          :                                               m_axis_actv_ff;

  assign m_axis_actv_en = dut2vip_capture_ff
                        | m_axis_handshake;


  always_ff @(posedge s_axis_aclk or negedge s_axis_aresetn) begin
    if (~s_axis_aresetn)
       m_axis_actv_ff <= '0;
    else if ( m_axis_actv_en)
       m_axis_actv_ff <= m_axis_actv_next;
  end

  assign m_axis_tvalid = m_axis_actv_ff;

  // m_axis_tlast rises for final transaction
  assign m_axis_tlast  = (m_axis_word_cnt_ff == DUT2VIP_WORDS_NUM-1);


  // DUT clock gating
  BUFGCE
  #(
    .CE_TYPE("SYNC")
  )
   i_BUFGCE_vip_clk
   (
    .O  ( vip2dut_clk    ),
    .CE ( vip_clk_en_ff  ),
    .I  ( s_axis_aclk    )
  );


  // tkeep is currently always filled with 1
  assign m_axis_tkeep  = '1;

endmodule
