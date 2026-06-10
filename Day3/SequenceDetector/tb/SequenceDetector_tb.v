`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 15:40:12
// Design Name: 
// Module Name: SequenceDetector_1_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 10:59:31
// Design Name: 
// Module Name: SequenceDetector_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SequenceDetector_1_tb();
reg clk_tb,rst_tb,din_tb;
wire detected_tb;
SequenceDetector_1 dut(clk_tb,rst_tb,din_tb,detected_tb);
initial 
begin
{clk_tb,rst_tb,din_tb}=0;
end
always #5 clk_tb=~clk_tb;
initial
begin
    rst_tb = 1;
    #10 rst_tb = 0;

    #10 din_tb = 1;
    #10 din_tb = 1;
    #10 din_tb = 1;
    #10 din_tb = 0;
end
endmodule


