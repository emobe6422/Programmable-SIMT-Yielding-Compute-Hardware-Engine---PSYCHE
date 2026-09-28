`timescale 1ns /1ps

/* Notes:
 * - #116 still doesnt make sense
 * - How to deal with control signals?
 * - Need to write up the SCC conditions
 * - do we really want scc to be something
 */

 module scalar_reg_file #(
    parameter REG_COUNT = 61 //# of scalar registers
    )
    (
    input logic clk, rst_n,
    input logic write_back, //control signal
    input logic [6:0] rs1, rs2,
    input logic [5:0] rd,
    input logic [31:0] data_in,
    input logic [31:0] scc, //115 {31'b0, scc}
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
    //read only derived bits (assign w/ always_comb)
    logic [31:0] vccz; //113 {31'b0, vccz}
    logic [31:0] execz; //114 {31'b0, execz}
    
    logic [31:0] BIG_NUMBA; //WTF IS THIS??? #116
    //117-127 empty
    
    //--------------------------------------------------------//   
    
    function automatic logic [31:0] decode_scalar_operand(
        input logic [6:0]  rs,
        input logic [31:0] scalar_registers [0:60],
        input logic [31:0] vcc,
        input logic [31:0] m0,
        input logic [31:0] exec,
        input logic        vccz,
        input logic        execz
    );
        if (rs inside {[7'd0:7'd60]}) begin
            return scalar_registers[rs]; //sGPR case
        end else if (rs == 7'd61) begin
            return vcc;
        end else if (rs == 7'd62) begin
            return m0;
        end else if (rs == 7'd63) begin
            return exec;
        end else if (rs == 7'd64) begin //0
            return '0;
        end else if (rs inside {[7'd65:7'd96]}) begin //1 -> 32
            return 32'(rs) - 32'd64;
        end else if (rs inside {[7'd97:7'd112]}) begin //-1 -> -16
            return 32'd96 - 32'(rs);
        end else if (rs == 7'd113) begin
            return vccz;
        end else if (rs == 7'd114) begin
            return execz;
        end else if (rs == 7'd115) begin
            //SCC
        end else if (rs == 7'd116) begin
            //16 bit constant
        end else begin
            //random bullshit
        end
    endfunction
    
    //--------------------------------------------------------//  
   
    always_comb begin 
        vccz = {{31{1'b0}}, (vcc == '0)};
        execz ={{31{1'b0}}, (exec == '0)};
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
            data_out_1 <= decode_scalar_operand(rs1, scalar_registers, vcc, m0, exec, vccz, execz);
            data_out_2 <= decode_scalar_operand(rs2, scalar_registers, vcc, m0, exec, vccz, execz);
        end
    end
endmodule
