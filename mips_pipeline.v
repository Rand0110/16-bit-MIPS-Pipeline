`timescale 1ns / 1ps
`default_nettype none

module mips_pipeline (
    input clk,
    input reset,
    output [15:0] instr,
    output [15:0] if_id_instr,
    output [15:0] id_ex_reg_data1,
    output [15:0] ex_mem_alu_result,
    output [15:0] write_back_data
);
    // Internal control
    wire stall;
    reg [15:0] pc;
    reg [15:0] data_mem [0:255];

    // IF Stage
    reg [15:0] if_id_instr_reg;
    wire [5:0] opcode = if_id_instr_reg[15:10];
    wire [3:0] rs = if_id_instr_reg[9:6];
    wire [3:0] rt = if_id_instr_reg[5:2];
    wire [3:0] rd = if_id_instr_reg[3:0];
    wire zero_extend = (opcode == 6'b001100 || opcode == 6'b001101 || opcode == 6'b001010);
    wire [15:0] imm_ext = zero_extend ? {8'd0, if_id_instr_reg[7:0]} :
                                        {{8{if_id_instr_reg[7]}}, if_id_instr_reg[7:0]};

    wire [15:0] branch_offset = imm_ext;
    wire [15:0] branch_target = pc + 1 + branch_offset;
    wire [15:0] jump_target = {pc[15:10], if_id_instr_reg[9:0]};

    wire is_branch = (opcode == 6'b000100);
    wire is_bne    = (opcode == 6'b000101);
    wire is_jump   = (opcode == 6'b000010);
    wire is_jal    = (opcode == 6'b000011);
    wire is_jr     = (opcode == 6'b001000);
    wire is_halt   = (opcode == 6'b111111);

    wire is_i_type = (opcode == 6'b001111 || opcode == 6'b000101 || opcode == 6'b000100 ||
                      opcode == 6'b001100 || opcode == 6'b001101 || opcode == 6'b001010);
    wire [15:0] reg_data1, reg_data2;
    wire branch_taken = (is_branch && (reg_data1 == reg_data2)) || (is_bne && (reg_data1 != reg_data2));
    wire [15:0] jr_target = reg_data1;
    wire [15:0] pc_plus1 = pc + 1;
    wire [15:0] pc_next = is_halt ? pc :
                          is_jr   ? jr_target :
                          is_jal  ? jump_target :
                          is_jump ? jump_target :
                          branch_taken ? branch_target :
                          pc_plus1;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 16'd0;
        else if (!stall)
            pc <= pc_next;
        if (is_halt) begin
            $display("HALT encountered at PC=%0d", pc);
            rf.print_registers();
            $finish;
        end
    end

    wire [15:0] fetched_instr;
    instr_mem imem (
        .addr(pc),
        .instr(fetched_instr)
    );
    assign instr = fetched_instr;

    always @(posedge clk or posedge reset) begin
        if (reset)
            if_id_instr_reg <= 16'd0;
        else if (branch_taken || is_jump || is_jal || is_jr)
            if_id_instr_reg <= 16'd0;
        else if (!stall)
            if_id_instr_reg <= fetched_instr;
    end
    assign if_id_instr = if_id_instr_reg;

    wire reg_write_wb;
    wire [3:0] mem_wb_rd;

    wire [15:0] jal_link = pc_plus1;
    wire is_r_type = (opcode == 6'b000000);
    
    wire [3:0] wb_dest = is_jal ? 4'd15 :
                  is_i_type ? rt :
                  is_r_type ? rd :
                  4'd0;
    wire [3:0] dest_reg = wb_dest;

    reg_file rf (
        .clk(clk),
        .reg_write(reg_write_wb),
        .rs(rs),
        .rt(rt),
        .rd(mem_wb_rd),
        .write_data(write_back_data),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    wire reg_write, alu_src, mem_read, mem_write, mem_to_reg;
    wire [2:0] alu_control;


    control_unit cu (
        .opcode(opcode),
        .funct(rd),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_control(alu_control)
    );

    wire id_ex_mem_read;
    wire [3:0] id_ex_rt;

    hazard_detection_unit hdu (
        .id_rs(rs),
        .id_rt(rt),
        .ex_rt(id_ex_rt),
        .ex_mem_read(id_ex_mem_read),
        .stall(stall)
    );

    wire [15:0] id_ex_reg_data2, id_ex_sign_ext;
    wire [2:0] id_ex_alu_control;
    wire id_ex_reg_write, id_ex_mem_write, id_ex_mem_to_reg, id_ex_alu_src;
    wire [3:0] id_ex_rs, id_ex_rd;

    id_ex_reg id_ex (
        .clk(clk), .reset(reset),
        .reg_data1_in(reg_data1),
        .reg_data2_in(reg_data2),
        .sign_ext_in(imm_ext),
        .rs_in(rs), 
        .rt_in(rt), 
        .rd_in(wb_dest),
        .alu_control_in(alu_control),
        .reg_write_in(reg_write),
        .mem_read_in(mem_read),
        .mem_write_in(mem_write),
        .mem_to_reg_in(mem_to_reg),
        .alu_src_in(alu_src),
        .reg_data1_out(id_ex_reg_data1),
        .reg_data2_out(id_ex_reg_data2),
        .sign_ext_out(id_ex_sign_ext),
        .rs_out(id_ex_rs), 
        .rt_out(id_ex_rt), 
        .rd_out(id_ex_rd),
        .alu_control_out(id_ex_alu_control),
        .reg_write_out(id_ex_reg_write),
        .mem_read_out(id_ex_mem_read),
        .mem_write_out(id_ex_mem_write),
        .mem_to_reg_out(id_ex_mem_to_reg),
        .alu_src_out(id_ex_alu_src)
    );

    wire [1:0] forward_a, forward_b;
    wire mem_wb_reg_write;
    wire [3:0] ex_mem_rd;
    wire ex_mem_reg_write;

    forwarding_unit fwd (
        .id_ex_rs(id_ex_rs), 
        .id_ex_rt(id_ex_rt),
        .ex_mem_rd(ex_mem_rd), 
        .mem_wb_rd(mem_wb_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a), 
        .forward_b(forward_b)
    );

    wire [15:0] alu_result;
    wire [15:0] forwarded_a = (forward_a == 2'b10) ? ex_mem_alu_result :
                              (forward_a == 2'b01) ? write_back_data : id_ex_reg_data1;
    wire [15:0] forwarded_b = (forward_b == 2'b10) ? ex_mem_alu_result :
                              (forward_b == 2'b01) ? write_back_data : id_ex_reg_data2;
    wire [15:0] alu_in2 = id_ex_alu_src ? id_ex_sign_ext : forwarded_b;

    alu alu_unit (
        .in1(forwarded_a),
        .in2(alu_in2),
        .alu_control(id_ex_alu_control),
        .result(alu_result),
        .zero()
    );

    wire [15:0] ex_mem_reg_data2;
    wire ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg;

    always @(posedge clk) begin
        if (ex_mem_mem_read)
            $display("MEM: LW addr=%0d → data=0x%04h", ex_mem_alu_result, data_mem[ex_mem_alu_result]);
    end

    ex_mem_reg ex_mem (
        .clk(clk), .reset(reset),
        .alu_result_in(alu_result),
        .reg_data2_in(forwarded_b),
        .rd_in(id_ex_rd),
        .reg_write_in(id_ex_reg_write),
        .mem_read_in(id_ex_mem_read),
        .mem_write_in(id_ex_mem_write),
        .mem_to_reg_in(id_ex_mem_to_reg),
        .alu_result_out(ex_mem_alu_result),
        .reg_data2_out(ex_mem_reg_data2),
        .rd_out(ex_mem_rd),
        .reg_write_out(ex_mem_reg_write),
        .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write),
        .mem_to_reg_out(ex_mem_mem_to_reg)
    );

    
    reg [15:0] mem_read_data;
    initial begin
        data_mem[4] = 16'h0F00; // for LW test
    end

    always @(posedge clk) begin
        if (ex_mem_mem_write) begin
            if (ex_mem_alu_result == 16'hFFFC) begin
                $display("MMIO OUTPUT: %0d (0x%04h)", ex_mem_reg_data2, ex_mem_reg_data2);
            end else begin
                data_mem[ex_mem_alu_result] <= ex_mem_reg_data2;
            end
        end
        if (ex_mem_mem_read) begin
            mem_read_data <= data_mem[ex_mem_alu_result];
        end
    end

    wire [15:0] mem_wb_read_data, mem_wb_alu_result;
    wire mem_wb_mem_to_reg;

    mem_wb_reg mem_wb (
        .clk(clk), .reset(reset),
        .read_data_in(mem_read_data),
        .alu_result_in(ex_mem_alu_result),
        .rd_in(ex_mem_rd),
        .reg_write_in(ex_mem_reg_write),
        .mem_to_reg_in(ex_mem_mem_to_reg),
        .read_data_out(mem_wb_read_data),
        .alu_result_out(mem_wb_alu_result),
        .rd_out(mem_wb_rd),
        .reg_write_out(reg_write_wb),
        .mem_to_reg_out(mem_wb_mem_to_reg)
    );

    assign write_back_data = mem_wb_mem_to_reg ? mem_wb_read_data : mem_wb_alu_result;

endmodule
