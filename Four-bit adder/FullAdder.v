module FullAdder
(
  input     A,
  input     B,
  input     Cin,
  output    S,
  output    Cout,
  output    P,
  output    G
);


assign S = A ^ B ^ Cin;
assign Cout = (A & B) | (Cin & (A ^ B));
assign P = A ^ B;
assign G = A & B;


endmodule // HalfAdder
