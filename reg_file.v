`timescale 1ns / 1ps
module reg_file (
    input clk,
    input reg_write,
    input [3:0] rs, rt, rd,
    input [15:0] write_data,
    output [15:0] read_data1, read_data2
);
    reg [15:0] regs [0:15];
    integer i;

    initial begin
        for (i = 0; i < 16; i = i + 1)
            regs[i] = 16'd0;
    end

    assign read_data1 = regs[rs];
    assign read_data2 = regs[rt];

    always @(posedge clk) begin
        if (reg_write)
            regs[rd] <= write_data;
    end

    task print_registers;
        integer i;
        begin
            $display("\n=== Final Register File State ===");
            for (i = 0; i < 16; i = i + 1)
                $display("r%0d = %0d (0x%04h)", i, regs[i], regs[i]);
        end
    endtask

endmodule
