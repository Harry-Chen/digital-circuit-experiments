module PasswordValidator(
  input         CLK,
  input         RST,
  input         enable,
  input  [3:0]  data,
  input  [3:0]  digit,
  input         resetLockDown,
  output [1:0]  address,
  output        errorLight,
  output        unlockLight,
  output        lockDown,
  // below for debug purposes
  output [3:0]  dbgSuccessState,
  output [2:0]  dbgErrorState,
  output        dbgAdminState
);

    parameter ADMIN_PASSWORD_0 = 0;
    parameter ADMIN_PASSWORD_1 = 0;
    parameter ADMIN_PASSWORD_2 = 0;
    parameter ADMIN_PASSWORD_3 = 0;

    typedef enum logic [2:0] {
        S_INIT, S_0, S_1, S_2, S_3, S_DONE
    } SuccessState;

    typedef enum logic [1:0] {
        S_ERROR_0, S_ERROR_1, S_ERROR_2, S_ERROR_3
    } ErrorState;

    typedef enum logic {
        S_SUCCESS, S_FAILURE
    } AdminState;

    SuccessState currentSuccessState, nextSuccessState;
    ErrorState currentErrorState, nextErrorState;
    AdminState currentAdminState, nextAdminState;

    assign dbgSuccessState = currentSuccessState;
    assign dbgErrorState = currentErrorState;
    assign dbgAdminState = currentAdminState;

    logic error;

    always_ff @(posedge CLK or negedge RST or posedge resetLockDown) begin
        if (!RST | resetLockDown) begin
            currentSuccessState <= enable ? S_0 : currentSuccessState;
            currentAdminState <= enable ? S_SUCCESS : currentAdminState;
        end else if (CLK) begin
            currentSuccessState <= enable ? nextSuccessState : currentSuccessState;
            currentAdminState <= enable ? nextAdminState : currentAdminState;
            currentErrorState <= enable ? nextErrorState : currentErrorState;
        end
		  
		  if (resetLockDown) currentErrorState <= enable ? S_ERROR_0 : currentErrorState;
    end

    always_comb begin
        unique case (currentErrorState)
            S_ERROR_3: lockDown <= 1;
            default: lockDown <= 0;
        endcase

        unique case (currentSuccessState)
            S_INIT: begin
                nextSuccessState = S_INIT;
                nextAdminState = S_SUCCESS;
                errorLight = error;
                unlockLight = 0;
                error = 1;
                address = 0;
                nextErrorState = currentErrorState;
            end

            `define VALIDATE_STATE(now, nextState) \
            S_``now: begin \
                error = 0; \
                address = now; \
                unlockLight = 0; \
                errorLight = 0; \
                nextAdminState = S_FAILURE; \
                nextErrorState = currentErrorState; \
                nextSuccessState = nextState; \
                if (digit == ADMIN_PASSWORD_``now && currentAdminState == S_SUCCESS) begin \
                    nextAdminState = S_SUCCESS; \
                end else if (data != digit) begin \
                    error = 1; \
                    nextSuccessState = S_INIT; \
                    unique case (currentErrorState) \
                        S_ERROR_0: nextErrorState = S_ERROR_1; \
                        S_ERROR_1: nextErrorState = S_ERROR_2; \
                        S_ERROR_2: nextErrorState = S_ERROR_3; \
                        S_ERROR_3: nextErrorState = S_ERROR_3; \
                    endcase \
                end \
            end

            `VALIDATE_STATE(0, S_1)
            `VALIDATE_STATE(1, S_2)
            `VALIDATE_STATE(2, S_3)
            `VALIDATE_STATE(3, S_DONE)

            S_DONE: begin
                error = 0;
                address = 0;
                errorLight = 0;
                unlockLight = 1;
                nextSuccessState = S_DONE;
                nextErrorState = S_ERROR_0;
                nextAdminState = S_FAILURE;
            end

            default: nextSuccessState = S_INIT;

        endcase
    end


endmodule // PasswordValidator