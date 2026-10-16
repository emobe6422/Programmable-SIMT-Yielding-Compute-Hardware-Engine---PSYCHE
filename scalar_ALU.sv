`timescale 1ns / 1ps

/* Notes: 
 * - where should scc and exec exist?
 * - God knows how much extra hardware for multiplication???
 * - branch control and flag are diff things silly
 * -subi doesnt exist
 *
 */

module scalar_ALU(
    //control
    input logic [2:0] funct3,
    input logic [6:0] funct7, //only needed for y0 instructions
    input logic [4:0] alu_control, 
    //logic
    input  logic [31:0] scc,
    input  logic [31:0] exec,
    input  logic [31:0] data_in_1,
    input  logic [31:0] data_in_2,
    output logic        branch_flag,
    output logic [31:0] sum
    );
      
    always_comb begin
        sum         = 32'b0;
        branch_flag =  1'b0;
        
        case (alu_control)
            5'b00000 : sum = data_in_1 +  data_in_2; //add, addi
            5'b00001 : sum = data_in_1 ^  data_in_2; //xor, xori
            5'b00010 : sum = data_in_1 |  data_in_2; //or, ori
            5'b00011 : sum = data_in_1 &  data_in_2; //and, andi
            5'b00100 : sum = data_in_1 -  data_in_2; //sub
            5'b00101 : ; //multiplication goes here
            
            
            5'b00110 : sum = data_in_1 << data_in_2[4:0]; //sll + slli
            5'b00111 : sum = data_in_1 >> data_in_2[4:0]; //srl + srli
            5'b01000 : sum = $signed(data_in_1) >>> data_in_2[4:0]; //sra + srai
            5'b01001 : ; //CMP_EQ, LT, GE, LTU, GEU (funct3)
            5'b01010 : ; //LUI
            5'b01011 : ; //AUIPC
            5'b01100 :  //branch/cbranch
                case (funct7[3:0]) //only need the first 4 bits
                    4'b0000 : branch_flag = 1 ; //BRANCH
                    4'b0001 : branch_flag = (scc == 0)? 1 : 0 ; //CBRANCH_SCCZ
                    4'b0010 : branch_flag = (scc == 1)? 1 : 0 ; //CBRANCH_SCCNZ
                    4'b0011 : ;
                    4'b0100 : ;
                    4'b0101 : ;
                    4'b0110 : ;
                    4'b0111 : ; //BARRIER
                    4'b1000 : ; //WAIT_CNT
                    4'b1001 : ; //END_PGM
                    default : branch_flag = 0; 
                endcase           
            5'b01101 : ;
            5'b01110 : ;
            5'b01111 : ;
            5'b10000 : ;
            5'b10001 : ;
            5'b10010 : ;
            5'b10011 : ;
            5'b10110 : ;
            default: ;
        endcase
    end
endmodule

