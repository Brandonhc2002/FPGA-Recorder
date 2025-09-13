`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2025 06:52:17 PM
// Design Name: 
// Module Name: record_top
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


module record_top(
    input system_clock,
    
    output microphone_clock,
    output microphone_select,
    input microphone_data,
    
    output stereo,
    output logic ampSD,
    
    input BTNU,
    input BTND,
    input BTNC,
    
    output LED16_R,
    output LED16_G,
    output LED16_B,
    output [15:0] LED
    );


// --------------------------------------------- Parameters

// states
localparam IDLE = 0;
localparam RECORD = 1;
localparam PLAY = 2;

localparam DECIMATION = 64;        // <-- match CIC config
localparam INPUT_CLK_HZ = 3_125_000; // mic clock (PDM sample rate)
localparam OUTPUT_RATE = INPUT_CLK_HZ / DECIMATION; // CIC output sample rate


localparam SYSTEM_CLK_HZ = 100_000_000;
localparam MAX_BRAM_CYCLES = SYSTEM_CLK_HZ / (2 * OUTPUT_RATE);

localparam MAX_SAMPLES = 488_280;

// --------------------------------------------- Registers and wires

logic [1:0] current_state = 0,next_state = 0;

logic mic_enable,stereo_enable;

logic [19:0] read_addr = 0, write_addr = 0;

logic bram_clock_genetate = 0;
logic [$clog2(4096)-1:0]bram_clock_counter = 0;
logic sample_ready_d = 0;

logic bram_clk_sync_d;
logic bram_clk_posedge;

wire posedge_record;
wire posedge_play;
wire posedge_stop;

wire [7:0] amplitude;
wire sample_ready;

wire [7:0] bram_amplitude;

wire wr_enable;

wire bram_clock;

wire bram_clock_enable;

wire btnu_db, btnd_db, btnc_db;

// --------------------------------------------- Instantiations

pdm_mic_interface my_mic (
    .system_clock(system_clock),
    .mic_data(microphone_data),
    .mic_clk(microphone_clock),
    .mic_lr_select(microphone_select),
    .amplitude(amplitude),
    .sample_ready(sample_ready),
    .mic_enable(mic_enable)
);

pwm_audio_output my_pwm (
    .system_clock(system_clock),
    .amplitude(bram_amplitude),
    .stereo_enable(stereo_enable),
    .stereo_out(stereo)
);

bram_interface my_bram (
    .bram_clock(bram_clock),
    .wr_en(wr_enable),
    .wr_addr(write_addr),
    .wr_data(amplitude),
    .rd_addr(read_addr),
    .rd_data(bram_amplitude)
);

positive_edge_detector PE1(
    .clock(system_clock), 
    .signal(btnu_db), 
    .positive_edge(posedge_record)
);

positive_edge_detector PE2(
    .clock(system_clock), 
    .signal(btnd_db), 
    .positive_edge(posedge_play)
);

positive_edge_detector PE3(
    .clock(system_clock), 
    .signal(btnc_db), 
    .positive_edge(posedge_stop)
);

debounce #(
    .MS(10)   // 10 ms debounce
) my_debouncer1 (
    .clk(system_clock),     // system clock
    .noisy_in(BTND),        // raw pushbutton input
    .clean_out(btnd_db)     // debounced output
);

debounce #(
    .MS(10)   // 10 ms debounce
) my_debouncer2 (
    .clk(system_clock),     // system clock
    .noisy_in(BTNU),        // raw pushbutton input
    .clean_out(btnu_db)     // debounced output
);

debounce #(
    .MS(10)   // 10 ms debounce
) my_debouncer3 (
    .clk(system_clock),     // system clock
    .noisy_in(BTNC),        // raw pushbutton input
    .clean_out(btnc_db)     // debounced output
);


// --------------------------------------------- Assign statements

assign ampSD = current_state == PLAY ? 1'b1 : 1'b0;
assign stereo_enable = current_state == PLAY ? 1'b1 : 1'b0;
assign mic_enable = current_state == RECORD ? 1'b1 : 1'b0;
assign wr_enable  = current_state == RECORD ? 1'b1 : 1'b0;
assign bram_clock = current_state == RECORD ? sample_ready : bram_clock_genetate ;
assign LED16_B = current_state == PLAY ? 1'b1:1'b0;
assign LED16_R = current_state == RECORD ? 1'b1:1'b0;
assign LED16_G = current_state == IDLE ? 1'b1:1'b0;
assign LED[7:0] = btnu_db ? 8'd255 : 8'd0;
assign LED[15:8] = btnd_db ? 8'd255 : 8'd0;
assign sample_ready_posedge = sample_ready & ~sample_ready_d;
assign bram_clk_posedge = bram_clock_genetate & ~bram_clk_sync_d;

// --------------------------------------------- Logic





//generate bram clock
always @(posedge system_clock) begin
    if(current_state == PLAY) begin
        if(bram_clock_counter == MAX_BRAM_CYCLES-1) begin
            bram_clock_counter <= 0;
            bram_clock_genetate <= ~bram_clock_genetate; // toggle clock
        end else begin
            bram_clock_counter <= bram_clock_counter + 1;
        end
    end else begin
        bram_clock_genetate <= 0;
        bram_clock_counter <= 0;
    end
end


always@(posedge system_clock)
begin 
    
    sample_ready_d <= sample_ready;
    bram_clk_sync_d <= bram_clock_genetate;
    
    case(current_state)
    
        IDLE:
        begin
           if(posedge_record)
           begin
                
                
                next_state <= RECORD;
                write_addr <= 0;
           end 
           
           else if(posedge_play)
           begin
           
                
                next_state <= PLAY;
                read_addr <= 0;
           
           end 
           
           
        end
        
        
        
        
        RECORD:
        begin
            
            if(write_addr > MAX_SAMPLES - 1 || posedge_stop)
            begin
                next_state <= IDLE;
            end
            
            else if(sample_ready_posedge)
            begin
                next_state <= RECORD;
                write_addr += 1;
            end
            
            
            
        end
        
        PLAY:
        begin
        
            if(read_addr > write_addr  || posedge_stop)
            begin
                next_state <= IDLE;
            end
            
            else if(bram_clk_posedge)
            begin
                next_state <= PLAY;
                read_addr += 1;
            end
            
            
            
        
        end
    
    



    endcase
    
    current_state <= next_state;
end


endmodule