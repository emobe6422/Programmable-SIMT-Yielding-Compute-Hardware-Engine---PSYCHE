No AI used for RTL generation. AI used for help with emulator and assembler.

UVM, Assembler and Emulator are being made in parallel currently.

Currently:
-R and I types work on the assembler
- Since only loads and stores require access to data memory (and im not sure what data memory will look like yet), verify the rtl works without lw's and sw's for scalar instructions. Good checkpoint to stop making RTL at for the moment to completely shift to getting my assembler and emulator up and running. Once all three work without loads and stores and verified using UVM, then either add loads and stores or start figuring out the vector stuff.
