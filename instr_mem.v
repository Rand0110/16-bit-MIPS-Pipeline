`timescale 1ns / 1ps
`default_nettype none

module instr_mem (
    input  [15:0] addr,
    output [15:0] instr
);
    reg [15:0] memory [0:255];

    initial begin
        // Clear memory
        integer i;
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 16'h0000;

        // === LUI & ANDI / ORI / SLTU test ===
        memory[0] = 16'b0011110011001111; // lui r3, 0x0F
        memory[1] = 16'b0011000110001111; // andi r4, r3, 0x0F
        memory[2] = 16'b0011010110001111; // ori r5, r3, 0x0F
        memory[3] = 16'b0000000110100110; // sltu r6, r3, r5

        // === LW test (data_mem[4] = 0x0F00 expected) ===
        memory[4] = 16'b0001010001000100; // addi r1, r0, 4
        memory[5] = 16'b1000110001000010; // lw r2, 0(r1)

        // === ADDI / BNE test ===
        memory[6] = 16'b0001010010001010; // addi r2, r0, 10
        memory[7] = 16'b0001010011001011; // addi r3, r0, 11
        memory[8] = 16'b0001010010000001; // bne r2, r3, +1 (taken)
        memory[9] = 16'b0011110000001111; // skipped if branch taken

        // === SLT test with signed comparison ===
        memory[10] = 16'b0001010100111111; // addi r4, r0, -1
        memory[11] = 16'b0000000100100101; // slt r5, r4, r2

        // === SW + MMIO test ===
        memory[12] = 16'b0001010110000100; // addi r6, r0, 4
        memory[13] = 16'b0001010010001010; // addi r2, r0, 10
        memory[14] = 16'b0010100100000110; // sw r2, 0(r6) — writes to mem[4]

        // === HALT ===
        memory[15] = 16'b1111110000000000;


    end

    assign instr = memory[addr];
endmodule
