`define		defaultPeriod	30'b000001011111010111100001000000	//	25 10^6
`define		100_Hz_Period	30'd250000


module simpleChronometer	(	CLK_50M,
					SW,

					LED);

input		CLK_50M;
input		SW;

output	[7:0]	LED;

/****************************************/
/*** ... and hereafter what's left... ***/
/****************************************/
wire		w_clock_100_Hz;
wire		w_clock_10_Hz;
wire		w_clock_1_Hz;
wire		w_clock_05_Hz;
wire		[7:0] w1;
wire		[7:0] w2;

Module_FrequencyDivider		clock_100_Hz_generator	(	.clk_in(CLK_50M),
								.period(`100_Hz_Period),

								.clk_out(w_clock_100_Hz));

Module_Counter_8_bit		counter1		(	.clk_in(w_clock_100_Hz),
								.limit(8'b00001010),

								.out(w1[3:0]),
								.carry(w_clock_10_Hz));


Module_Counter_8_bit		counter2		(	.clk_in(w_clock_10_Hz),
								.limit(8'b00001010),

								.out(w1[7:4]),
								.carry(w_clock_1_Hz));

Module_Counter_8_bit		counter3		(	.clk_in(w_clock_1_Hz),
								.limit(8'b00001010),

								.out(w2[3:0]),
								.carry(w_clock_05_Hz));
								
Module_Counter_8_bit		counter4		(	.clk_in(w_clock_05_Hz),
								.limit(8'b00001010),

								.out(w2[7:4]));

Module_Multiplexer_2_input_8_bit_comb	mux	(	.address(SW),
								.input_0(w1),
								.input_1(w2),

							.mux_output(LED));
endmodule
