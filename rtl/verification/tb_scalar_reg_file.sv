`timescale 1ns / 1ps

/* Notes:
 * - VCC, EXEC and m0 are not explicitly set by the user, but I will anyway for testing purposes
 * - 
 */

module tb_scalar_reg_file();
    logic clk;
    logic write_enable;
    logic [6:0] rs1, rs2;
    logic [5:0] rd;
    logic [31:0] data_in;
    logic [31:0] scc;
    logic [31:0] data_out_1, data_out_2;
    
    int errors = 0;
    int checks = 0;
    
    scalar_reg_file dut(
        //in
        .clk(clk),
        .write_enable(write_enable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .data_in(data_in),
        .scc(scc),
        //out
        .data_out_1(data_out_1),
        .data_out_2(data_out_2)
    );
    
    always #5 clk = ~clk; //100MHz
    
        // self-checking helper
    task automatic check_equal(input string name, input logic [31:0] actual, input logic [31:0] expected);
        checks++;
        if (actual !== expected) begin
            errors++;
            $error("[FAIL] %s: expected %h, got %h", name, expected, actual);
        end else begin
            $display("[PASS] %s", name);
        end
    endtask
    
    initial begin
        clk = 0;
        /*Case 1  : VCC = '0, VCCZ = 1*/
        rd = 61;
        data_in = '0;
        write_enable = 1;
        @(posedge clk);
        @(posedge clk);
        check_equal("VCCZ equals 1 for VCC = '0", dut.vccz, {{31'b0}, 1'b1});
        /*Case 2  : VCC = NZ, VCCZ = 0*/
        rd = 61;
        data_in = {{31'b0}, 1'b1};
        write_enable = 1;
        @(posedge clk);
        @(posedge clk);
        check_equal("VCCZ equals 0 for VCC = NZ", dut.vccz, {{32'b0}});
        /*Case 3  : EXEC = '0, EXECZ = 1*/
         rd = 63;
        data_in = '0;
        write_enable = 1;
        @(posedge clk);
        @(posedge clk);
        check_equal("EXECZ equals 1 for EXEC = '0", dut.execz, {{31'b0}, 1'b1});
        /*Case 4  : EXEC = NZ, EXECZ = 0*/
        rd = 63;
        data_in = {{31'b0}, 1'b1};
        write_enable = 1;
        @(posedge clk);
        @(posedge clk);
        check_equal("EXECZ equals 0 for EXEC = NZ", dut.execz, 32'b0);
        /*Case 5  : write to sGPR, with fringe cases*/
        // 0
        rd = 0;
        data_in = 32'd4294967295;
        write_enable = 1;
        @(posedge clk);
        @(posedge clk);
        check_equal("write to sGPR 0", dut.scalar_registers[0], 32'd4294967295);
        //30
        rd = 30;
        data_in = 32'd0;
        write_enable = 1;
        @(posedge clk);
        @(posedge clk);
        check_equal("write to sGPR 30", dut.scalar_registers[30], 32'd0);
        //60
        rd = 60;
        data_in = 32'd676767;
        write_enable = 1;
        @(posedge clk);
        @(posedge clk);
        check_equal("write to sGPR 60", dut.scalar_registers[60], 32'd676767);
        /*Case 6  : read the registers with fringe cases */
        //0
        rs1 = 0;
        @(posedge clk);
        @(posedge clk);
        check_equal("read sGPR 0", data_out_1, 32'd4294967295);
        //30
        rs1 = 30;
        @(posedge clk);
        @(posedge clk);
        check_equal("read sGPR 30", data_out_1, 32'd0);
        
        //60
        rs1 = 60;
        @(posedge clk);
        @(posedge clk);
        check_equal("read sGPR 60", data_out_1, 32'd676767);
        
        
        /*Case 7  : write to a reg that cannot be written to*/
        rs1 = 118;
        @(posedge clk);
        @(posedge clk);
        check_equal("read an out of range register", data_out_1, 'X);
        /*Case 8  : write when w.e. = 0*/
        //ehhhhhhh
        /*Case 9  : check vcc for 61*/
        //ehhhhhhh
        /*Case 10 : check m0 for 62*/
        //ehhhhhhh
        /*Case 11 : check exec for 63*/
        //ehhhhhhh
        /*Case 12 : write to sGPR, then rewrite*/
        
        /*Case 13 : try '0 (64)*/
        
        /*Case 14 : try 1, 32, -1, -16*/
        //1
        rs1 = 65;
        @(posedge clk);
        @(posedge clk);
        check_equal("read a scalar constant 1", data_out_1, 32'd1);
        //32
        rs1 = 96;
        @(posedge clk);
        @(posedge clk);
        check_equal("read a scalar constant 32" , data_out_1, 32'd32);
        //-1
        rs1 = 97;
        @(posedge clk);
        @(posedge clk);
        
        check_equal("read a scalar constant -1", data_out_1, -32'd1);
        //-16
        rs1 = 112;
        @(posedge clk);
        @(posedge clk);
        
        check_equal("read a scalar constant -16", data_out_1, -32'd16);
        $finish;
    end
endmodule
