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
            
            S_0: begin
                error = 0;
                address = 0;
                unlockLight = 0;
                errorLight = 0;
                nextAdminState = S_FAILURE;
                nextErrorState = currentErrorState;
                nextSuccessState = S_1;
                if (digit == 0 && currentAdminState == S_SUCCESS) begin
                    nextAdminState = S_SUCCESS;
                end else if (data != digit) begin
                    error = 1;
                    nextSuccessState = S_INIT;
                    unique case (currentErrorState)
                        S_ERROR_0: nextErrorState = S_ERROR_1;
                        S_ERROR_1: nextErrorState = S_ERROR_2;
                        S_ERROR_2: nextErrorState = S_ERROR_3;
                        S_ERROR_3: nextErrorState = S_ERROR_3;
                    endcase
                end
            end

            S_1: begin
                error = 0;
                address = 1;
                unlockLight = 0;
                errorLight = 0;
                nextAdminState = S_FAILURE;
                nextErrorState = currentErrorState;
                nextSuccessState = S_2;
                if (digit == 1 && currentAdminState == S_SUCCESS) begin
                    nextAdminState = S_SUCCESS;
                end else if (data != digit) begin
                    error = 1;
                    nextSuccessState = S_INIT;
                    unique case (currentErrorState)
                        S_ERROR_0: nextErrorState = S_ERROR_1;
                        S_ERROR_1: nextErrorState = S_ERROR_2;
                        S_ERROR_2: nextErrorState = S_ERROR_3;
                        S_ERROR_3: nextErrorState = S_ERROR_3;
                    endcase
                end
            end

            S_2: begin
                error = 0;
                address = 2;
                unlockLight = 0;
                errorLight = 0;
                nextAdminState = S_FAILURE;
                nextErrorState = currentErrorState;
                nextSuccessState = S_3;
                if (digit == 2 && currentAdminState == S_SUCCESS) begin
                    nextAdminState = S_SUCCESS;
                end else if (data != digit) begin
                    error = 1;
                    nextSuccessState = S_INIT;
                    unique case (currentErrorState)
                        S_ERROR_0: nextErrorState = S_ERROR_1;
                        S_ERROR_1: nextErrorState = S_ERROR_2;
                        S_ERROR_2: nextErrorState = S_ERROR_3;
                        S_ERROR_3: nextErrorState = S_ERROR_3;
                    endcase
                end
            end

            S_3: begin
                error = 0;
                address = 3;
                unlockLight = 0;
                errorLight = 0;
                nextAdminState = S_FAILURE;
                nextErrorState = currentErrorState;
                nextSuccessState = S_DONE;
                if (digit == 9 && currentAdminState == S_SUCCESS) begin
                    nextAdminState = S_SUCCESS;
                end else if (data != digit) begin
                    error = 1;
                    nextSuccessState = S_INIT;
                    unique case (currentErrorState)
                        S_ERROR_0: nextErrorState = S_ERROR_1;
                        S_ERROR_1: nextErrorState = S_ERROR_2;
                        S_ERROR_2: nextErrorState = S_ERROR_3;
                        S_ERROR_3: nextErrorState = S_ERROR_3;
                    endcase
                end
            end

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