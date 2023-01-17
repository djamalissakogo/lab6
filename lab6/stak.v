`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:36:08 01/17/2023 
// Design Name: 
// Module Name:    stak 
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
module stak(
input clk,
input rstn,
input pop,
input push,
input [WIDTH-1:0]din,

output [WIDTH-1:0]dout,
output empty,
output full);

parameter WIDTH = 32;
parameter DEPTH = 32;

reg [WIDTH-1:0]stack[DEPTH-1:0]; //memory
reg [WIDTH-1:0]index, next_index; 
reg [WIDTH-1:0]dout, next_dout;

wire empty, full;
initial
    begin
        dout  <= 8'd0;
        index <= 1'b0;
    end
always @ (posedge clk) //Sequential block
begin
  if(!rstn)
  begin
    dout  <= 8'd0;
    index <= 1'b0;
  end
  else
  begin
    dout  <= next_dout;
    index <= next_index;
  end
end

assign empty = !(|index);
assign full  = !(|(index ^ DEPTH));
always @ (*) //Combinational Block
begin
  if(push) //write
  begin
  stack[index] = din;
  next_index   = index+1'b1;
  end
  else if(pop)  //read
  begin
  next_dout  = stack[index-1'b1];
  next_index = index-1'b1;
  end
  else
  begin
  next_dout  = dout;
  next_index = index;
  end
 
end
endmodule
