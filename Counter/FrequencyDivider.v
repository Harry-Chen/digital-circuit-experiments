module FrequencyDivider(
  input     CLK,
  output    DividedCLK
);

    parameter ClockFrequency = 1000000;
    parameter NeededFrequency = 1;
    localparam CLOCKS_NEEDED = ClockFrequency / NeededFrequency;

    reg         outputClk = 0;
    reg [19:0]   count = 0;
    assign DividedCLK = outputClk;

    always @(posedge CLK) begin
    if (count == CLOCKS_NEEDED) begin
        count <= 0;
        outputClk <= ~outputClk;
    end else begin
        count <= count + 1;
    end
    end

endmodule // FrequencyDivider