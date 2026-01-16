// this module is to generate the seconds, minutes and hours for normal display mode in the digital watch
module Normal_Clock (
    input wire clk,               // system clock
    input wire rst,            // active low reset
    input wire mode,            // mode signal to switch between normal mode and setting mode
    input wire set,             // set signal to increment the time in setting mode

    // fsm control signals
    input wire normal_mode_en,    // normal_mode_enble signal
    input wire alarm_mode_en,     // alarm_mode_enable signal
    input wire setting_mode_en,   // setting_mode_enable signal
    input wire stopwatch_mode_en,  // i use it in alarm sound control

    // outputs for fsm
    output reg setting_done,      // to indicate if setting is done (we are in the last digit, most right)
    
    // display outputs
    output [1:0] tens_hours_out,  // tens hours output (0-2)
    output [3:0] units_hours_out, // units hours output (0-9)
    output [2:0] tens_minutes_out, // tens minutes output (0-5)
    output [3:0] units_minutes_out, // units minutes output (0-9)
    output alarm_sound              // alarm sound output
);
    // Digits internal signals
    reg [1:0] tens_hours; // represents the left digit of hours (0-2) (most left)
    reg [3:0] units_hours; // represents the right digit of hours (0-9)
    reg [2:0] tens_minutes; // represents the left digit of minutes (0-5)
    reg [3:0] units_minutes; // represents the right digit of minutes (0-9) (most right)   

    reg [1:0] setting_digit; // to indicate which digit is being set from left to right

    
    // seconds counter
    reg [5:0] sec_count;    // seconds output (0-59)
    
    // Setting mode internal signals
    reg [5:0] set_hours;
    reg [6:0] set_minutes;
    reg zero_start; // flag to make the outputs to be zeroes at the beginning of setting
    
    // Alarm mode internal signals
    reg [5:0] alarm_hours;
    reg [6:0] alarm_minutes;
    reg [4:0] alarm_counter; // alarm should sound for a 20 seconds duration
    reg alarm_active;      // to indicate if alarm is currently active
    reg alarm_done;        // to indicate if alarm setting is done, use this to begin the normal time with value saved in set_hours and set_minutes
    reg first_alarm;    // to indicate the first time alarm is set, to keep alarm shut when reset 
    reg load_set; // flag to load the set time into normal time when stopwatch mode is on
    // Seconds counter
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            sec_count <= 6'd0;
        end 
        else if (setting_mode_en || alarm_mode_en) begin
            // In setting mode, seconds reset to 0 and the time is paused until setting is done
            sec_count <= 6'd0;
        end 
        else begin // if any mode but setting the watch will work
            if (sec_count == 6'd59) begin
                sec_count <= 6'd0;
            end else begin
                sec_count <= sec_count + 6'd1;
            end
        end
    end

    // Hours and Minutes counter (both in the same always block)
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            tens_hours <= 2'd0;
            units_hours <= 4'd0;
            units_minutes <= 4'd0;
            tens_minutes <= 3'd0;
            setting_digit <= 2'b00;
            setting_done <= 1'b0;
            zero_start <= 1'b0;
            load_set <= 1'b1;
        end 
        else begin 
            if (setting_mode_en || alarm_mode_en) begin
                load_set <= 1'b1; // set the flag to load the set time when back to normal mode
                // In setting mode, the time is paused until setting is done
                // choosing the digit being set
                if (!setting_digit) begin
                    if (!zero_start) begin
                        setting_done <= 1'b0; // reset setting done flag
                        tens_hours <= 2'd0;
                        units_hours <= 4'd0;
                        units_minutes <= 4'd0;
                        tens_minutes <= 3'd0;
                        zero_start <= 1'b1; // make it high again
                    end
                    if (mode) begin // transition to the next digit
                        setting_digit <= 2'b01; // move to next digit
                    end
                    else if (set && tens_hours < 2) begin // make sure tens of hours does not exceed 2
                        tens_hours <= tens_hours + 1;
                    end
                    else if (set) begin
                        tens_hours <= 0;
                    end
                end
                else if (setting_digit == 2'b01) begin
                    if (mode) begin // transition to the next digit
                        setting_digit <= 2'b10; // move to next digit
                    end
                    else if (set && units_hours < 9 && tens_hours != 2) begin // make sure units of hours does not exceed 9
                        units_hours <= units_hours + 1;
                    end
                    else if (set && units_hours < 3 && tens_hours == 2) begin // make sure units of hours does not exceed 9
                        units_hours <= units_hours + 1;
                    end
                    else if (set) begin
                        units_hours <= 0;     
                    end
                    zero_start <= 1'b0; // make the flag low as when coming agian to the first digit
                end
                else if (setting_digit == 2'b10) begin
                    if (mode) begin // transition to the next digit
                        setting_digit <= 2'b11; // move to next digit
                    end
                    else if (set && tens_minutes < 5) begin // make sure tens of minutes does not exceed 5
                        tens_minutes <= tens_minutes + 1;
                    end
                    else if (set) begin
                        tens_minutes <= 0;
                    end
                end
                else if (setting_digit == 2'b11) begin
                    setting_done <= 1'b1; // indicate setting is done
                    if (mode) begin
                        setting_digit <= 2'b00; // reset to first digit
                    end
                    else if (set && units_minutes < 9) begin // make sure units of minutes does not exceed 9
                        units_minutes <= units_minutes + 1;
                    end
                    else if (set) begin
                        units_minutes <= 0;
                    end
                end
            end
            else if (normal_mode_en) begin
                if (load_set && stopwatch_mode_en) begin
                    {tens_minutes, units_minutes} <= set_minutes; // load the set minutes
                    {tens_hours, units_hours} <= set_hours;       // load the set hours
                    load_set <= 1'b0;
                end
                else begin
                    if (sec_count == 6'd59) begin
                        if (units_minutes == 4'd9 && tens_minutes == 3'd5) begin
                            units_minutes <= 4'd0;
                            tens_minutes <= 3'd0;
                        end
                        else if (units_minutes < 9) begin
                            units_minutes <= units_minutes + 1; // increment units of minutes
                        end
                        else begin
                            tens_minutes <= tens_minutes + 1; // increment tens of minutes
                            units_minutes <= 4'd0;
                        end
                    end
                    if (sec_count == 6'd59 && units_minutes == 4'd9 && tens_minutes == 3'd5) begin
                        if (tens_hours == 2'd2 && units_hours == 4'd3) begin
                            tens_hours <= 2'd0;
                            units_hours <= 4'd0;
                        end 
                        else if (units_hours < 4'd9) begin
                            units_hours <= units_hours + 4'd1;
                        end 
                        else begin
                            tens_hours <= tens_hours + 2'd1;
                            units_hours <= 4'd0;
                        end
                    end
                end
            end
        end
    end

    // Setting time mode/Alarm mode always block to save the setting time/alarm time
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            alarm_hours <= 6'd0;
            alarm_minutes <= 7'd0;
            set_hours <= 6'd0;
            set_minutes <= 7'd0;
            alarm_done <= 1'b0;
            first_alarm <= 1'b0;
        end else if  (setting_mode_en) begin
            set_hours <= {tens_hours, units_hours}; // combine tens and units hours
            set_minutes <= {tens_minutes, units_minutes}; // combine tens and units minutes
        end else if (alarm_mode_en) begin
            alarm_hours <= {tens_hours, units_hours}; // combine tens and units hours
            alarm_minutes <= {tens_minutes, units_minutes}; // combine tens and units minutes
            alarm_done <= 1'b1;
            first_alarm <= 1'b1;
        end
        else begin // if normal or stopwatch mode turn off the alarm done signal
            alarm_done <= 1'b0; // reset alarm done flag 
        end
    end

    // Alarm sound control
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            alarm_counter <= 5'd0;
            alarm_active <= 1'b0;
        end else if ((alarm_hours == {tens_hours, units_hours}) && (alarm_minutes == {tens_minutes, units_minutes})) begin
            if (normal_mode_en && !stopwatch_mode_en && !alarm_mode_en && first_alarm && alarm_counter < 5'd20) begin
                /*if (alarm_counter > 1)*/ alarm_active <= 1'b1;
                alarm_counter <= alarm_counter + 5'd1; // count up to 20 seconds
            end
            else begin
                alarm_active <= 1'b0;
            end
        end
        else begin
            alarm_active <= 1'b0;
            alarm_counter <= 5'd0; // reset counter when time does not match alarm time
        end
    end

    // Output assignments
    assign tens_hours_out = tens_hours;
    assign units_hours_out = units_hours;
    assign tens_minutes_out = tens_minutes;
    assign units_minutes_out = units_minutes;
    // alarm should sound when current time matches alarm time
    assign alarm_sound = alarm_active;
endmodule