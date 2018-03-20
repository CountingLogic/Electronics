module DAC_Driver	(	CLK_50M,
				SPI_SCK,
				Va, Vb,
				startEnable,

				SPI_MOSI, DAC_CS, DAC_CLR,
				dacNumber
			);

input		CLK_50M;
input		SPI_SCK;
input	[11:0]	Va;
input	[11:0]	Vb;
input		startEnable;

output		SPI_MOSI;
output		DAC_CS;
output		DAC_CLR;
output		dacNumber;

endmodule
