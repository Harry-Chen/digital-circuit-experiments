module SerialFourBitAdder
	(
	input   [3:0]   A,
	input   [3:0]   B,
	input           Cin,
	output  [3:0]   F,
	output          Cout
	);

wire [3:0]C;

assign Cout = C[3];

FullAdder adder_1(.A(A[0]), .B(B[0]), .Cin(Cin), .S(F[0]), .Cout(C[0]));
FullAdder adder_2(.A(A[1]), .B(B[1]), .Cin(C[0]), .S(F[1]), .Cout(C[1]));
FullAdder adder_3(.A(A[2]), .B(B[2]), .Cin(C[1]), .S(F[2]), .Cout(C[2]));
FullAdder adder_4(.A(A[3]), .B(B[3]), .Cin(C[2]), .S(F[3]), .Cout(C[3]));

endmodule