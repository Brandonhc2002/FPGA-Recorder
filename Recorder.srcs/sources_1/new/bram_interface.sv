`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2025 06:38:16 PM
// Design Name: 
// Module Name: bram_interface
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


module bram_interface(
    input bram_clock,
    
    input  logic                  wr_en,
    input  logic [ADDR_WIDTH-1:0] wr_addr,
    input  logic [DATA_WIDTH-1:0] wr_data,
    
    input  logic [ADDR_WIDTH-1:0] rd_addr,
    output logic [DATA_WIDTH-1:0] rd_data
    );
    
 // --------------------------------- Parameters   
 localparam DATA_WIDTH = 8;
 localparam ADDR_WIDTH = 19;
 
 // --------------------------------- Registers and wires   
 logic [DATA_WIDTH-1:0] memory [(2**ADDR_WIDTH)-1:0];
 
 // --------------------------------- Logic
    
// Write process
    always @(posedge bram_clock) begin
        if (wr_en)
        begin
            memory[wr_addr] <= wr_data;
        end
    end

    // Read process
    always @(posedge bram_clock) begin
        rd_data <= memory[rd_addr];
    end

endmodule
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
