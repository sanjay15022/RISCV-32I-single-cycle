`timescale 1ns/1ps

module tb_sieve;

    reg clk;
    integer i;
    integer cycles;
    integer errors;

    reg [7:0] expected [0:30];
    reg [7:0] got;

    main uut (.clk(clk));

    // Clock: 10 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("sieve.vcd");
        $dumpvars(0, tb_sieve);

        // Expected prime flags
        for (i = 0; i <= 30; i = i + 1)
            expected[i] = 0;

        expected[2]  = 1;
        expected[3]  = 1;
        expected[5]  = 1;
        expected[7]  = 1;
        expected[11] = 1;
        expected[13] = 1;
        expected[17] = 1;
        expected[19] = 1;
        expected[23] = 1;
        expected[29] = 1;

        #1;

        $display("========================================");
        $display("       RV32I SIEVE OF ERATOSTHENES");
        $display("========================================");

        cycles = 0;

        // Wait for completion flag at address 100
        while (uut.dmem1.dmemory[100] !== 8'h01 &&
               cycles < 1000) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        #1;

        if (uut.dmem1.dmemory[100] !== 8'h01) begin
            $display("FAIL: Timeout!");
            $display("PC = %08h", uut.pc);
            $finish;
        end

        errors = 0;

        $display("\nNumber | Actual | Expected");
        $display("--------------------------");

        for (i = 0; i <= 30; i = i + 1) begin

            got = uut.dmem1.dmemory[i];

            $display("%6d | %6d | %8d",
                     i, got, expected[i]);

            if (got !== expected[i])
                errors = errors + 1;
        end

        $display("\nPrime numbers:");

        for (i = 2; i <= 30; i = i + 1)
            if (uut.dmem1.dmemory[i] === 8'd1)
                $write("%0d ", i);

        $display("");

        $display("\nCycles: %0d", cycles);

        if (errors == 0)
            $display("PASS: All prime flags are correct!");
        else
            $display("FAIL: %0d incorrect flags", errors);

        $display("Final PC = %08h", uut.pc);

        $finish;
    end

endmodule