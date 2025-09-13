`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2025 01:27:55 PM
// Design Name: 
// Module Name: tb_record_top
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

module tb_record_top;

    // Clock
    logic system_clock = 0;
    always #5 system_clock = ~system_clock; // 100 MHz

    // Inputs
    logic BTNU = 0;
    logic BTND = 0;
    logic microphone_data = 0;

    // Outputs
    wire microphone_clock;
    wire microphone_select;
    wire stereo;
    wire ampSD;
    wire LED16_R, LED16_G, LED16_B;
    wire [15:0] LED;

    logic BTNC = 0;

record_top dut (
    .system_clock(system_clock),
    .microphone_clock(microphone_clock),
    .microphone_select(microphone_select),
    .microphone_data(microphone_data),
    .stereo(stereo),
    .ampSD(ampSD),
    .BTNU(BTNU),
    .BTND(BTND),
    .BTNC(BTNC),
    .LED16_R(LED16_R),
    .LED16_G(LED16_G),
    .LED16_B(LED16_B),
    .LED(LED)
);

    // Simple test stimulus
    initial begin
        // Wait for global reset
        #100;

        // Press BTNU to go RECORD
        BTNU = 1;
        #15_000_000; // 100 ns press
        BTNU = 0;

        #500_000_000;
        BTNC = 1;
        #15_000_000;
        BTNC = 0;
        #1_000_000


        // Press BTND to go PLAY
        BTND = 1;
        #15_000_000; // 100 ns press
        BTND = 0;

        #500_000_000;
        BTNC = 1;
        #15_000_000;
        BTNC = 0;
        #1_000_000

        // Press BTNU again to go RECORD
        BTNU = 1;
        #100;
        BTNU = 0;

        #500_000_000; // Wait some time

        $stop;
    end

    // Monitor state changes via LEDs
    initial begin
        $display("Time\tLED_R LED_G LED_B");
        $monitor("%0t\t%b\t%b\t%b", $time, LED16_R, LED16_G, LED16_B);
    end

endmodule

