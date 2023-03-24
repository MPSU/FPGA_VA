module vip_axis #(
  parameter C_DATA_WIDTH,           // in bits
  parameter XDMA_TRANSFER_SIZE_IN,  // in bits
  parameter XDMA_TRANSFER_SIZE_OUT  // in bits
) (
  input  logic                                axi_clk,
  input  logic                                axi_aresetn,

  output logic [C_DATA_WIDTH-1:0]             m_axis_c2h_tdata_0,
  output logic                                m_axis_c2h_tlast_0,
  output logic                                m_axis_c2h_tvalid_0,
  input  logic                                m_axis_c2h_tready_0,
  output logic [C_DATA_WIDTH/8-1:0]           m_axis_c2h_tkeep_0,

  input  logic [C_DATA_WIDTH-1:0]             s_axis_h2c_tdata_0,
  input  logic                                s_axis_h2c_tlast_0,
  input  logic                                s_axis_h2c_tvalid_0,
  output logic                                s_axis_h2c_tready_0,
  input  logic [C_DATA_WIDTH/8-1:0]           s_axis_h2c_tkeep_0,
  // gated clock
  output                                      vip_clk,
  // from DUT
  input  logic [XDMA_TRANSFER_SIZE_OUT-1:0]   vip_data_out,
  // to DUT
  output logic [XDMA_TRANSFER_SIZE_IN-1:0]    vip_data_in
);

/*

  Логика работы IP:
  
  IP принимает входные данные до приема последнего (last) пакета
  (возможно заменить на счетчик).

  Данные принимаются в сдвиговый регистр vip_data_in в случае, если размер
  пересылаемых данных больше разрядности транзакций axi steram. В случае, если
  разрядность меньше либо равна разрядности axi stream, vip_data_in
  синтезируется обычный регистр.
  
  Размер пересылаемых данных обязан быть кратен разрядности axi stream.
  За этой частью следит скрипт автогенерации, добивая размер нулями в старших
  разрядах.
  
  После приема последнего пакета, происходит тактирование DUT. В этот момент,
  все данные уже находятся в регистре vip_data_in.
  
  В момент тактирования, в счетчик выходных пакетов записывается 1. С этого
  момента, счетчик начинает отсчитывать выходные транзакции, пока не отсчитает
  количество XDMA_TRANSFERS_OUT_NUM.
  
  Выходные транзакции идут из выходного сдвигового регистра, данные в него
  защелкиваются при тактировании DUT.

  В момент выдачи данных, IP может принимать следующую порцию данных
  (что вообще говоря в данный момент не может использоваться, т.к. тестбенч
  не отправит новую порцию стимулов, пока не придут результаты с предыдущей
  посылки, но вдруг это когда-нибудь изменится).

  IP перестанет принимать данные, в случае, если он принял почти все входные
  сигналы, но выходной интерфейс еще не отправил все значения.

*/

  generate 
    // Check if transfer size is multiple of axi_stream data width and throw
    // synthesis error if not
    if((XDMA_TRANSFER_SIZE_IN % C_DATA_WIDTH) != 0) begin
      illegal_parameter XDMA_TRANSFER_SIZE_IN();
    end
    if((XDMA_TRANSFER_SIZE_OUT % C_DATA_WIDTH) != 0) begin
      illegal_parameter XDMA_TRANSFER_SIZE_OUT();
    end
  endgenerate


  localparam XDMA_TRANSFERS_OUT_NUM = XDMA_TRANSFER_SIZE_OUT / C_DATA_WIDTH;
  localparam XDMA_TRANSFERS_IN_NUM  = XDMA_TRANSFER_SIZE_IN / C_DATA_WIDTH;
  logic axi_handshake_in;
  logic axi_handshake_out;

  assign axi_handshake_in = s_axis_h2c_tvalid_0 && s_axis_h2c_tready_0;
  assign axi_handshake_out= m_axis_c2h_tvalid_0 && m_axis_c2h_tready_0;



  // DUT clock gating
  logic abs_clk_cg;
  BUFGCE BUFGCE_vip_clk (
    .O  ( vip_clk     ), // 1-bit output: Clock output
    .CE ( abs_clk_cg  ), // 1-bit input: Clock output
    .I  ( axi_clk     )  // 1-bit input: Clock input
  );
  assign abs_clk_cg = (s_axis_h2c_tlast_0 && axi_handshake_in);

  // Saving data from host
  logic [XDMA_TRANSFER_SIZE_IN        -1:0] dut_stimulus;

  // If XDMA_TRANSFER_SIZE_IN <= C_DATA_WIDTH we should synthesise a common
  // register, not shift register
  generate if(XDMA_TRANSFER_SIZE_IN <= C_DATA_WIDTH) begin
    assign dut_stimulus = s_axis_h2c_tdata_0;
  end
  else begin
    assign dut_stimulus = {
      dut_stimulus[XDMA_TRANSFER_SIZE_IN-C_DATA_WIDTH-1-:C_DATA_WIDTH],
      s_axis_h2c_tdata_0
    };
  end
  endgenerate
  
  always_ff @( posedge axi_clk ) begin
    if( ~axi_aresetn ) begin
      vip_data_in <= '0;
    end
    else begin
      if ( axi_handshake_in ) begin
        vip_data_in <= dut_stimulus;
      end
    end
  end

  logic [$clog2(XDMA_TRANSFERS_IN_NUM)-1:0] in_counter;
  
  always_ff @( posedge axi_clk ) begin
    if( ~axi_aresetn ) begin
      in_counter <= '0;
    end
    else begin
      if ( axi_handshake_in ) begin
        if(s_axis_h2c_tlast_0) begin
        in_counter <= '0;
        end
        else begin
          in_counter <= in_counter + 1'b1;
        end
      end
    end
  end
  assign s_axis_h2c_tready_0 =  (in_counter < XDMA_TRANSFERS_IN_NUM - 2) ||
                                (out_counter == 0);


  // Sending data to host
  logic [XDMA_TRANSFER_SIZE_OUT-1:0] dut_result;
  logic [$clog2(XDMA_TRANSFERS_OUT_NUM)-1:0] out_counter;

  generate if(XDMA_TRANSFER_SIZE_OUT <= C_DATA_WIDTH) begin
    assign m_axis_c2h_tdata_0 = dut_result;
  end
  else begin
    assign m_axis_c2h_tdata_0 = dut_result[XDMA_TRANSFER_SIZE_OUT-1-:C_DATA_WIDTH];
  end
  endgenerate

  assign m_axis_c2h_tlast_0 = out_counter == XDMA_TRANSFERS_OUT_NUM;
  assign m_axis_c2h_tvalid_0= out_counter != 0;
  assign m_axis_c2h_tkeep_0 = '1;
  
  always_ff @(posedge axi_clk) begin
    if(~axi_aresetn) begin
      dut_result <= '0;
    end
    else if(abs_clk_cg) begin
      dut_result <= vip_data_out;
    end
    else if((out_counter != '0) && axi_handshake_out) begin
      dut_result <= dut_result << C_DATA_WIDTH;
    end
  end

  always_ff @(posedge axi_clk) begin
    if(~axi_aresetn) begin
      out_counter <= '0;
    end
    else begin
      if(out_counter == '0) begin
        out_counter <= abs_clk_cg;
      end
      else if(m_axis_c2h_tready_0) begin
        if(out_counter < XDMA_TRANSFERS_OUT_NUM - 'd1) begin
          out_counter <= out_counter + 'd1;
        end
        else begin
          out_counter <= '0;
        end
      end
    end
  end


endmodule