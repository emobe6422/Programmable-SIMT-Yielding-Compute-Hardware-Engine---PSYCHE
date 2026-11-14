#include <cstdint>
#include <cstdio>
#include <vector>
#include <iostream>
#include <algorithm>
#include <bitset>
using namespace std;

#define  R_INSTRUCTION 0b0110011
#define  I_INSTRUCTION 0b0010011 //except LW and JALR
#define  S_INSTRUCTION 0b0100011
#define  U_INSTRUCTION 0b0110111
#define  J_INSTRUCTION 0b1101111
//define Y0_OPCODE 0b
//define Y1_OPCODE 0b
//define Y2_OPCODE 0b
#define REG_SIZE 32
#define MEMORY_DEPTH 64

/**
* Notes: 
* - Make sure x0 is hardwired to 0
* - takes the binary input and outputs what we need
* - VCC can be explicitly written to since it's a register duh
* - x31 is also exclusively reserved for VCC. Nothing else should go there
* - fix  slli, srli, srai
* - Use the scalar reg read and write methods
* - What to do about i types for scalar_reg_r/w
* - how to efficiently throw errors?
* - Q16.16 for EVERYTHING???
* - Double check the last instruction for the while loop that its executed
*/

struct WaveState {
    uint32_t sgpr[REG_SIZE];//x0 and should be hardwired
    uint32_t exec;
    uint32_t pc;
    uint32_t scc; //zero-extended so as to be {{31'b0}, scc}
    //vgpr's
    //bool done;
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
    //w.done = false;
    return w;
}

/** 
* Input the register index (x0 -> x31) you want 
* to read from and output the register's data (32'b0)
* Note: The 'register' keyword is off-limits. C++ stuff idk. 
* Call 'register' idx instead.
*/
uint32_t scalar_reg_read(uint8_t idx, uint32_t scalar_registers[32]) {
    //register could be rs1 or rs2
    if (idx == 0) {
        return 0;
    } else if (idx > 0 && idx <= REG_SIZE-1) {
        return scalar_registers[idx]; //VCC included
    }
    //throw an error
}

/**
 * input the register you want to write data to
 */
void scalar_reg_write(uint8_t idx, uint32_t data_in, uint32_t scalar_registers[32]) {
    if (idx == 0) {
        scalar_registers[0] = 0;
    } else if (idx > 0 && idx <= REG_SIZE-1) {
        scalar_registers[idx] = data_in;
    }
    //throw an error
}

//step function. Should fetch, decode, execute one instruction



void evaluate_instruction(uint32_t opcode, uint8_t f3, uint8_t f7,
                          uint8_t r1, uint8_t r2, uint8_t d /*rd*/,
                          int32_t imm /*sign extended I-type immediate*/,
                          uint32_t scalar_registers[REG_SIZE]) {
    uint32_t data_temp;
    uint32_t a = scalar_registers[r1];
    uint32_t b = scalar_registers[r2];

    switch (opcode) {
        case R_INSTRUCTION:
            switch (f3) {
                case 0b000: //add/sub
                    switch (f7) {
                        case 0b0000000: //add
                            data_temp = a + b;
                            scalar_reg_write(d, data_temp, scalar_registers);
                            break;
                        case 0b0100000: //sub
                            data_temp = a - b;
                            scalar_reg_write(d, data_temp, scalar_registers);
                            break;
                    }
                    break;

                case 0b001: //sll
                    data_temp = a << (b & 0x1F);
                    scalar_reg_write(d, data_temp, scalar_registers);
                    break;

                case 0b010: //mul
                    data_temp = a * b;
                    scalar_reg_write(d, data_temp, scalar_registers);
                    break;

                case 0b011: //mulq
                    break;

                case 0b100: //xor
                    data_temp = a ^ b;
                    scalar_reg_write(d, data_temp, scalar_registers);
                    break;

                case 0b101: //srl/sra
                    switch (f7) {
                        case 0b0000000: //srl
                            data_temp = a >> (b & 0x1F);
                            scalar_reg_write(d, data_temp, scalar_registers);
                            break;
                        case 0b0100000: //sra
                            data_temp = (uint32_t)((int32_t)a >> (b & 0x1F));
                            scalar_reg_write(d, data_temp, scalar_registers);
                            break;
                    }
                    break;

                case 0b110: //or
                    data_temp = a | b;
                    scalar_reg_write(d, data_temp, scalar_registers);
                    break;

                case 0b111: //and
                    data_temp = a & b;
                    scalar_reg_write(d, data_temp, scalar_registers);
                    break;
            }
            break;

        case I_INSTRUCTION:
            switch (f3) {
                case 0b000: //addi
                    data_temp = a + (uint32_t)imm;
                    scalar_reg_write(d, data_temp, scalar_registers);
                    break;

                case 0b010: //muli
                    data_temp = a * (uint32_t)imm;
                    scalar_reg_write(d, data_temp, scalar_registers);
                    break;

                case 0b100: //xori
                    data_temp = a ^ (uint32_t)imm;
                    scalar_reg_write(d, data_temp, scalar_registers);
                    break;

                case 0b110: //ori
                    data_temp = a | (uint32_t)imm;
                    scalar_reg_write(d, data_temp, scalar_registers);
                    break;

                case 0b111: //andi
                    data_temp = a & (uint32_t)imm;
                    scalar_reg_write(d, data_temp, scalar_registers);
                    break;

                case 0b001: //slli
                    data_temp = a << (imm & 0x1F);
                    scalar_reg_write(d, data_temp, scalar_registers);
                    break;

                case 0b101: //srli, srai
                    switch (f7) {
                        case 0b0000000: //srli
                            data_temp = a >> (imm & 0x1F);
                            scalar_reg_write(d, data_temp, scalar_registers);
                            break;
                        case 0b0100000: //srai
                            data_temp = (uint32_t)((int32_t)a >> (imm & 0x1F));
                            scalar_reg_write(d, data_temp, scalar_registers);
                            break;
                    }
                    break;
            }
            break;

        case S_INSTRUCTION:
            break;

        case U_INSTRUCTION:
            break;

        case J_INSTRUCTION:
            break;
    }
}

