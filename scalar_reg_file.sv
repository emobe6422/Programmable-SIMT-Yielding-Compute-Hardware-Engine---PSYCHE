`timescale 1ns /1ps

/* Notes: 
 * - VCC implicitly written to, not explicitly
 * - SCC, M0 and EXEC stay out, VCC stays in
 */

module scalar_reg_file #(
    parameter REG_COUNT = 32 //# of scalar registers
    )
    (
    input logic clk,
    input logic write_enable, //control signal
    input logic [4:0] rs1, rs2, rd,
    input logic [31:0] data_in,
    /*we pass these values (data_out_1/2) as unsigned and modules downstream
     * can decide if they want to convert it.
     */
    output logic [31:0] data_out_1, data_out_2
    );    
    //read/write
    logic [31:0] scalar_registers [0:REG_COUNT-1];
    logic [31:0] vcc;
    
    //--------------------------------------------------------//   
    
    function automatic logic [31:0] decode_scalar_operand(
        input logic [4:0]  rs,
        input logic [31:0] scalar_registers [0:REG_COUNT-1],
        input logic [31:0] vcc
    );
        if (rs == 5'd0) begin
            return '0; //sGPR case
        end else if (rs inside {[5'd1:5'd30]}) begin
            return scalar_registers[rs];
        end else if (rs == 5'd31) begin
            return vcc;
        end
    endfunction
    
    //--------------------------------------------------------//  
    
    always_comb begin
        data_out_1 = decode_scalar_operand(rs1, scalar_registers, vcc);
        data_out_2 = decode_scalar_operand(rs2, scalar_registers, vcc);
    end
    always_ff @ (posedge clk) begin
       if (write_enable) begin
            if (rd == 5'd0) begin
                // x0 is hardwired to zero - writes are discarded
            end else if (rd inside {[5'd1:5'd30]}) begin
                scalar_registers[rd] <= data_in;
            end else if (rd == 5'd31) begin
                vcc <= data_in;
            end
        end
    end
endmodule
