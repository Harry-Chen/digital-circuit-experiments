module PasswordSetter(
    input         CLK,
    input         RST,
    input         enable,
    input  [3:0]  digit,
    output [3:0]  data,
    output [1:0]  address,
    output        shouldWrite
  );

    typedef enum logic [2:0] {
        S_INIT, S_0, S_1, S_2, S_3
    } SetState;

    SetState currentSetState, nextSetState;

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            currentSetState <= enable ? S_0 : currentSetState;
        end else begin
            currentSetState <= enable ? nextSetState : currentSetState;
        end
    end

    always_comb begin
        unique case (currentSetState)

            S_0: begin
                shouldWrite = 1;
                address = 0;
                data = digit;
                nextSetState = S_1;
            end

            S_1: begin
                shouldWrite = 1;
                address = 1;
                data = digit;
                nextSetState = S_2;
            end

            S_2: begin
                shouldWrite = 1;
                address = 2;
                data = digit;
                nextSetState = S_3;
            end

            S_3: begin
                shouldWrite = 1;
                address = 3;
                data = digit;
                nextSetState = S_INIT;
            end

            default: begin
                address = 0;
                data = 0;
                shouldWrite = 0;
                nextSetState = S_INIT;
            end
            
        endcase
    end

endmodule // PasswordSetter