`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:12:28 01/17/2023 
// Design Name: 
// Module Name:    test 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module test();
reg clk, reset;
wire [9:0] pc;
always #5 clk <= ~clk;
initial begin
    clk = 0;
    reset = 0;
end
cpu cpu(
    .clk(clk), 
    .reset(reset), 
    .pc(pc)
);


endmodule
