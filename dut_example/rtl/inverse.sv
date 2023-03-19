module inverse
#(parameter SIG_WIDTH = 128,
  parameter STAGES    = 128
)  
(
  input             clk,
  input [SIG_WIDTH-1:0] in,
  output[SIG_WIDTH-1:0] out
);

logic [STAGES-1:0][SIG_WIDTH-1:0] temp_reg;

always_ff @(posedge clk) begin
  temp_reg <= {temp_reg[STAGES-2:0], in};
end

assign out = {<<{temp_reg[STAGES-1]}}; //inverse direction of bits in input signal

endmodule