No AI used for RTL generation. Claude used a small bit (<15%) for the emulator and a lot (>50%) for the assembler. I wasnt really interested in the assembler besides the new instructions.

UVM, Assembler and Emulator are being made in parallel currently.

Currently:
- Going all-in on the cpp emulator since I'm getting to the point where I really need it. I need to compare my RTL's state to a veirfied model for testing across millions of cycles to catch any cheeky bugs
-R and I types work on the assembler
- Since only loads and stores require access to data memory (and im not sure what data memory will look like yet), verify the rtl works without lw's and sw's for scalar instructions. Good checkpoint to stop making RTL at for the moment to completely shift to getting my assembler and emulator up and running. Once all three work without loads and stores and verified using UVM, then either add loads and stores or start figuring out the vector stuff.

Make some simple self checking TB's then move on to more stuff

Link to check out the wip documentation:

https://docs.google.com/document/d/18SE2LMBSRBfYAjMrl6ifSK7LZMf0lSKwwFyZZTDHly8/edit?usp=sharing
