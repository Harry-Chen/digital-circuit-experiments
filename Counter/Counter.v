module Counter(
  input             CLK,
  input             RST,
  input             pause,
  input             timer,
  output    [6:0]   highDisplay,
  output    [6:0]   lowDisplay
);

wire    [3:0]   outputLow;
wire    [3:0]   outputHigh;
wire            fullLow;
wire            fullAll;
wire            clkToUse;
wire            clkPerSecond;

FrequencyDivider #(
    .ClockFrequency(1000000),
    .NeededFrequency(1)
) divider (
    .CLK(CLK),
    .DividedCLK(clkPerSecond)
);
assign clkToUse = timer ? clkPerSecond : CLK;


assign fullLow = (outputLow == 4'd10); 
assign fullAll = (outputLow == 4'd10) && (outputHigh == 4'd5);


FourBitCounter counterLow(
    .CLK(clkToUse),
    .RST(RST & !fullLow),
    .pause(pause),
    .Q(outputLow)
);

FourBitCounter counterHigh(
    .CLK(fullLow),
    .RST(RST & !fullAll),
    .pause(pause),
    .Q(outputHigh)
);

LedDecoder decoderLow(
	.hex(outputLow),
	.segments(lowDisplay)
);

LedDecoder decoderHigh(
	.hex(outputHigh),
	.segments(highDisplay)
);


endmodule // Counter