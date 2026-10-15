#include <cstdint>
#include <cstdio>
#include <vector>
#include <iostream>
#include <bitset>
using std::cout;
using std::bitset;


/*
* Notes:
* - R and B types first
* - Loop labels down the line (label_1, etc.)
* - need to eventually support Q16.16, 2s complement #s as well
* - scalar registers denoted with x, vector registers denoted with v.
*/
//uint32_t instruction;

struct DecodeInstruction {
    uint32_t instruction;
    //no IMM since thats done elsewhere
    uint8_t opcode; //7 bits
    uint8_t rd;     //5 bits
    uint8_t funct3; //3 bits
    uint8_t funct7; //7 bits
    uint8_t rs1;    //5 bits
    uint8_t rs2;    //5 bits
    //immediate?
};

struct ImmediateGenerator {
    /* takes in instruction, outputs the corresponding immediate
     * and also a flag for what instruction type it was.
     */
    uint32_t instruction;
    int32_t r_type; //?? be careful about testing this one
    int32_t i_type;
    int32_t s_type;
    int32_t u_type;
    int32_t j_type;
    int32_t y0_type;
    int32_t y1_type;
    int32_t y2_type;
    //some sort of flag to indicate the type chosen
};

//return type immediate_generator
    ImmediateGenerator immediate (uint32_t instr) {
        ImmediateGenerator imm{}; //initializes all values to zero with the {}
        imm.instruction = instr;
        //r type :p

        imm.r_type = 0; //no immediates for r type

        //i type
        //bits 31-20
        imm.i_type = ((int32_t)instr) >> 20;

        //s type

        //u type

        //j type

        //y0 type
        imm.y0_type = (int32_t)(int16_t)((instr >> 7) & 0xFFFF); //yeah idek 

        //y1 type

        //y2 type

        return imm;
    }
    DecodeInstruction decode (uint32_t instr) {
        DecodeInstruction d{};
        d.instruction = instr;
        d.opcode = instr & 0x7F;
        d.rd = (instr >> 7) & 0x1F;
        d.funct3 = (instr >> 12) & 0x7;
        d.funct7 = (instr >> 25) & 0x7F;
        d.rs1 = (instr >> 15) & 0x1F;
        d.rs2 = (instr >>  20) & 0x1F; 
        return d;
    }
int main() {
    uint32_t test_instruction = 0x003100b3;
    ImmediateGenerator imm = immediate(test_instruction);
    DecodeInstruction de = decode(test_instruction);
    //funct3, funct7, rs1, rs2, rd, opcode
    cout << "opcode: " << bitset<7>(de.opcode) << "\n";
    cout << "rd: "     << bitset<5>(de.rd)     << "\n";
    cout << "funct3: " << bitset<3>(de.funct3) << "\n";
    cout << "funct7: " << bitset<7>(de.funct7) << "\n";
    cout << "rs1: "    << bitset<5>(de.rs1)    << ", rs2: " << bitset<5>(de.rs2) << "\n";
    //immediates
    cout << "r type: " << imm.r_type << ", i type: " << imm.i_type << "\n";

    return 0;
}
