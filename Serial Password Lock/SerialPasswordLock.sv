module SerialPasswordLock(
  input          CLK,
  input          reset,
  input          setMode,
  input [3:0]    digit,
  output         unlockLight,
  output         errorLight,
  output         warningLight,
  output [2:0]   dbgMainState,
  output [3:0]   dbgSuccessState,
  output [2:0]   dbgErrorState,
  output         dbgAdminState,
  output [2:0]   dbgSetState,
  output [3:0]   dbgReadData
);

    logic RST;
    assign RST = reset;

    logic lockDown = 0, resetLockDown = 0;
    logic nowLockDown;
    assign nowLockDown = lockDown & !resetLockDown;
    assign warningLight = lockDown;

    typedef enum logic [2:0] {
        S_NORMAL, S_LOCKED, S_1, S_2, S_3, S_4, S_DONE
    } LockState;

    LockState currentState, nextState;
    assign dbgMainState = currentState;

    logic   [3:0]   digitToSet, digitRead;
    assign dbgReadData = digitRead;
    logic   [1:0]   writeAddress, readAddress, address;
    assign address = setMode ? writeAddress : readAddress;
    logic           shouldWrite;

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

    PasswordValidator validator(
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
        if (!RST) currentState <= S_NORMAL;
        else currentState <= nextState;
    end

    always_comb begin
        unique case (currentState)
            S_NORMAL: begin
                resetLockDown = 0;
                if (lockDown) nextState = S_LOCKED;
                else nextState = S_NORMAL;
            end

            S_LOCKED: begin
                resetLockDown = 0;
                if (digit==0) nextState = S_1;
                else nextState = S_LOCKED;
            end

            S_1: begin
                resetLockDown = 0;
                if (digit==1) nextState = S_2;
                else nextState = S_LOCKED;
            end

            S_2: begin
                resetLockDown = 0;
                if (digit==2) nextState = S_3;
                else nextState = S_LOCKED;
            end

            S_3: begin
                resetLockDown = 0;
                if (digit==9) nextState = S_4;
                else nextState = S_LOCKED;
            end

            S_4: begin
                resetLockDown = 1;
                nextState = S_DONE;
            end

            default: begin
                resetLockDown = 0;
                nextState = S_NORMAL;
            end
        endcase
    end

endmodule // SerialPasswordLock