module LightenDigitalLife
	(
	input [3:0]Key, // unused
	input Reset,
	input Clock, // 1MHz
	input ManualClock,
	output [3:0]DisplayOdd, // not decoded
	output [3:0]DisplayEven,
	output [6:0]DisplayNatural // decoded
	);
	
reg [19:0]count;
reg [3:0]natural;
reg [3:0]even;
reg [3:0]odd;

LED_Decoder decoder(natural, DisplayNatural);

assign DisplayEven = even;
assign DisplayOdd = odd;

always @(posedge Clock or negedge Reset) begin

	if (~Reset) begin // initial state
		count = 20'd0;
		natural = 4'd0;
		even = 4'd0;
		odd = 4'd1;
	end
	else begin
		count = count + 1'd1;
		
		if (count == 20'd1000000 || ManualClock) begin // accumulate every 1s
		
			count = 20'd0;
			
			natural = natural + 1'd1;
			even =  even + 2'd2;
			odd = odd + 2'd2;
			
			// make numbers cyclic
			if (natural == 4'hf) natural = 4'd0;
			if (even == 4'd10) even = 4'd0;
			if (odd == 4'd11) odd = 4'd1;
	
		end
	end
	
end
	
endmodule
