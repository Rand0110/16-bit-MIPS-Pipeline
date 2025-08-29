`timescale 1ns / 1ps
module hazard_detection_unit (
    input [3:0] id_rs,
    input [3:0] id_rt,
    input [3:0] ex_rt,
    input ex_mem_read,
    output reg stall
);
    always @(*) begin
        if (ex_mem_read && ((ex_rt == id_rs) || (ex_rt == id_rt)))
            stall = 1;
        else
            stall = 0;
    end
endmodule
