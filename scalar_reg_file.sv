`timescale 1ns /1ps

 module scalar_reg_file #(
    parameter REG_COUNT = 61 //# of scalar registers
    )
    (
    input logic clk, rst_n,
    input logic [6:0] rs1, rs2,
    input logic [5:0] rd,
    /*we pass these values (data_out_1/2) as unsigned and modules downstream
     * can decide if they want to convert it.
     */
    output logic [31:0] data_out_1, data_out_2
    );
    
    //read/write
    logic [31:0] scalar_registers [0:REG_COUNT-1];
    logic [31:0] vcc [61];
    logic [31:0] m0 [62];
    logic [31:0] exec [63];
    //read only integer constants
    const int zero[64] = '{0};
    const int one_to_thirty_two [65:96] =
        '{1, 2, 3, 4, 5, 6, 7, 8, 9,  10,
          11, 12, 13, 14, 15, 16, 17, 18, 
          19, 20, 21, 22, 23, 24, 25, 26, 
          27, 28, 29, 30, 31, 32};
    const int neg_one_to_neg_sixteen [97:112] =
        '{-1, -2, -3, -4,  -5,  -6,
          -7, -8, -9, -10, -11, -12, 
          -13, -14, -15, -16};
    //read only derived bits (assign w/ always_comb)
    logic [31:0] vccz [113];
    logic [31:0] execz [114];
    logic [31:0] scc [115];
    logic [31:0] BIG_NUMBA [116]; //WTF IS THIS???
   
    
    

    always_comb begin 
        vccz = {{31{1'b0}}, (vcc == '0)};
        execz ={};
        //scc WILL TAKE A WHILE
    end
    
    always_ff @ (posedge clk) begin
        if (!rst_n) begin
            //
        end else begin
            //
        end
    end
endmodule