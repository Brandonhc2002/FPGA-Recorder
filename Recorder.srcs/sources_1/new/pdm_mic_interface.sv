`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2025 04:51:10 PM
// Design Name: 
// Module Name: pdm_mic_interface
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


module pdm_mic_interface(
    input system_clock,

    // Microphone signals
    input mic_data,
    output logic mic_clk,
    output mic_lr_select,

    output logic [7:0] amplitude,
    output logic sample_ready,

    input mic_enable
);
// -----------------------------
    // Mic clock generation
    localparam sys_clk_freq = 100_000_000; 
    localparam mic_clk_freq = 3_125_000;
    localparam max_mic_clk_cycles = (sys_clk_freq / mic_clk_freq)/2;

    reg [26:0] counter = 0;
    reg        mic_clk_reg = 0;
    assign mic_clk = mic_clk_reg;
    assign mic_lr_select = 0;

    always @(posedge system_clock) 
    begin
        if (mic_enable) 
        begin
            if (counter == max_mic_clk_cycles-1) 
            begin
                counter <= 0;
                mic_clk_reg <= ~mic_clk_reg;
            end
             
            else 
            begin
                counter <= counter + 1;
            end
        end 
        
        else 
        begin
            mic_clk_reg <= 0;
            counter <= 0;
        end
    end

    // -----------------------------
    // Pack 2 PDM bits for CIC input
    
   logic    [2:0] m_data = 0;
   logic m_clk_d;
    assign m_clk_rising = mic_clk & ~m_clk_d;
    always @(posedge system_clock) 
    begin
        m_clk_d <= mic_clk;
        if(~mic_enable)
        begin
            m_data <= 3'd0;
        end
        
        else
        begin
            m_data[0] <= mic_data;
            m_data[2:1] <= m_data[1:0];
        end
        
    end

    // -----------------------------
    // CIC signals
    wire [31:0] cic_out;
    wire        cic_valid;
    wire        cic_ready;

    cic_compiler_0 cic_inst (
        .aclk(system_clock),
        .s_axis_data_tdata({1'b0,m_data[2]}),
        .s_axis_data_tvalid(m_clk_rising),
        .s_axis_data_tready(),
        .m_axis_data_tdata(cic_out),
        .m_axis_data_tvalid(cic_valid)
    );

    // -----------------------------
   
    always @(posedge system_clock)
     begin
        if (cic_valid) 
        begin
            amplitude <= cic_out[25:18]; // MSB 8 bits
            sample_ready <= 1'b1;
        end 
        
        else 
        begin
            sample_ready <= 1'b0;
        end
    end

endmodule