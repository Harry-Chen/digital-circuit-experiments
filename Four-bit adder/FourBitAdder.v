module FourBitAdder(
  input     [3:0]   A,
  input     [3:0]   B,
  input             Cin,
  output    [3:0]   F_s, // serial addder
  output            Cout_s,
  output    [3:0]   F_p, // parallel adder
  output            Cout_p
);

ParallelFourBitAdder parallelAdder(.A(A), .B(B), .Cin(~Cin), .F(F_p), .Cout(Cout_p));

SerialFourBitAdder serialAdder(.A(A), .B(B), .Cin(~Cin), .F(F_s), .Cout(Cout_s));

endmodule // FourBitAdder