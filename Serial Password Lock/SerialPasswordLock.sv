module SerialPasswordLock(
  input          CLK,
  input          reset,
  input          setMode,
  input  [3:0]   digit,
  output         unlockLight,
  output         errorLight,
  output         warningLight,
  // below for debug purposes
  output [2:0]   dbgMainState,
  output [3:0]   dbgSuccessState,
  output [2:0]   dbgErrorState,
  output         dbgAdminState,
  output [2:0]   dbgSetState,
  output [3:0]   dbgReadData,
  output [3:0]   dbgAddress,
  output         dbgLockDown,
  output         dbgResetLockDown
);

    parameter ADMIN_PASSWORD_0 = 0;
    parameter ADMIN_PASSWORD_1 = 1;
    parameter ADMIN_PASSWORD_2 = 2;
    parameter ADMIN_PASSWORD_3 = 9;

    wire RST;
    assign RST = reset;

    logic lockDown, resetLockDown;
    logic nowLockDown;
    assign nowLockDown = lockDown & !resetLockDown;
    assign warningLight = lockDown;

    typedef enum logic [2:0] {
        S_NORMAL, S_LOCKED, S_1, S_2, S_3, S_4, S_DONE
    } LockState;

    LockState currentState, nextState;
    logic [3:0] digitToSet, digitRead;
    logic [1:0] writeAddress, readAddress, address;
    assign address = setMode ? writeAddress : readAddress;

    logic shouldWrite;

    // debug purposes
    assign dbgLockDown = lockDown;
    assign dbgResetLockDown = resetLockDown;
    assign dbgMainState = currentState;
    assign dbgAddress = address;
    assign dbgReadData = digitRead;

    PasswordStore store(
        .CLK(CLK),
        .address(address),
        .shouldWrite(shouldWrite),
        .inputData(digitToSet),
        .outputData(digitRead)
    );

    PasswordSetter setter(
        .CLK(CLK),
        .RST(RST),
        .enable(setMode & !nowLockDown),
        .digit(digit),
        .data(digitToSet),
        .address(writeAddress),
        .shouldWrite(shouldWrite),
        .dbgSetState(dbgSetState)
    );

    PasswordValidator #(
        .ADMIN_PASSWORD_0(ADMIN_PASSWORD_0),
        .ADMIN_PASSWORD_1(ADMIN_PASSWORD_1),
        .ADMIN_PASSWORD_2(ADMIN_PASSWORD_2),
        .ADMIN_PASSWORD_3(ADMIN_PASSWORD_3)
    ) validator(
        .CLK(CLK),
        .RST(RST),
        .enable(!setMode & !nowLockDown),
        .data(digitRead),
        .digit(digit),
        .address(readAddress),
        .errorLight(errorLight),
        .unlockLight(unlockLight),
        .lockDown(lockDown),
        .resetLockDown(resetLockDown),
        .dbgSuccessState(dbgSuccessState),
        .dbgErrorState(dbgErrorState),
        .dbgAdminState(dbgAdminState)
    );

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            currentState <= lockDown ? S_LOCKED : S_NORMAL;
		  end
        else currentState <= nextState;
    end

    always_comb begin
        unique case (currentState)
            default: begin
                resetLockDown = 0;
                nextState = S_NORMAL;
            end

            S_LOCKED: begin
                resetLockDown = 0;
                if (digit == ADMIN_PASSWORD_0) nextState = S_1;
                else nextState = S_LOCKED;
            end

            `define MAIN_STATE(now, next) \
            S_``now: begin \
                resetLockDown = 0; \
                if (digit == ADMIN_PASSWORD_``now) nextState = S_``next; \
                else nextState = S_LOCKED; \
            end

            `MAIN_STATE(1, 2)
            `MAIN_STATE(2, 3)
            `MAIN_STATE(3, 4)

            `undef MAIN_STATE

            S_4: begin
                resetLockDown = 1;
                nextState = S_DONE;
            end
        endcase
    end

endmodule // SerialPasswordLock