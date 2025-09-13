`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2025 11:52:14 AM
// Design Name: 
// Module Name: debounce
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


module debounce #(
    parameter MS = 10         // debounce time in ms
)(
    input  logic clk,         // system clock
    input  logic noisy_in,    // raw button
    output logic clean_out    // debounced output
);

    localparam integer CNT_MAX = MS * 100_000; // 10 ms * 100 MHz
    logic [$clog2(CNT_MAX)-1:0] counter;   // enough bits for CNT_MAX
    logic latched;

    always_ff @(posedge clk) begin
        if (noisy_in) 
        begin
        
            if (counter < CNT_MAX)
            begin
                counter <= counter + 1;
            end
            
            if (counter >= CNT_MAX)
            begin
                latched <= 1'b1;   // latch high
            end
        end 
        
        else 
        begin
            counter <= 0;
            latched <= 0;           // release latch when button released
        end
    end

    assign clean_out = latched;

endmodule

