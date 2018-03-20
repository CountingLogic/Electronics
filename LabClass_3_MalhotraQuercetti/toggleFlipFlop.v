module ToggleFlipFlop (	clk_in,
								pb,
								out);

input		clk_in;
input		pb;
output	out;

reg		out =0; 
reg		pb_old =0;

always @(posedge clk_in) begin
	if (!pb_old & pb) begin
		out = !out;
	end
	pb_old = pb;
end

endmodule
