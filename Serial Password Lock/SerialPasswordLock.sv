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
  output [3:0]   dbgReadData,
  output [3:0]   dbgAddress,
  output         dbgLockDown,
  output         dbgResetLockDown
);

    wire RST;
    assign RST = reset;

    logic lockDown, resetLockDown;
    logic nowLockDown;
	 assign dbgLockDown = lockDown;
	 assign dbgResetLockDown = resetLockDown;
    assign nowLockDown = lockDown & !resetLockDown;
    assign warningLight = lockDown;

    typedef enum logic [2:0] {
        S_NORMAL, S_LOCKED, S_1, S_2, S_3, S_4, S_DONE
    } LockState;

    LockState currentState, nextState;
    assign dbgMainState = currentState;

    wire   [3:0]   digitToSet, digitRead;
    assign dbgReadData = digitRead;
    wire   [1:0]   writeAddress, readAddress, address;
    assign address = setMode ? writeAddress : readAddress;
    assign dbgAddress = address;
    wire           shouldWrite;

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
        endcase
    end

endmodule // SerialPasswordLock