`timescale 1ns / 1ps
`default_nettype none

module mips_pipeline_tb;

    reg clk = 0;
    reg reset = 1;
    integer i;
    integer cycle = 0;

    // Clock generation
    always #5 clk = ~clk;

    // DUT instantiation with all debug outputs connected
    wire [15:0] instr, if_id_instr, id_ex_reg_data1, ex_mem_alu_result, write_back_data;

    mips_pipeline dut (
        .clk(clk),
        .reset(reset),
        .instr(instr),
        .if_id_instr(if_id_instr),
        .id_ex_reg_data1(id_ex_reg_data1),
        .ex_mem_alu_result(ex_mem_alu_result),
        .write_back_data(write_back_data)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, mips_pipeline_tb);

        #10 reset = 0;

        for (cycle = 0; cycle < 50; cycle = cycle + 1) begin
            @(posedge clk);
            $display("Cycle %0d:", cycle);
            $display("  IF  stage: %b", instr);
            $display("  ID  stage: %b", if_id_instr);
            $display("  EX  stage: %b", id_ex_reg_data1);
            $display("  MEM stage: %b", ex_mem_alu_result);
            $display("  WB  stage: %b", write_back_data);
        end

        #10;
        $display("Calling print_registers...");
        dut.rf.print_registers();
    end

endmodule
