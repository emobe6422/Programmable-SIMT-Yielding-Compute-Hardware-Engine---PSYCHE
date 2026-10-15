#include <cstdint>
#include <cstdio>
#include <vector>
/*
 * Make sure 0 and 31 are hardwired.
 * Test int16_t for immediates closely
 * JAL/JALR issue
 */

struct wave_state {
    uint32_t sgpr[32] = {0};
    uint32_t vcc = 0;
    uint32_t exec = 0xFFFFFFFF;
    uint32_t PC = 0;
    uint8_t scc = 0; //either a 1 bit code on its own or padded w 31 0s as well
    bool done = false;
    
    
};

struct decoded_instruction {
    //no IMM since thats done elsewhere
    uint8_t opcode; //7 bits
    uint8_t rd;     //5 bits
    uint8_t funct3; //3 bits
    uint8_t funct7; //7 bits
    uint8_t rs1;    //5 bits
    uint8_t rs2;    //5 bits
    //no immediate here
};

struct immediate_generator {
    /* takes in instruction, outputs the corresponding immediate
     * and also a flag for what instruction type it was.
     */
    uint32_t instruction;
    int16_t r_type; //?? be careful about testing this one
    int16_t i_type;
    int16_t s_type;
    int16_t u_type;
    int16_t j_type;
    int16_t y0_type; //new b type kinda
    int16_t y1_type;
    int16_t y2_type;
    //some sort of bit flag
};



int main() {
    return 0;
};
