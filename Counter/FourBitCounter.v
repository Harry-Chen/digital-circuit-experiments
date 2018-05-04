module FourBitCounter(
  input             CLK,
  input             RST, // asynchronous reset
  //input             CLR, // synchronous reset
  input             pause,
  output    [3:0]   Q
);

    wire [3:0]_NQ;
    wire [3:0]_Q;

    assign Q = _Q;

    D_FF D_0(
        .D(pause ? _Q[0] : _NQ[0]),
        .RST(RST),
        .CLK(CLK),
        .Q(_Q[0]),
        .NQ(_NQ[0])
    );

    D_FF D_1(
        .D(pause ? _Q[1] : _NQ[1]),
        .RST(RST),
        .CLK(_NQ[0]),
        .Q(_Q[1]),
        .NQ(_NQ[1])
    );

    D_FF D_2(
        .D(pause ? _Q[2] : _NQ[2]),
        .RST(RST),
        .CLK(_NQ[1]),
        .Q(_Q[2]),
        .NQ(_NQ[2])
    );

    D_FF D_3(
        .D(pause ? _Q[3] : _NQ[3]),
        .RST(RST),
        .CLK(_NQ[2]),
        .Q(_Q[3]),
        .NQ(_NQ[3])
    );

endmodule // FourBitCounter