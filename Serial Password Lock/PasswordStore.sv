module PasswordStore(
  input          CLK,
  input  [1:0]   address,
  input          shouldWrite, // 1->write, 2->read
  input  [3:0]   inputData,
  output [3:0]   outputData
);

    logic [3:0]memory[3:0];

    always_ff @(posedge CLK) begin
        if (shouldWrite) begin // write
            memory[address] <= inputData;
        end
    end

    assign outputData = memory[address];

endmodule // PasswordStore