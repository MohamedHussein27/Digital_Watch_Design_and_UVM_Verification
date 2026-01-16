// this interface is used to monitor the internal signals of out dut
interface dw_internal_if;
    logic normal_mode_en;
    logic setting_mode_en;
    logic alarm_mode_en;
    logic stopwatch_mode_en;
    logic setting_done;
    logic split_mode;
endinterface