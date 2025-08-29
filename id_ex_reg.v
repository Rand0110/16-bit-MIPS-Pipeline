`timescale 1ns / 1ps
module id_ex_reg (
    input clk,
    input reset,
    input [15:0] reg_data1_in, reg_data2_in, sign_ext_in,
    input [3:0] rs_in,
    input [3:0] rt_in,
    input [3:0] rd_in,
    input [2:0] alu_control_in,
    input reg_write_in, mem_read_in, mem_write_in, mem_to_reg_in, alu_src_in,
    output reg [15:0] reg_data1_out, reg_data2_out, sign_ext_out,
    output reg [3:0] rs_out, rt_out,
    output reg [3:0] rd_out,
    output reg [2:0] alu_control_out,
    output reg reg_write_out, mem_read_out, mem_write_out, mem_to_reg_out, alu_src_out
);
    reg [3:0] temp_rd;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_data1_out <= 0;
            reg_data2_out <= 0;
            sign_ext_out <= 0;
            rs_out <= 0;
            rt_out <= 0;
            rd_out <= 0;
            alu_control_out <= 0;
            reg_write_out <= 0;
            mem_read_out <= 0;
            mem_write_out <= 0;
            mem_to_reg_out <= 0;
            alu_src_out <= 0;
        end else begin
            reg_data1_out <= reg_data1_in;
            reg_data2_out <= reg_data2_in;
            sign_ext_out <= sign_ext_in;
            rs_out <= rs_in;
            rt_out <= rt_in;
            rd_out <= rd_in;
            temp_rd = rd_in;
            alu_control_out <= alu_control_in;
            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_src_out <= alu_src_in;
        end
        
    end
endmodule
