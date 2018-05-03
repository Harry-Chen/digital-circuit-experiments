module ParallelFourBitAdder
	(
	input   [3:0]   A,
	input   [3:0]   B,
	input           Cin,
	output  [3:0]   F,
	output          Cout
	);

wire [3:0]C;
wire [3:0]P;
wire [3:0]G;

LookAheadCarrier carrier(.Cin(Cin), .P(P), .G(G), .Cout(C));
assign Cout = C[3];

FullAdder adder_1(.A(A[0]), .B(B[0]), .Cin(Cin), .S(F[0]), .P(P[0]), .G(G[0]));
FullAdder adder_2(.A(A[1]), .B(B[1]), .Cin(C[0]), .S(F[1]), .P(P[1]), .G(G[1]));
FullAdder adder_3(.A(A[2]), .B(B[2]), .Cin(C[1]), .S(F[2]), .P(P[2]), .G(G[2]));
FullAdder adder_4(.A(A[3]), .B(B[3]), .Cin(C[2]), .S(F[3]), .P(P[3]), .G(G[3]));

endmodule