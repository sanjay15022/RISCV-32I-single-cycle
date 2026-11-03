`timescale 1ns/1ps

module tb_fibonacci;

    reg clk;
    integer i;
    integer cycles;
    integer errors;

    reg [31:0] expected [0:24];
    reg [31:0] got;

    main uut (.clk(clk));

    // 10 ns clock period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("fibonacci.vcd");
        $dumpvars(0, tb_fibonacci);

        // Expected Fibonacci sequence
        expected[0]  = 0;
        expected[1]  = 1;
        expected[2]  = 1;
        expected[3]  = 2;
        expected[4]  = 3;
        expected[5]  = 5;
        expected[6]  = 8;
        expected[7]  = 13;
        expected[8]  = 21;
        expected[9]  = 34;
        expected[10] = 55;
        expected[11] = 89;
        expected[12] = 144;
        expected[13] = 233;
        expected[14] = 377;
        expected[15] = 610;
        expected[16] = 987;
        expected[17] = 1597;
        expected[18] = 2584;
        expected[19] = 4181;
        expected[20] = 6765;
        expected[21] = 10946;
        expected[22] = 17711;
        expected[23] = 28657;
        expected[24] = 46368;

        // Wait for instruction memory initialization
        #1;

        // Completion flag initialization
        uut.dmem1.dmemory[124] = 8'h00;

        $display("========================================");
        $display("       RISC-V FIBONACCI TEST");
        $display("========================================");

        cycles = 0;

        // Wait for program completion
        while (uut.dmem1.dmemory[124] !== 8'h01 &&
               cycles < 1000) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        #1;

        if (uut.dmem1.dmemory[124] !== 8'h01) begin
            $display("FAIL: Timeout!");
            $display("PC = %08h", uut.pc);
            $finish;
        end

        errors = 0;

        $display("\n-------- FIBONACCI RESULTS --------");

        for (i = 0; i < 25; i = i + 1) begin

            got = {
                uut.dmem1.dmemory[4*i+3],
                uut.dmem1.dmemory[4*i+2],
                uut.dmem1.dmemory[4*i+1],
                uut.dmem1.dmemory[4*i]
            };

            $display("F[%0d] = %0d", i, got);

            if (got !== expected[i]) begin
                $display("  Expected: %0d", expected[i]);
                errors = errors + 1;
            end
        end

        $display("\n-------- TEST RESULT --------");

        if (errors == 0)
            $display("PASS: All 25 Fibonacci numbers correct!");
        else
            $display("FAIL: %0d mismatches", errors);

        $display("Cycles: %0d", cycles);

        $finish;
    end

endmodule