`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2025 07:11:29 AM
// Design Name: 
// Module Name: Edge_detection
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


module positive_edge_detector(
    input clock, 
    input signal, 
    output positive_edge
);
reg signal_prev;

always @(posedge clock) begin
    signal_prev <= signal;
end

assign positive_edge = signal & ~signal_prev; // 0 -> 1 transition

endmodule


module negative_edge_detector(
    input clock, 
    input signal, 
    output negative_edge
);
reg signal_prev;

always @(posedge clock) begin
    signal_prev <= signal;
end

assign negative_edge = ~signal & signal_prev; // 1 -> 0 transition

endmodule