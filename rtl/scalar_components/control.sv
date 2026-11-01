`timescale 1ns/1ps

/* Notes: 
 * - Removal of slt, sltu, slti, sltiu since cmp r1, r2 fulfills a similar task
 * - the default cases
 *
 */

module control#(
    //load/stores very up in the air
    parameter immediate_opcode  = 7'b0010011,
    parameter arithmetic_opcode = 7'b0110011,
    parameter lui_opcode        = 7'b0110111,
    parameter auipc_opcode      = 7'b0010111,
    parameter y0_opcode         = 7'b1100011, //just reuse it; I deleted the normal branching
    parameter y1_opcode         = 7'b1111110, 
    parameter y2_opcode         = 7'b1111111
    )(  
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
        
        
        
    output logic branch_control, reg_write, alu_src,
    output logic [4:0] alu_control
    );
    
    always_comb begin
        branch_control =  0;
        reg_write      =  0;
        alu_src        =  0;
        alu_control    =  5'b0;
        //any more stuff needed
        
        case (opcode)
        
            //AND, OR, XOR, ADD, SUB, MULT, SLL, SRL, SRA
            arithmetic_opcode : begin
                //some sort of reg_write
                case (funct3) 
                    3'b000 : //add/sub
                        case (funct7) 
                            7'b0100000 : alu_control = 5'b00100; //sub
                            default    : alu_control = 5'b00000; //default to add (7'b0)
                        endcase
                    3'b001  : alu_control = 5'b00110; //sll
                    3'b010  : alu_control = 5'b00101; //reused a removed instruction's funct3 for mult
                    //011 maybe for one more mult instruction?
                    3'b100  : alu_control = 5'b00001; //xor
                    3'b101 :  //srl/sra
                        case (funct7) 
                            7'b0100000 : alu_control = 5'b01000; //sra
                            default    : alu_control = 5'b00111; //default to srl (7'b0)
                        endcase
                    3'b110  : alu_control = 5'b00010; //or
                    3'b111  : alu_control = 5'b00011; //and
                    default : alu_control = 5'b00000; //default
                endcase
            end
            
            //ANDI, ORI, XORI, ADDI, MULTI, SLLI, SRLI, SRAI
            immediate_opcode : begin
                //some sort of reg_write
                alu_src = 1'b1;
                case (funct3) 
                    3'b000 : alu_control = 5'b00000; //addi
                endcase
            end
            
            //CBRANCH_{SCCZ/NZ, VCCZ/NZ, EXECZ/NZ}, BRANCH, BARRIER, WAIT_CNT, ENDPGM}
            y0_opcode : ;
            //CBRANCH_I_FORK, CMOV
            y1_opcode : ;
            //CBRANCH_JOIN, ABS
            y2_opcode : ;
        
        
        
            default : begin
                branch_control = 0;
                reg_write      = 0;
                alu_src        = 0;
                alu_control    = 5'b0;
            end
        endcase
    end
endmodule
