`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 17:00:17
// Design Name: 
// Module Name: Decoder_2_4_tb
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


module decoder_2to4_tb();
reg [1:0]i_tb;
wire [3:0]Y_tb;
integer i;

Decoder_2to4_ dut(i_tb,Y_tb);
initial 
begin
i_tb=0;
end
initial
begin
 for(i=0; i<4; i=i+1)
    begin
        i_tb = i;
        #10;
    end
end

endmodule
