`timescale 1ns / 1ps

/* Notes:
 * - Need to add branching conditions
 */

module program_counter(
    input logic clk, rst_n,
    output logic [31:0] PC
    );
    
    logic [31:0] next_PC;
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            PC <= '0;
        end else begin
            PC <= next_PC;
        end
    end   
    
    always_comb begin 
        //stuff here (branching etc)
        next_PC = PC + 4;
    end   
endmodule



/*module program_counter(
    input wire branch_mux_signal,
    input wire jump,
    input wire jalr_sel,
    input wire [31:0] B_immediate,
    input wire [31:0] J_immediate,
    input wire [31:0] PC,
    input wire [31:0] sum,
    output reg [31:0] next_PC
);
    always @(*) begin
        if (jalr_sel)
            next_PC = sum;
        else if (jump)
            next_PC = PC + J_immediate;
        else if (branch_mux_signal)
            next_PC = PC + B_immediate;
        else
            next_PC = PC + 4;
    end
endmodule*/
