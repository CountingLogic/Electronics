`define		100_Hz_Period	30'b000000000000111101000010010000	//	25 10^4
`define		1_kHz_Period	30'd25000

module startStopLapReset_LCD	(	CLK_50M,
					SW,
					PUSH_BTN_SS, PUSH_BTN_LR,

					LED,
					LCD_DB,
					LCD_E, LCD_RS, LCD_RW);

input		CLK_50M;
input		SW;
input		PUSH_BTN_SS;
input		PUSH_BTN_LR;

output	[7:0]	LED;
output	[7:0]	LCD_DB;
output		LCD_E;
output		LCD_RS;
output		LCD_RW;


wire	[15:0]	wb_counter;
wire	[15:0]	wb_counter_toShow;

wire		w_startstop_pulse;
wire		w_startStop;
wire		w_lapreset_pulse_0;
wire		w_lapreset_pulse_1;
wire		w_lapreset_pulse_2;
wire		w_lap_pulse;
wire		w_lapFlag;
wire		w_reset;

wire		w_clock_1kHz;

wire		w_clock_100_Hz;
wire		w_enabled_clock_100_Hz;
wire		w_clock_10_Hz;
wire		w_clock_1_Hz;
wire		w_clock_01_Hz;

//commands

Module_FrequencyDivider		clock_1kHz_generator_for_monostables	(	.clk_in(CLK_50M),
								.period(`1_kHz_Period),

								.clk_out(w_clock_1kHz));

Module_Monostable		startstop_pulse		(	.clk_in(w_clock_1kHz),	// .clk_in(CLK_50M),
								.monostable_input(PUSH_BTN_SS),
								.N(28'd5),		// .N(28'd5000000),

								.monostable_output(w_startstop_pulse));

Module_ToggleFlipFlop		startstop_ff			(	.clk_in(CLK_50M),
								.ff_input(w_startstop_pulse),

								.ff_output(w_startStop));

Module_Monostable		lapreset_pulse_0		(	.clk_in(w_clock_1kHz),	// .clk_in(CLK_50M),
								.monostable_input(PUSH_BTN_LR),
								.N(28'd5),		// .N(28'd5000000),

								.monostable_output(w_lapreset_pulse_0));
								
Module_Monostable		lapreset_pulse_1		(	.clk_in(w_clock_1kHz),	
								.monostable_input(!w_lapreset_pulse_0),
								.N(28'd5),		// .N(28'd5000000),

								.monostable_output(w_lapreset_pulse_1));

Module_Monostable		lapreset_pulse_2	(	.clk_in(w_clock_1kHz),	
								.monostable_input(!w_lapreset_pulse_1),
								.N(28'd5),		// .N(28'd5000000),

								.monostable_output(w_lapreset_pulse_2));

assign w_lap_pulse = ((w_startStop | w_lapFlag) & w_lapreset_pulse_2);
assign w_reset = (!w_startStop & !w_lapFlag & w_lapreset_pulse_0);

Module_ToggleFlipFlop		lap_ff			(	.clk_in(CLK_50M),
								.ff_input(w_lap_pulse),

								.ff_output(w_lapFlag));
								
/*********************/
/* TIMING GENERATION */
/*********************/
Module_FrequencyDivider		clock_100_Hz		(	.clk_in(CLK_50M),
								.period(`100_Hz_Period),

								.clk_out(w_clock_100_Hz));

and(w_enabled_clock_100_Hz, w_clock_100_Hz, w_startStop);

Module_SynchroCounter_8_bit_SR	counter_100_Hz		(	.qzt_clk(CLK_50M),
								.clk_in(w_enabled_clock_100_Hz),
								.reset(w_reset),
								.set(0),
								.limit(8'b00001010),
								.presetValue(0),

								.out(wb_counter[3:0]),
								.carry(w_clock_10_Hz));

Module_SynchroCounter_8_bit_SR	counter_10_Hz		(	.qzt_clk(CLK_50M),
								.clk_in(w_clock_10_Hz),
								.reset(w_reset),
								.set(0),
								.limit(8'b00001010),
								.presetValue(0),

								.out(wb_counter[7:4]),
								.carry(w_clock_1_Hz));
								
						
Module_SynchroCounter_8_bit_SR	counter_1_Hz		(	.qzt_clk(CLK_50M),
								.clk_in(w_clock_1_Hz),
								.reset(w_reset),
								.set(0),
								.limit(8'b00001010),
								.presetValue(0),

								.out(wb_counter[11:8]),
								.carry(w_clock_01_Hz));

Module_SynchroCounter_8_bit_SR	counter_01_Hz		(	.qzt_clk(CLK_50M),
								.clk_in(w_clock_01_Hz),
								.reset(w_reset),
								.set(0),
								.limit(8'b00001010),
								.presetValue(0),

								.out(wb_counter[15:12]));
												
								
//visualization

Module_Latch_16_bit	latch				(	.clk_in(CLK_50M),
								.holdFlag(w_lapFlag),
								.twoByteInput(wb_counter),

								.twoByteOuput(wb_counter_toShow));

Module_Multiplexer_2_input_8_bit_sync	slide_switch	(	.clk_in(CLK_50M),
								.address(SW),
								.input_0(wb_counter[7:0]),
								.input_1(wb_counter[15:8]),

								.mux_output(LED[7:0]));


buf(LCD_RW, 0);
buf(LCD_DB[3:0], 4'b1111);

LCD_Driver_forChrono	lcd_driver	(	.qzt_clk(CLK_50M),
						.fourDigitInput(wb_counter_toShow),
						.lapFlag(w_lapFlag),

						.lcd_flags({LCD_RS, LCD_E}),
						.lcd_data(LCD_DB[7:4]));
						
endmodule 