#include <cstdint>
#include <cstdio>
#include <vector>
#include <iostream>
#include <bitset>
using namespace std;

/*
 * Notes: 
 * - Make sure x0 and x31 are hardwired to 0 and VCC
 * - takes the binary input and outputs what we need
 * - VCC can be explicitly written to since it's a register duh
 * - x31 is also exclusively reserved for VCC. Nothing else should go there
 */

struct WaveState {
    uint32_t sgpr[32];//x0 and x31 should be hardwired
    uint32_t exec;
    uint32_t pc;
    uint32_t scc; //zero-extended so as to be {{31'b0}, scc}
    //vgpr's
    bool done;
};

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


//Type wavestate here

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

//return type immediate_generator
ImmediateGenerator immediate (uint32_t instr) {
    ImmediateGenerator imm{}; //initializes all values to zero with the {}
    imm.instruction = instr;
    imm.r_type = 0; //no immediates for r type

    //i type - bits 31-20
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

WaveState wavestate () {
    WaveState w{}; //zero-initializes everything (the array too)
    w.exec = 0xFFFFFFFF;
    w.pc = 0;
    w.scc = 0; //zero-extended so as to be {{31'b0}, scc}
    //vgpr's
    w.done = false;
    return w;
}

/* 
 * Input the register index (x0 -> x31) you want 
 * to read from and output the register's data (32'b0)
 * Note: The 'register' keyword is off-limits. C++ stuff idk. 
 * Call 'register' idx instead.
 */
uint32_t scalar_reg_read(uint8_t idx, uint32_t scalar_registers[32]) {
    //register could be rs1 or rs2
    if (idx == 0) {
        return 0;
    } else if (idx > 0 && idx <= 31) {
        return scalar_registers[idx]; //VCC included
    } 
}

void scalar_reg_write(uint8_t idx, uint32_t data_in, uint32_t scalar_registers[32]) {
    if (idx == 0) {
        scalar_registers[0] = 0;
    } else if (idx > 0 && idx <= 31) {
        scalar_registers[idx] = data_in;
    }
}

//step function. Should fetch, decode, execute one instruction



int main() {
    //0x00000013 is NOP (addi x0 x0 0) so that way nothing happens
    vector<uint32_t> instruction_memory(1024, 0x00000013);

    return 0;
};