/**
 * Dump the contents of the register to examine states. For 
 * dump type "intermediate", dump ONLY the register values that
 * change and show the rest of the values normally.
 * For dump type "final", just show everything (all registers).
 * 
 * Creates a copy of scalar_registers and uses a for loop for initializing.
 * Compare the "temp" copy to the updated version. If any reg vlaues change,
 * only post those ones. Not concerned with what doesnt change.
 * 
 * Apparently C++ treats array parameters like pointers. Never knew!
 * 
 * PC, instr, registers, SCC, VCC
 * 
 */
void dump(string dump_type, uint32_t PC, uint32_t SCC, uint32_t VCC, uint32_t instr, uint32_t temporary[REG_SIZE], uint32_t scalar_registers[REG_SIZE]  ) {
    if (dump_type == "intermediate") {
        for (int i = 0; i < REG_SIZE; i++) {
            if (temporary[i] != scalar_registers[i]) {
                //print out what changed
                cout << "x" << i << ": " << scalar_registers[i];
            }
            //temporary should be one update behind scalar_registers
            temporary[i] = scalar_registers[i];
        }
    } else if (dump_type == "final") {
        for (int i = 0; i < REG_SIZE; i++) {
            cout << " x" << i << ": " << scalar_registers[i];
            if (i % 8 == 0 && i != 0) {
                cout << "\n";
            }
        }
        //should i print the last instruction too?
        cout << "\nPC: " << PC << ", SCC: " << SCC << ", VCC: " << bitset<32>(VCC) << endl;
    }
}



int main() {
    //0x00000013 is NOP (addi x0 x0 0) so that way nothing happens;
    vector<uint32_t> instruction_memory(MEMORY_DEPTH, 0x00000013);

    
    uint32_t test_instruction = 0x00000013;

    WaveState w = wavestate();
    uint32_t pc_idx = w.pc/4; //pc was initialized to 0 before

    ImmediateGenerator imm = immediate(test_instruction);
    DecodeInstruction d = decode(test_instruction);
    evaluate_instruction(d.opcode, d.funct3, d.funct7, d.rs1, d.rs2, d.rd, imm.i_type, w.sgpr); 
    uint32_t temp[REG_SIZE] = {}; //designed to be a copy of the sgpr's that is one cycle behind. For checking new reg values only
    //PC, SCC, VCC value of 216, 64, 400 is bs
    dump("intermediate", 216, 64, 400, test_instruction, temp, w.sgpr);

    //
    /*while (pc_idx != MEMORY_DEPTH) {
        ImmediateGenerator imm = immediate(instruction_memory[pc_idx]);
        DecodeInstruction d = decode(instruction_memory[pc_idx]);
        evaluate_instruction(d.opcode, d.funct3, d.funct7, d.rs1, d.rs2, d.rd, imm.i_type, w.sgpr);
        //print the states stuff
        w.pc += 4;
    }*/
    //print the final wavestate out at the end.

    return 0;
}
