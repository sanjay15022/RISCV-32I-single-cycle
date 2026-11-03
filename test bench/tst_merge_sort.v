`timescale 1ns/1ps

module tb_merge_sort_sc;
    reg clk;
    integer cycles;
    integer i;
    integer errors;
    reg signed [31:0] got;
    reg signed [31:0] expected [0:7];

    main uut (.clk(clk));

    // 10 ns clock period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("merge_sort_sc.vcd");
        $dumpvars(0, tb_merge_sort_sc);

        expected[0] = -9;
        expected[1] = -5;
        expected[2] =  0;
        expected[3] =  3;
        expected[4] =  4;
        expected[5] =  7;
        expected[6] = 12;
        expected[7] = 12;

        // instr_reg.v automatically loads program.hex at time 0.
        // The program initializes its own input array in data memory.
        // It writes 1 to byte address 108 when sorting is complete.
        cycles = 0;

        $display("========================================");
        $display("      RISC-V SINGLE-CYCLE MERGE SORT");
        $display("========================================");
        $display("Input : 12, -5, 7, 3, 12, 0, -9, 4");
        $display("Expect: -9, -5, 0, 3, 4, 7, 12, 12");

        // Wait for completion flag or timeout.
        while ((uut.dmem1.dmemory[108] !== 8'h01) && (cycles < 5000)) begin
            @(posedge clk);
            cycles = cycles + 1;
        end
        #1;

        if (uut.dmem1.dmemory[124] !== 8'h01) begin
            $display("\nFAIL: timeout; completion flag was not written.");
            $display("PC = %08h", uut.pc);
            $display("Check that program.hex is in the simulator working directory.");
            $finish;
        end

        errors = 0;
        $display("\n---------- SORTED ARRAY ----------");
        for (i = 0; i < 8; i = i + 1) begin
            got = {
                uut.dmem1.dmemory[4*i+3],
                uut.dmem1.dmemory[4*i+2],
                uut.dmem1.dmemory[4*i+1],
                uut.dmem1.dmemory[4*i]
            };
            $display("A[%0d] = %0d", i, got);
            if (got !== expected[i]) begin
                $display("  MISMATCH: expected %0d", expected[i]);
                errors = errors + 1;
            end
        end

        $display("\n------------- RESULT -------------");
        if (errors == 0)
            $display("PASS: all 8 elements are correctly sorted.");
        else
            $display("FAIL: %0d incorrect elements.", errors);
        $display("Cycles: %0d", cycles);
        $display("Final PC: %08h", uut.pc);
        $finish;
    end
endmodule
