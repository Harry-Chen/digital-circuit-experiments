module SerialPasswordLock(
  input          CLK,
  input          reset,
  input          setMode, // 1->set password, 0->validate password
  input  [3:0]   digit, // user input
  output         unlockLight, // indicates whether the password is correct
  output         errorLight, // indicates whether the password is wrong
  output         warningLight, // indicates whether in lockdown mode
  // below for debug purposes
  output [2:0]   dbgMainState,
  output [2:0]   dbgSuccessState,
  output [1:0]   dbgErrorState,
  output         dbgAdminState,
  output [2:0]   dbgSetState,
  output [3:0]   dbgReadData,
  output [1:0]   dbgAddress,
  output         dbgLockDown,
  output         dbgResetLockDown
);

    // pre-defined admin password
    parameter ADMIN_PASSWORD_0 = 0;
    parameter ADMIN_PASSWORD_1 = 1;
    parameter ADMIN_PASSWORD_2 = 2;
    parameter ADMIN_PASSWORD_3 = 9;

    // in case that we need to do an inverse here
    wire RST;
    assign RST = reset;

    // lock down after 3 failed attempts
    logic lockDown, resetLockDown;
    logic nowLockDown;
    assign nowLockDown = lockDown & !resetLockDown;
    assign warningLight = lockDown;

    // states of FSM in lockdown mode
    typedef enum logic [2:0] {
        S_NORMAL, S_LOCKED, S_1, S_2, S_3, S_4, S_DONE
    } LockState;

    LockState currentState, nextState;

    // read/write password from/to memory
    logic [3:0] digitToSet, digitRead;
    logic [1:0] writeAddress, readAddress, address;
    assign address = setMode ? writeAddress : readAddress;
    logic shouldWrite;

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

    // validate password and report results
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

    // debug purposes
    assign dbgLockDown = lockDown;
    assign dbgResetLockDown = resetLockDown;
    assign dbgMainState = currentState;
    assign dbgAddress = address;
    assign dbgReadData = digitRead;

    // switch state on clock edges
    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            currentState <= lockDown ? S_LOCKED : S_NORMAL;
		  end
        else currentState <= nextState;
    end

    // main FSM: admin reset after lockdown
    always_comb begin
        unique case (currentState)
            // not locked down
            S_NORMAL: begin
                resetLockDown = 0;
                nextState = S_NORMAL;
            end

            // locked down
            S_LOCKED: begin
                resetLockDown = 0;
                if (digit == ADMIN_PASSWORD_0) nextState = S_1;
                else nextState = S_LOCKED;
            end

            // S_i for having entered i digits correctly
            `define MAIN_STATE(NOW, NEXT) \
            S_``NOW: begin \
                resetLockDown = 0; \
                if (digit == ADMIN_PASSWORD_``NOW) nextState = S_``NEXT; \
                else nextState = S_LOCKED; \
            end

            `MAIN_STATE(1, 2)
            `MAIN_STATE(2, 3)
            `MAIN_STATE(3, 4)

            `undef MAIN_STATE

            // reset the lock
            S_4: begin
                resetLockDown = 1;
                nextState = S_DONE;
            end

            // initial state
            default: begin
                resetLockDown = 1;
                nextState = S_NORMAL;
            end
        endcase
    end

endmodule // SerialPasswordLock