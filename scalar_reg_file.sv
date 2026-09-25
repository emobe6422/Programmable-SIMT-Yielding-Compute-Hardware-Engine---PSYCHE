`timescale 1ns /1ps

/* Notes:
 * - #116 still doesnt make sense
 * - How to deal with control signals?
 * - Need to write up the SCC conditions
 *
 */

 module scalar_reg_file #(
    parameter REG_COUNT = 61 //# of scalar registers
    )
    (
    input logic clk, rst_n,
    input logic [6:0] rs1, rs2,
    input logic [5:0] rd,
    input logic [31:0] data_in,
    /*we pass these values (data_out_1/2) as unsigned and modules downstream
     * can decide if they want to convert it.
     */
    output logic [31:0] data_out_1, data_out_2
    );
    
    //read/write
    logic [31:0] scalar_registers [0:REG_COUNT-1];
    //making the register unpacked leads to unforseen issues so vcc, m0, exec will not be packed
    logic [31:0] vcc; //61
    logic [31:0] m0; //62
    logic [31:0] exec; //63
    //read only integer constants. Can be unpacked array
    const logic signed [31:0] zero[64] = '{0};
    const logic signed [31:0] one_to_thirty_two [65:96] =
        '{1, 2, 3, 4, 5, 6, 7, 8, 9,  10,
          11, 12, 13, 14, 15, 16, 17, 18, 
          19, 20, 21, 22, 23, 24, 25, 26, 
          27, 28, 29, 30, 31, 32};
    const logic signed [31:0] neg_one_to_neg_sixteen [97:112] =
        '{-1, -2, -3, -4,  -5,  -6,
          -7, -8, -9, -10, -11, -12, 
          -13, -14, -15, -16};
    //read only derived bits (assign w/ always_comb)
    logic [31:0] vccz; //113 {31'b0, vccz}
    logic [31:0] execz; //114 {31'b0, execz}
    logic [31:0] scc; //115 {31'b0, scc}
    logic [31:0] BIG_NUMBA; //WTF IS THIS??? #116
    //117-127 empty
   
    always_comb begin 
        vccz = {{31{1'b0}}, (vcc == '0)};
        execz ={{31{1'b0}}, (exec == '0)};
        //scc WILL TAKE A WHILE. Multiple cases to eval
    end
    
    always_ff @ (posedge clk) begin
        if (!rst_n) begin
            foreach (scalar_registers[i]) begin
                scalar_registers[i] <= '0;
            end
            vcc  <= '0;
            m0   <= '0;
            exec <= '0;
        end else begin
            //
        end
    end
endmodule
