`timescale 1ns / 1ps

/*
 * Notes:
 * - Think of ways to randomize R and I type tests
 * - Then add CMP instructions + work on emulator more
 * - 
 * - automate
 * 
 */


module tb_scalar_loop();
    logic clk, rst_n;
    logic [31:0] instruction;
    
    scalar_loop dut(
        .clk(clk),
        .rst_n(rst_n),
        .instruction(instruction)
    );
    
    task automatic r_type_run_instr(
        input logic [31:0] instr, 
        input logic [31:0] data_1, 
        input logic [31:0] data_2,
        );
        //since theres no loads or stores yet, I need to manually inject values into the registers
        instruction = instr;
        dut.scalar_reg_file.scalar_registers[2] = reg_value_1;
        dut.scalar_reg_file.scalar_registers[3] = reg_value_2;
        @(posedge clk);
        #1;
    endtask
    
    always #5 clk = ~clk; //100MHz clock
    
    initial begin
        clk = 0; //clk had to be initialized
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        instruction = 32'h003100b3; //add x1 x2 x3
        r_type_run_instr(instruction, 5, 10);
        
        $display("opcode : %b", dut.opcode);
        $display(" rs1: %d, rs2: %d, rd: %d", dut.rs1, dut.rs2, dut.rd);
        $display("funct3: %b, funct7: %b", dut.funct3, dut.funct7);
        $display("alu_control: %b", dut.alu_control);
        $display("data 1: %d, data 2: %d", dut.data_out_1, dut.data_2_mux);
        $display("output: %d", dut.sum);
        $display("output again: %d", dut.scalar_reg_file.scalar_registers[1]);
         
    
    
        $finish;
    end
endmodule
