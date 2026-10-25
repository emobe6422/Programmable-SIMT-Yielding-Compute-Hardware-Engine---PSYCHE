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
            5'b00000 : sum = data_in_1 +  data_in_2; //ADD, ADDI
            5'b00001 : sum = data_in_1 ^  data_in_2; //XOR, XORI
            5'b00010 : sum = data_in_1 |  data_in_2; //OR, ORI
            5'b00011 : sum = data_in_1 &  data_in_2; //AND, ANDI
            5'b00100 : sum = data_in_1 -  data_in_2; //SUB
            5'b00101 : ; //MUL
            5'b00110 : ; //MULQ
            5'b00111 : sum = data_in_1 << data_in_2[4:0]; //SLL, SLLI
            5'b01000 : sum = data_in_1 >> data_in_2[4:0]; //SRL, SRLI
            5'b01001 : sum = $signed(data_in_1) >>> data_in_2[4:0]; //SRA, SRAI
            //set SCC
            5'b01010 : ; //CMP_EQ, LT, GE, LTU, GEU (funct3)
            5'b01011 : ; //LUI
            5'b01100 : ; //AUIPC    
            5'b01101 :  //branch/cbranch
                case (funct7[3:0]) //only need the first 4 bits
                    4'b0000 : branch_flag = 1 ; //BRANCH
                    4'b0001 : branch_flag = (scc == 0)? 1 : 0 ; //CBRANCH_SCCZ
                    4'b0010 : branch_flag = (scc == 1)? 1 : 0 ; //CBRANCH_SCCNZ
                    4'b0011 : ; //CBRANCH_VCC
                    4'b0100 : ; //CBRANCH_VCCNZ
                    4'b0101 : ; //CBRANCH_EXEC
                    4'b0110 : ; //CBRANCH_EXECNZ
                    default : branch_flag = 0; 
                endcase  
            5'b01110 : ; //BARRIER
            5'b01111 : ; //WAIT_CNT
            5'b10000 : ; //END_PGM
            5'b10001 : ; //CBRANCH_I_FORK
            5'b10010 : ; //CMOV
            5'b10011 : ; //CBRANCH_JOIN
            5'b10100 : ; //ABSOLUTE
            5'b10101 : ; //JAL
            5'b10110 : ; //JALR
            default: ;
        endcase
    end
endmodule

