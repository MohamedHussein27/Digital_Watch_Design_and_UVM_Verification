interface dw_if (clk);
    input clk;
    
    // signals
    logic rst, mode, set;
    logic [1:0] tens_hours_out;  // tens hours logic (0-2)
    logic [3:0] units_hours_out; // units hours logic (0-9)
    logic [2:0] tens_minutes_out; // tens minutes logic (0-5)
    logic [3:0] units_minutes_out; // units minutes logic (0-9)
    logic alarm_sound;              // alarm sound logic

    // logics for display from StopWatch
    logic [5:0] stopwatch_min_out; // stopwatch minutes logic (0-59)
    logic [5:0] stopwatch_sec_out;

    // dut module 
    modport DUT (
        input clk, rst, mode, set,
        output tens_hours_out, units_hours_out, tens_minutes_out, units_minutes_out, alarm_sound, 
        stopwatch_min_out, stopwatch_sec_out
    );
endinterface