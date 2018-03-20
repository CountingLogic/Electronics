
module Module_Delay(qzt_clk,
						clk_in,
						Vin,
						
						Vout);

input		qzt_clk;
input		clk_in;
input		[13:0]	Vin;

output	[13:0]	Vout;

reg	clk_in_old;
reg	Vout;
always @(posedge qzt_clk) begin
	if (!clk_in_old & clk_in) 
		Vout = Vin;
	
	clk_in_old = clk_in;
end
endmodule
