`timescale 1ns / 1ps
module ex_mem_reg (
    input clk,
    input reset,
    input [15:0] alu_result_in,
    input [15:0] reg_data2_in,
    input [3:0] rd_in,
    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,
    output reg [15:0] alu_result_out,
    output reg [15:0] reg_data2_out,
    output reg [3:0] rd_out,
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_out <= 0;
            reg_data2_out <= 0;
            rd_out <= 0;
            reg_write_out <= 0;
            mem_read_out <= 0;
            mem_write_out <= 0;
            mem_to_reg_out <= 0;
        end else begin
            alu_result_out <= alu_result_in;
            reg_data2_out <= reg_data2_in;
            rd_out <= rd_in;
            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule
