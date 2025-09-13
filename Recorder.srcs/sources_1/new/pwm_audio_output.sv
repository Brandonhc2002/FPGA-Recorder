`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2025 05:20:22 PM
// Design Name: 
// Module Name: pwm_audio_output
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


module pwm_audio_output(
    input system_clock,
    
    input [7:0] amplitude,
    
    input stereo_enable,
    output wire stereo_out
    );


// --------------------------------- Parameters

localparam system_clk_freq = 100_000_000;

localparam mic_frequency = 3_125_000;
localparam amplitude_width = 64;

localparam oversampling = 15;
localparam pwm_freq = (mic_frequency/amplitude_width) * oversampling;
localparam  pwm_max_cycles = system_clk_freq / pwm_freq;

localparam iterator = pwm_max_cycles / amplitude_width;


// --------------------------------- Registers and wires
logic [$clog2(pwm_max_cycles)-1:0]pwm_counter = 0;


logic [$clog2(pwm_max_cycles):0]intensity;

logic stereo;
// --------------------------------- Logic

always @(*) 
begin
    intensity = (amplitude * iterator > 9'd255) ? 9'd255 : amplitude * iterator;
end

always@(posedge system_clock)
begin
    
    if(stereo_enable)
    begin
    
        if(pwm_counter == pwm_max_cycles - 1)
        begin
            pwm_counter <= 0;
        end
    
        else
        begin
            pwm_counter += 1;
        end
    
    
    end
    

end

assign stereo = intensity >= pwm_counter ? 1'bz : 1'b0;
assign stereo_out = stereo_enable ? stereo : 1'bz;

endmodule
