No AI used for RTL generation. Claude used a small bit (<15%) for the emulator and a lot (>50%) for the assembler. I wasnt really interested in the assembler besides the new instructions (which I haven't even gotten to yet).

UVM, Assembler and Emulator are being made in parallel currently.

Currently:
- Going all-in on the cpp emulator since I'm getting to the point where I really need it. I need to compare my RTL's state to a veirfied model for testing across millions of cycles to catch any cheeky bugs
-R and I types work on the assembler. Got load word working as well
- Once all basic opcodes are working for the scalar side, compare emulator and RTL using UVM. Once fully verified, then move onto vector side (the fun part!!)

Make some simple self checking TB's then move on to more stuff

Link to check out the wip documentation:
https://docs.google.com/document/d/18SE2LMBSRBfYAjMrl6ifSK7LZMf0lSKwwFyZZTDHly8/edit?usp=sharing

Link to check out the ISA's instruction (70% RISC based, 30% AMD based):
https://docs.google.com/document/d/1B7M0C_R3KBA8vSXxU88JsNecfSQaQFuy6l8b3Vo932w/edit?usp=sharing
