module PasswordSetter(
    input         CLK,
    input         RST,
    input         enable,
    input  [3:0]  digit,
    output [3:0]  data,
    output [1:0]  address,
    output        shouldWrite,
    output [2:0]  dbgSetState // for debug purposes
  );

    typedef enum logic [2:0] {
        S_INIT, S_0, S_1, S_2, S_3
    } SetState;

    SetState currentSetState, nextSetState;

    assign dbgSetState = currentSetState;

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            currentSetState <= enable ? S_0 : currentSetState;
        end else begin
            currentSetState <= enable ? nextSetState : currentSetState;
        end
    end

    always_comb begin
        unique case (currentSetState)

            `define SET_STATE(NOW, NEXT_STATE) \
            S_``NOW: begin \
                shouldWrite = 1; \
                address = NOW; \
                data = digit; \
                nextSetState = NEXT_STATE; \
            end \

            `SET_STATE(0, S_1)
            `SET_STATE(1, S_2)
            `SET_STATE(2, S_3)
            `SET_STATE(3, S_INIT)

            default: begin
                address = 0;
                data = 0;
                shouldWrite = 0;
                nextSetState = S_INIT;
            end

        endcase
    end

endmodule // PasswordSetter