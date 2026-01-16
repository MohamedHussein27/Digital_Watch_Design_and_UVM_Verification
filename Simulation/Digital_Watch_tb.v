// this module is to test the Digital_Watch_Top module
// we are acting as the clock divider which supports 1Hz clock for the Digital_Watch_Top
`timescale 1s / 1ms
module Digital_Watch_tb;
    // Inputs
    reg clk;
    reg rst;
    reg mode;
    reg set;

    // Outputs
    wire [1:0] tens_hours_out;
    wire [3:0] units_hours_out;
    wire [2:0] tens_minutes_out;
    wire [3:0] units_minutes_out;
    wire alarm_sound;
    wire [5:0] stopwatch_min_out;
    wire [5:0] stopwatch_sec_out;

    // Instantiate the Digital_Watch_Top module
    Digital_Watch_Top uut (
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .set(set),
        .tens_hours_out(tens_hours_out),
        .units_hours_out(units_hours_out),
        .tens_minutes_out(tens_minutes_out),
        .units_minutes_out(units_minutes_out),
        .alarm_sound(alarm_sound),
        .stopwatch_min_out(stopwatch_min_out),
        .stopwatch_sec_out(stopwatch_sec_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #0.5 clk = ~clk;  // 1 Hz clock (toggle every 0.5 sec)
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst = 0;
        mode = 0;
        set = 0;
        @(negedge clk);
        rst = 1;

        // we will test the different modes of the digital watch here in this sequence
        // Normal Mode -> Set Time -> Set Alarm -> Stopwatch Mode -> Back to Normal Mode

        //*************************** first case: Normal Mode ***************************//
        mode = 0;
        repeat (300) @(negedge clk); // wait for 300 seconds (5 minutes)

        
        //*************************** second case: Set Time Mode ***************************//
        mode = 1; // move to Set Time Mode
        @(negedge clk);
        mode = 0;
        Set_Time_Alarm(2'd0, 4'd2, 3'd0, 4'd0); // Set time to 02:00

        
        //*************************** third case: Set Alarm Mode ***************************//
        mode = 1; // move to Set Alarm Mode
        @(negedge clk);
        mode = 0;
        Set_Time_Alarm(2'd0, 4'd2, 3'd0, 4'd5); // Set alarm to 02:05


        //*************************** fourth case: Stopwatch Mode (Elapsed Time) ***************************//
        mode = 1; // move to Stopwatch Mode
        @(negedge clk);
        mode = 0;
        StopWatch(0, 7, 12, 17, 22); // start at 0s, stop at 7s, resume at 12s, final stop at 17s, reset at 22s
        
        
        //*************************** fifth case: Stopwatch Mode (Split Time) ***************************//
        mode = 1; // move to Stopwatch Mode (split time)
        @(negedge clk);
        mode = 0;
        StopWatch(0, 7, 12, 17, 22); // start at 0s, split at 7s, split release at 12s, final stop at 17s, reset at 22s
        
        //*************************** sixth case: Back to Normal Mode ***************************//
        mode = 1; // move to Normal Mode
        @(negedge clk);
        mode = 0;
        repeat (300) @(negedge clk); // let it run for a while in normal mode
        // note: we will notice the alarm ringing at 02:05 if we set the time and alarm correctly
        
        // Finish simulation
        $stop;
    end

    // Set_Time_Alarm Task (takes 4 inputs for each digit) and it clicks the suitable number of times on set signal to set the time
    task Set_Time_Alarm;
        input [1:0] tens_hours_in;
        input [3:0] units_hours_in;
        input [2:0] tens_minutes_in;
        input [3:0] units_minutes_in;
        integer i;
        begin
            // Set Tens Hours
            for (i = 0; i < tens_hours_in; i = i + 1) begin
                @(negedge clk);
                set = 1;
                @(negedge clk);
                set = 0;
            end
            if (i == 0) @(negedge clk); // to handle the case of setting to 0
            mode = 1; // move to next digit
            @(negedge clk);
            mode = 0;
            // Set Units Hours
            for (i = 0; i < units_hours_in; i = i + 1) begin
                @(negedge clk);
                set = 1;
                @(negedge clk);
                set = 0;
            end
            if (i == 0) @(negedge clk); // to handle the case of setting to 0
            mode = 1; // move to next digit
            @(negedge clk);
            mode = 0;
            // Set Tens Minutes
            for (i = 0; i < tens_minutes_in; i = i + 1) begin
                @(negedge clk);
                set = 1;
                @(negedge clk);
                set = 0;
            end
            if (i == 0) @(negedge clk); // to handle the case of setting to 0
            mode = 1; // move to next digit
            @(negedge clk);
            mode = 0;
            // Set Units Minutes
            for (i = 0; i < units_minutes_in; i = i + 1) begin
                @(negedge clk);
                set = 1;
                @(negedge clk);
                set = 0;
            end
            if (i == 0) @(negedge clk); // to handle the case of setting to 0
        end
    endtask

    // StopWatch task should take 5 inputs:
    // 1- when to start
    // 2- when to stop, split if (split_mode)
    // 3- when to resume, split release if (split_mode)
    // 4- when to stop finally
    // 5- when to reset (clear)
    task StopWatch;
        input integer start_time;
        input integer stop_split_time;
        input integer resume_splitRelease_time;
        input integer final_stop_time;
        input integer reset_time;
        integer t; // time counter
        begin
            for (t = 0; t < start_time; t = t + 1) begin
                @(negedge clk);
            end
            set = 1; // start
            @(negedge clk);
            set = 0;
            for (t = 0; t < (stop_split_time - start_time) -1; t = t + 1) begin
                @(negedge clk);
            end
            set = 1; // stop or split
            @(negedge clk);
            set = 0;
            for (t = 0; t < (resume_splitRelease_time - stop_split_time) -1; t = t + 1) begin
                @(negedge clk);
            end
            set = 1; // resume or split release
            @(negedge clk);
            set = 0;
            for (t = 0; t < (final_stop_time - resume_splitRelease_time) -1; t = t + 1) begin
                @(negedge clk);
            end
            set = 1; // final stop
            @(negedge clk);
            set = 0;
            for (t = 0; t < (reset_time - final_stop_time) -1; t = t + 1) begin
                @(negedge clk);
            end
            set = 1; // reset
            @(negedge clk);
            set = 0;
        end
    endtask
endmodule