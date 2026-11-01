`timescale 1ns / 1ps
/*
 * Notes:
 * - possible conflict with the naming for the reg and alu ports
 * - the way i type my rtl lowk looks hella bot but its more readable to me lol
 * - add to control the logic to make the SCC_write
 */

module scalar_loop #(
    parameter I_opcode  = 7'b0010011,
    parameter S_opcode  = 7'b0100011,
    parameter U_opcode  = 7'b0110111,
    parameter J_opcode  = 7'b1101111,
    parameter y0_opcode = 7'b1100011,
    parameter y1_opcode = 7'b1111110,
    parameter y2_opcode = 7'b1111110
    )
    (
    input logic clk, rst_n
    );
    
    /* ---- shared logic ---- */
    logic [31:0] instruction;
    logic [4:0]  rs1, rs2, rd;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic        reg_write;
    logic [4:0]  alu_control;
      
    /* ---- decoder ---- */
    logic [6:0]  opcode;
    //instruction
    //rd, rs1, rs2
    //funct3
    //funct7
    

    /* ---- control ---- */
    logic branch_control, mem_read, mem_to_reg, mem_write, alu_src;
    logic jump, jalr_sel, jal_sel, pc_sel;
    //opcode
    //funct3
    //funct7
    //reg_write
    //alu_control
    
    /* ---- scalar_reg_file ---- */
    logic [31:0] data_in; //CURRENTLY DOING NOTHING!!!!!!!!!!!
    logic [31:0] data_out_1, data_out_2;  
    //rd, rs1, rs2
    //reg_write
    
    /* ---- immediate generator ---- */
    logic [31:0] I_immediate;
    logic [31:0] S_immediate;
    logic [31:0] U_immediate;
    logic [31:0] J_immediate;
    logic [31:0] y0_immediate;
    //instruction
    
    
    /* ---- SCC ---- */
    logic        SCC_write;
    logic [31:0] SCC_data_in;
    logic [31:0] SCC_data_out;
    
    /* ---- EXEC ---- */
    /*
     *
     *
     *
     *
     */
    
    /* ---- scalar_ALU ---- */
    logic [31:0] scc;
    logic [31:0] exec;
    logic [31:0] data_in_1;
    logic [31:0] data_in_2;
    logic        branch_flag;
    logic [31:0] sum;
    //funct3
    //funct7
    //alu_control
     
     decoder decoder(
         .instruction(instruction),
         .opcode(opcode),
         .rd(rd), 
         .rs1(rs1), 
         .rs2(rs2),
         .funct3(funct3),
         .funct7(funct3)
     );
     
     control control(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .branch_control(branch_control), 
        .mem_read(mem_read), 
        .mem_to_reg(mem_to_reg), 
        .mem_write(mem_write), 
        .alu_src(alu_src), 
        .reg_write(reg_write),
        .alu_control(alu_control),
        .jump(jump), 
        .jalr_sel(jalr_sel), 
        .jal_sel(jal_sel),
        .pc_sel(pc_sel) 
     );
     
    imm_gen imm_gen(
        .instruction(instruction),
        .I_immediate(I_immediate),
        .S_immediate(S_immediate),
        .U_immediate(U_immediate),
        .J_immediate(J_immediate),
        .y0_immediate(y0_immediate)
    );
    
        scalar_reg_file scalar_reg_file(
        .clk(clk),
        .reg_write(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .data_in(sum), //TEMPORARY!!!!!!!!!!!
        .data_out_1(data_out_1),
        .data_out_2(data_out_2)
    );
    
    SCC SCC(
        .clk(clk),
        .SCC_write(SCC_write),
        .SCC_data_in(SCC_data_in),
        .SCC_data_out(SCC_data_out)
    );
    
    /*immediate selection */
    logic [31:0] immediate; 
    assign immediate = (opcode == I_opcode)  ?  I_immediate :
                       (opcode == S_opcode)  ?  S_immediate :
                       (opcode == U_opcode)  ?  U_immediate :
                       (opcode == J_opcode)  ?  J_immediate :
                        y0_immediate;
                        //ADD Y1 AND Y2 IMMEDIATES
                       
    /*multiplexor to decide between immediate or data_out_2*/
    logic [31:0] data_2_mux;
    assign data_2_mux = (alu_src == 0) ? data_out_2 : immediate; 
    
    scalar_ALU scalar_ALU(
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control),
        .scc(), // HERE!!!!!!!!!!!
        .exec(), //HERE!!!!!!!!!!!
        .data_in_1(data_out_1),
        .data_in_2(data_2_mux),
        .branch_flag(branch_flag),
        .sum(sum)
    );
endmodule
