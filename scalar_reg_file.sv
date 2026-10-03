`timescale 1ns /1ps

/* Notes:
 * - #116? Instruction stream constant !!REMOVED!!
 * - Need to write up the SCC conditions/evaluate it more
 * - returning the value in SCC
 * - No reset pins for reg file
 * - SCC and EXEC stay out, VCC and M0 stay in
 * -fix the ordering later since removing SCC and EXEC
 */

module scalar_reg_file #(
    parameter REG_COUNT = 61 //# of scalar registers
    )
    (
    input logic clk,
    input logic write_enable, //control signal
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
    //63
    //read only derived bits (assign w/ always_comb)
    logic [31:0] vccz; //113 {31'b0, vccz}
    //114 , 115, 116
    //117-127 empty
    
    //--------------------------------------------------------//   
    
    function automatic logic [31:0] decode_scalar_operand(
        input logic [6:0]  rs,
        input logic [31:0] scalar_registers [0:60],
        input logic [31:0] vcc,
        input logic [31:0] m0,
        input logic        vccz
    );
        if (rs inside {[7'd0:7'd60]}) begin
            return scalar_registers[rs]; //sGPR case
        end else if (rs == 7'd61) begin
            return vcc;
        end else if (rs == 7'd62) begin
            return m0;
        end else if (rs == 7'd63) begin
            return 'X;
        end else if (rs == 7'd64) begin //0
            return '0;
        end else if (rs inside {[7'd65:7'd96]}) begin //1 -> 32
            return 32'(rs) - 32'd64;
        end else if (rs inside {[7'd97:7'd112]}) begin //-1 -> -16
            return 32'd96 - 32'(rs);
        end else if (rs == 7'd113) begin
            return vccz;
        end else if (rs == 7'd114) begin
            return 'X;
        end else if (rs == 7'd115) begin
            //SCC
        end else if (rs inside {[7'd116:7'd127]}) begin
            //outliers that shouldnt do anything
            return 'X;
        end
    endfunction
    
    //--------------------------------------------------------//  
    
    always_comb begin
        vccz = {{31{1'b0}}, (vcc == '0)};
        data_out_1 = decode_scalar_operand(rs1, scalar_registers, vcc, m0, vccz);
        data_out_2 = decode_scalar_operand(rs2, scalar_registers, vcc, m0, vccz);
    end
    always_ff @ (posedge clk) begin
        if (write_enable) begin
            if (rd inside {[7'd0:7'd60]}) begin
                scalar_registers[rd] <= data_in;
            end else if (rd == 7'd61) begin
                vcc <= data_in;
            end else if (rd == 7'd62) begin  
                m0 <= data_in;
            end
        end
    end
endmodule
