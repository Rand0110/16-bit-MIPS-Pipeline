`timescale 1ns / 1ps
`default_nettype none

module control_unit (
    input wire [5:0] opcode,
    input wire [3:0] funct, // used for R-type if needed
    output reg reg_write,
    output reg alu_src,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg [2:0] alu_control
);
    always @(*) begin
        // Default all signals
        reg_write   = 0;
        alu_src     = 0;
        mem_read    = 0;
        mem_write   = 0;
        mem_to_reg  = 0;
        alu_control = 3'b000;

        case (opcode)
            6'b000000: begin // R-type
                reg_write = 1;
                alu_src   = 0;
                case (funct)
                    4'b0000: alu_control = 3'b000; // ADD
                    4'b0001: alu_control = 3'b001; // SUB
                    4'b0010: alu_control = 3'b100; // AND
                    4'b0011: alu_control = 3'b101; // OR
                    4'b0110: alu_control = 3'b111; // SLTU
                    default: alu_control = 3'b000; // default to ADD
                endcase
            end
            6'b001111: begin // LUI
                reg_write   = 1;
                alu_src     = 1;
                alu_control = 3'b110; // LUI operation
            end
           6'b100011: begin // LW
                reg_write   = 1;
                alu_src     = 1;
                mem_read    = 1;
                mem_to_reg  = 1;
                alu_control = 3'b000; // ADD for address calculation
            end
            6'b101011: begin // SW
                reg_write   = 0;
                alu_src     = 1;
                mem_write   = 1;
                alu_control = 3'b000; // ADD
            end
            6'b000100, // BEQ
            6'b000101: begin // BNE
                reg_write   = 0;
                alu_src     = 0;
                alu_control = 3'b001; // SUB
            end
            6'b000010, // J
            6'b000011: begin // JAL
                reg_write   = (opcode == 6'b000011); // only JAL writes
                alu_control = 3'b000; // don't care
            end
            6'b001000: begin // JR
                reg_write   = 0;
                alu_control = 3'b000; // don't care
            end
            // === New Instructions ===
            6'b001100: begin // ANDI
                reg_write   = 1;
                alu_src     = 1;
                alu_control = 3'b100; // AND
            end
            6'b001101: begin // ORI
                reg_write   = 1;
                alu_src     = 1;
                alu_control = 3'b101; // OR
            end
            6'b001010: begin // SLTU
                reg_write   = 1;
                alu_src     = 1;
                alu_control = 3'b111; // SLTU
            end
            6'b111111: begin // HALT
                reg_write   = 0;
                alu_control = 3'b000;
            end
        endcase
    end
endmodule
