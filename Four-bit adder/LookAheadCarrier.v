module LookAheadCarrier(
  input             Cin,
  input     [3:0]   P,
  input     [3:0]   G,
  output    [3:0]   Cout,
  output            Pout,
  output            Gout
);

assign Cout[0] = G[0] | (P[0] & Cin);
assign Cout[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin);
assign Cout[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Cin);
assign Cout[3] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & Cin);

// not implemented
assign Pout = 1;
assign Gout = 1;

endmodule // LookAheadCarrier