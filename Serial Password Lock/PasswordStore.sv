module PasswordStore(
  input          CLK,
  input  [1:0]   address,
  input          shouldWrite, // 1->write, 0->disabled
  input  [3:0]   inputData,
  output [3:0]   outputData
);

    // memory space for storing password
    logic [3:0]memory[3:0];

    always_ff @(posedge CLK) begin
        if (shouldWrite) begin // write
            memory[address] <= inputData;
        end
    end

    // we do not have to wait for an clock edge when reading
    assign outputData = memory[address];

endmodule // PasswordStore