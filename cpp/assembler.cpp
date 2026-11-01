#include <cstdint>
#include <cstdio>
#include <vector>
#include <iostream>
#include <bitset>
#include <string>
#include <unordered_map>
using namespace std;

/*
* Notes:
* - R and B types first
* - Loop labels down the line (label_1, etc.)
* - need to eventually support Q16.16, 2s complement #s as well
* - scalar registers denoted with x, vector registers denoted with v.
*/
//uint32_t instruction;

enum class Format { R, I, S, U, J, Y0, Y1, Y2 }; //apparently adding the class keyword is just good syntax

struct InstructionTable {
    Format fmt;
    uint8_t opcode; //7 bits
    uint8_t funct3; //3 bits
    uint8_t funct7; //7 bits
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

//return type immediate_generator
    ImmediateGenerator immediate (uint32_t instr) {
        ImmediateGenerator imm{}; //initializes all values to zero with the {}
        imm.instruction = instr;
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
    unordered_map<string, InstructionTable> INSTR_TABLE = {
        /* R TYPE INSTRUCTIONS */
        {"add", {Format::R, 0b0110011, 0b000, 0b0000000}},
        {"sub", {Format::R, 0b0110011, 0b000, 0b0100000}},
        //mult
        //mulq?
        {"xor", {Format::R, 0b0110011, 0b100, 0b0000000}},
        {"or",  {Format::R, 0b0110011, 0b110, 0b0000000}},
        {"and", {Format::R, 0b0110011, 0b111, 0b0000000}},
        {"sll", {Format::R, 0b0110011, 0b001, 0b0000000}},
        {"srl", {Format::R, 0b0110011, 0b101, 0b0000000}},
        {"sra", {Format::R, 0b0110011, 0b101, 0b0100000}},
        /* I TYPE INSTRUCTIONS */
        {"addi", {Format::I, 0b0010011, 0b000, 0}},
        //multi
        {"xori", {Format::I, 0b0010011, 0b100, 0}},
        {"ori",  {Format::I, 0b0010011, 0b110, 0}},
        {"andi", {Format::I, 0b0010011, 0b111, 0}},
        {"slli", {Format::I, 0b0010011, 0b001, 0b0000000}},
        {"srli", {Format::I, 0b0010011, 0b101, 0b0000000}},
        {"srai", {Format::I, 0b0010011, 0b101, 0b0100000}},
        {"lw",   {Format::I, 0b0000011, 0b010, 0}},
        {"jalr", {Format::I, 0b1100111, 0b000, 0}},
        /* S TYPE INSTRUCTIONS */
        //sw
        //cmp_eq
        //cmp_lt
        //cmp_ge
        //cmp_ltu
        //cmp_geu
        /* U TYPE INSTRUCTIONS */
        //lui
        //auipc
        /* J TYPE INSTRUCTIONS */
        //jal
        /* y0 TYPE INSTRUCTIONS */
        //branch 
        //cbranch_sccz
        //cbranch_sccnz
        //cbranch_vccz
        //cbranch_vccnz
        //cbranch_execz
        //cbranch_execnz
        //barrier
        //wait_cnt
        //endpgm
        /* y1 TYPE INSTRUCTIONS */
        //cbranch_i_fork
        //cmov
        /* y2 TYPE INSTRUCTIONS */
        //cbranch_join
        //abs




    };
    //add x1 x2 x3
    //x0 and x31 should be exceptions since vcc and 0
    //just reproduce the binary representation of the instruction
    //input is a string
    string english_instruction = "addi x1, x2, -12";
    string mnemonic = "";
    vector<string> operand_list;
    string current_operand = "";
    bool in_operands = false;
    for (char c : english_instruction) {
        if (!in_operands) {
            if (isspace(c)) {
                if (!mnemonic.empty()) in_operands = true;   // first space after the mnemonic
            } else {
                mnemonic += c;
            }
        } else {
            if (c == ',') {
                operand_list.push_back(current_operand);     // finish this operand
                current_operand = "";
            } else if (!isspace(c)) {
                current_operand += c;                         // skip spaces inside operand list
            }
        }
    }
    if (!current_operand.empty()) operand_list.push_back(current_operand);  // last operand

    // 1. Look up the mnemonic
    auto it = INSTR_TABLE.find(mnemonic);
    if (it == INSTR_TABLE.end()) {
        cout << "error: unknown instruction '" << mnemonic << "'\n";
        return 1;
    }
    const InstructionTable& info = it->second;

    //remove any x's (if there are any)
    for (string& s : operand_list) {
        if (!s.empty() && s[0] == 'x') {
            s.erase(0, 1);
        }
    }

    // Convert a stripped operand ("17") to a register number, -1 if invalid
    auto parse_reg = [](const string& op) -> int {
        if (op.empty()) return -1;
        int num = stoi(op);
        return (num >= 0 && num <= 31) ? num : -1;
    };

    // Parse a decimal, negative, or hex immediate and range-check it
    auto parse_imm = [](const string& op, int lo, int hi, int& out) -> bool {
        if (op.empty()) return false;
        int num = stoi(op, nullptr, 0);
        if (num < lo || num > hi) return false;
        out = num;
        return true;
    };

    uint32_t binary_instruction = 0;

    if (info.fmt == Format::R) {
        // 2. Operand count
        if (operand_list.size() != 3) {
            cout << "error: R-type needs 3 operands\n";
            return 1;
        }
        // 3. Registers
        int rd  = parse_reg(operand_list[0]);
        int rs1 = parse_reg(operand_list[1]);
        int rs2 = parse_reg(operand_list[2]);
        if (rd < 0 || rs1 < 0 || rs2 < 0) {
            cout << "error: bad register\n";
            return 1;
        }
        // 4. Pack
        binary_instruction = ((uint32_t)info.funct7 << 25)
                           | ((uint32_t)rs2          << 20)
                           | ((uint32_t)rs1          << 15)
                           | ((uint32_t)info.funct3  << 12)
                           | ((uint32_t)rd           << 7)
                           |  (uint32_t)info.opcode;
    }
    else if (info.fmt == Format::I) {
        int rd = -1, rs1 = -1, imm = 0;

        if (mnemonic == "lw" || mnemonic == "jalr") {
            // "lw x5, 8(x1)" → operands ["5", "8(x1)"]
            if (operand_list.size() != 2) {
                cout << "error: expected rd, offset(rs1)\n";
                return 1;
            }
            rd = parse_reg(operand_list[0]);
            string mem = operand_list[1];
            size_t open = mem.find('(');
            size_t close = mem.find(')');
            if (open == string::npos || close == string::npos || close < open) {
                cout << "error: expected offset(reg)\n";
                return 1;
            }
            string offset = mem.substr(0, open);
            string reg    = mem.substr(open + 1, close - open - 1);
            if (!reg.empty() && reg[0] == 'x') reg.erase(0, 1);
            rs1 = parse_reg(reg);
            if (!parse_imm(offset.empty() ? "0" : offset, -2048, 2047, imm)) {
                cout << "error: offset must be -2048 to 2047\n";
                return 1;
            }
        } else {
            // "addi x1, x2, -12" → operands ["1", "2", "-12"]
            if (operand_list.size() != 3) {
                cout << "error: I-type needs 3 operands\n";
                return 1;
            }
            rd  = parse_reg(operand_list[0]);
            rs1 = parse_reg(operand_list[1]);

            bool is_shift = (mnemonic == "slli" || mnemonic == "srli" || mnemonic == "srai");
            if (is_shift) {
                if (!parse_imm(operand_list[2], 0, 31, imm)) {
                    cout << "error: shift amount must be 0-31\n";
                    return 1;
                }
                imm |= (info.funct7 << 5);   // srai: puts 0100000 in imm[11:5]
            } else {
                if (!parse_imm(operand_list[2], -2048, 2047, imm)) {
                    cout << "error: immediate must be -2048 to 2047\n";
                    return 1;
                }
            }
        }
        if (rd < 0 || rs1 < 0) {
            cout << "error: bad register\n";
            return 1;
        }
        binary_instruction = (((uint32_t)imm & 0xFFF) << 20)
                           | ((uint32_t)rs1          << 15)
                           | ((uint32_t)info.funct3  << 12)
                           | ((uint32_t)rd           << 7)
                           |  (uint32_t)info.opcode;
    }
    else {
        cout << "error: format not supported yet\n";
        return 1;
    }

    // ---- Output ----
    DecodeInstruction de = decode(binary_instruction);
    ImmediateGenerator imm = immediate(binary_instruction);

    cout << "input:  " << english_instruction << "\n";
    cout << "binary: " << bitset<32>(binary_instruction) << "\n";
    printf("hex:    0x%08X\n\n", binary_instruction);

    //funct3, funct7, rs1, rs2, rd, opcode
    if (info.fmt == Format::R) {
        cout << "funct7: " << bitset<7>(de.funct7) << "\n";
        cout << "rs2:    " << bitset<5>(de.rs2)    << "  (x" << +de.rs2 << ")\n";
    } else if (info.fmt == Format::I) {
        cout << "imm:    " << bitset<12>((binary_instruction >> 20) & 0xFFF)
             << "  (" << imm.i_type << ")\n";
    }
    cout << "rs1:    " << bitset<5>(de.rs1)    << "  (x" << +de.rs1 << ")\n";
    cout << "funct3: " << bitset<3>(de.funct3) << "\n";
    cout << "rd:     " << bitset<5>(de.rd)     << "  (x" << +de.rd  << ")\n";
    cout << "opcode: " << bitset<7>(de.opcode) << "\n";

    return 0;
}
