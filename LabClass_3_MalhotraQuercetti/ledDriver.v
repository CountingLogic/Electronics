`define		defaultPeriod	30'b000001011111010111100001000000
//	25 10^6 DEFAULT PERIOD DEFINITION


module ledDriver	(	CLK_50M,
				PB,

				LED);

input		CLK_50M;
input		PB;

output	LED;



ToggleFlipFlop	try	(	.clk_in(CLK_50M),
								.pb(PB),

								.out(LED));

endmodule
