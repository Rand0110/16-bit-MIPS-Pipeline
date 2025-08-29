`timescale 1ns / 1ps
module alu (
    input [15:0] in1, in2,
    input [2:0] alu_control,
    output reg [15:0] result,
    output zero
);
    always @(*) begin
        case (alu_control)
            3'b000: result = in1 + in2;
            3'b001: result = in1 - in2;
            3'b010: result = in1 & in2;
            3'b011: result = in1 | in2;
            3'b100: result = (in1 < in2) ? 16'd1 : 16'd0;
            3'b110: result = {in2[7:0], 8'b0}; // LUI: shift left 8 bits
            default: result = 16'b0;
        endcase
    end
    assign zero = (result == 0);
endmodule
