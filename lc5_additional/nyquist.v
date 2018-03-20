module nyquist	(	CLK_50M,
				SW,
				ADC_OUT,

				DAC_CS,
				DAC_CLR,
				SPI_SCK,
				AMP_CS,
				SPI_MOSI,
				AD_CONV);

input		CLK_50M;
input		[2:0]	SW;
input		ADC_OUT;

output		DAC_CS;
output		DAC_CLR;
output		SPI_SCK;
output		SPI_MOSI;
output		AMP_CS;
output		AD_CONV;

wire		w_SPI_MOSI_preAmp;
wire		w_SPI_MOSI_DAC;
wire		w_dacNumber;

wire	[13:0]	wb_Va;
wire	[13:0]	wb_Vb;
wire 	[13:0]	wb_Vc;
wire	[13:0]	wb_Vd;
wire	[13:0]	wb_Vdel;
wire	[13:0]	wb_Vdel2;

buf(SPI_MOSI, ((AMP_CS & w_SPI_MOSI_DAC)|(!AMP_CS & w_SPI_MOSI_preAmp)));


Module_Counter_8_bit	SPI_SCK_generator	(	.clk_in(CLK_50M),
							.limit(((SW[0])? 30'd10 : 30'd4)),

							.carry(SPI_SCK));

ADC_Driver		ADC_Driver		(	.qzt_clk(CLK_50M),
							.SPI_SCK(SPI_SCK),
							.enable(1),
							.ADC_OUT(ADC_OUT),
							.gainLabel(0),
							.waitTime({SW,4'b0000}),

							.AD_CONV(AD_CONV),
							.Va_Vb({wb_Va, wb_Vb}),
							.AMP_CS(AMP_CS),
							.SPI_MOSI(w_SPI_MOSI_preAmp));

Module_Delay	delay1				(.qzt_clk(CLK_50M),
							.clk_in(~w_dacNumber),
							.Vin(wb_Va),
							
							.Vout(wb_Vdel));
							
Module_Delay	delay2				(.qzt_clk(CLK_50M),
							.clk_in(~w_dacNumber),
							.Vin(wb_Vdel),
							
							.Vout(wb_Vdel2));

assign wb_Vd = (3*wb_Va + ((wb_Vdel[13])? (~wb_Vdel[13:0]) << 2 : ~(wb_Vdel[13:0] << 2)) + 14'b00000000000001 + wb_Vdel2);						
assign wb_Vc = (SW[1])? wb_Vdel : 
					(SW[2])? (wb_Va + ~wb_Vdel + 14'b00000000000001): //wb_Vd;
					((wb_Vd[13])? ~((~wb_Vd[13:0]) >> 1) : wb_Vd[13:0] >> 1);

DAC_Driver		DAC_Driver		(	.CLK_50M(CLK_50M),
							.SPI_SCK(SPI_SCK),
							.Va({!wb_Va[13], wb_Va[12:2]}),
							.Vb({!wb_Vc[13], wb_Vc[12:2]}),
							.startEnable(AD_CONV),

							.SPI_MOSI(w_SPI_MOSI_DAC),
							.DAC_CS(DAC_CS),
							.DAC_CLR(DAC_CLR),
							.dacNumber(w_dacNumber));

endmodule
