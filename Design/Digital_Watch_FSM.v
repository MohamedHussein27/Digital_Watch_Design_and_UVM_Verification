// this module acts as the controlling unit for a digital watch which can display hours, minutes and set alarm and make a stop watch function
module Digital_Watch_FSM (
    input clk,
    input rst,
    input mode, // to transition between time display, set time, alarm set, and stopWatch 
    input set,  // to set the time or alarm

    // inputs from Normal_Clock
    input setting_done, // to indicate if setting is done (we are in the last digit, most right)

    // inputs from StopWatch
    input split_mode, // to indicate if it's in split time mode as if mode=1 we will go back to normal time
    
    // control signals to Normal_Clock 
    output reg normal_mode_en, // to enable normal clock display mode
    output reg setting_mode_en, // to enable setting mode to set the time
    output reg alarm_mode_en, // to enable alarm setting mode
    output reg stopwatch_mode_en // to enable stopwatch mode
);
    localparam Normal = 2'b00,
               SetTime = 2'b01,
               SetAlarm = 2'b10,
               StopWatch = 2'b11;
    
    reg [1:0] current_state, next_state;
    
    // state memory
    always @(posedge clk or negedge rst) begin
        if (!rst)
            current_state <= Normal; // start in SetTime mode
        else
            current_state <= next_state;
    end

    // next state logic
    always @(*) begin
        case (current_state) // use mode to transition between modes
            Normal: begin
                if (mode) next_state = SetTime;
                else next_state = Normal;
            end
            SetTime: begin
                if (mode && setting_done) next_state = SetAlarm;
                else next_state = SetTime;
            end
            SetAlarm: begin
                if (mode && setting_done) next_state = StopWatch;
                else next_state = SetAlarm;
            end
            StopWatch: begin
                if (mode && split_mode) next_state = Normal;
                else next_state = StopWatch;
            end
            default: next_state = Normal;
        endcase
    end

    // output logic 
    always @(*) begin
        // Default values for all outputs 
        normal_mode_en = 1'b0; 
        setting_mode_en = 1'b0;
        alarm_mode_en = 1'b0;
        stopwatch_mode_en = 1'b0;    

        case(current_state)
            Normal: begin
                normal_mode_en = 1'b1;
            end
            SetTime: begin
                setting_mode_en = 1'b1;
            end
            SetAlarm: begin
                alarm_mode_en = 1'b1;
            end
            StopWatch: begin
                stopwatch_mode_en = 1'b1;
                normal_mode_en = 1'b1;
            end            
            default: begin  // Default case handles Normal mode
                normal_mode_en = 1'b1;
            end
        endcase
    end
endmodule