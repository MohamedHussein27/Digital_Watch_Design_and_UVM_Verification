// this module is the top module that integrates Normal_Clock, StopWatch, and Digital_Watch FSM 
module Digital_Watch_Top (dw_if.DUT dwif);
    
    logic rst, mode, set;
    logic [1:0] tens_hours_out;  // tens hours logic (0-2)
    logic [3:0] units_hours_out; // units hours logic (0-9)
    logic [2:0] tens_minutes_out; // tens minutes logic (0-5)
    logic [3:0] units_minutes_out; // units minutes logic (0-9)
    logic alarm_sound;              // alarm sound logic

    // logics for display from StopWatch
    logic [5:0] stopwatch_min_out; // stopwatch minutes logic (0-59)
    logic [5:0] stopwatch_sec_out;
    
    
    // inputs assignment
    assign clk = dwif.clk;
    assign rst = dwif.rst;
    assign mode = dwif.mode;
    assign set = dwif.set;

    // outputs assignment
    assign dwif.tens_hours_out = tens_hours_out;
    assign dwif.units_hours_out = units_hours_out;
    assign dwif.tens_minutes_out = tens_minutes_out;
    assign dwif.units_minutes_out = units_minutes_out;
    assign dwif.alarm_sound = alarm_sound;
    assign dwif.stopwatch_min_out = stopwatch_min_out;
    assign dwif.stopwatch_sec_out = stopwatch_sec_out;

    
    // Control signals from Digital_Watch FSM
    wire normal_mode_en;
    wire setting_mode_en;
    wire alarm_mode_en;
    wire stopwatch_mode_en;

    // Signals from Normal_Clock
    wire setting_done;

    // Signals from StopWatch
    wire split_mode;

    // Instantiate Digital_Watch FSM
    Digital_Watch_FSM fsm_inst (
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .set(set),
        .setting_done(setting_done),
        .split_mode(split_mode),
        .normal_mode_en(normal_mode_en),
        .setting_mode_en(setting_mode_en),
        .alarm_mode_en(alarm_mode_en),
        .stopwatch_mode_en(stopwatch_mode_en)
    );

    // Instantiate Normal_Clock
    Normal_Clock clock_inst (
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .set(set),
        .normal_mode_en(normal_mode_en),
        .alarm_mode_en(alarm_mode_en),
        .setting_mode_en(setting_mode_en),
        .stopwatch_mode_en(stopwatch_mode_en),
        .setting_done(setting_done),
        .tens_hours_out(tens_hours_out),
        .units_hours_out(units_hours_out),
        .tens_minutes_out(tens_minutes_out),
        .units_minutes_out(units_minutes_out),
        .alarm_sound(alarm_sound)
    );

    // Instantiate StopWatch
    StopWatch stopwatch_inst (
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .set(set),
        .stopwatch_mode_en(stopwatch_mode_en),
        .min_out(stopwatch_min_out),
        .sec_out(stopwatch_sec_out),
        .split_mode(split_mode)
    );
endmodule