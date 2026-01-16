import dw_test_pkg::*;
import dw_env_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module dw_top();
    bit clk;

    initial begin
        forever #1 clk = ~clk;
    end

    dw_if dwif (clk);
    dw_internal_if dw_int_if(); // to monitor internals in the dut
    Digital_Watch_Top dut (dwif);

    // setting the virtual interface to be accessible by the test
    initial begin
        uvm_config_db #(virtual dw_if)::set(null, "uvm_test_top", "dw_V", dwif); // main interface
        uvm_config_db #(virtual dw_internal_if)::set(null, "uvm_test_top", "dw_IV", dw_int_if);
        run_test ("dw_test");
    end

    // i wanted to monitor internal signlas in my design for coverage purposes so,
    // i made a new virtual interface that only contains them 
    // assign the dut internals to the internal interface 
    assign dw_int_if.normal_mode_en    = dut.normal_mode_en;
    assign dw_int_if.setting_mode_en   = dut.setting_mode_en;
    assign dw_int_if.alarm_mode_en     = dut.alarm_mode_en;
    assign dw_int_if.stopwatch_mode_en = dut.stopwatch_mode_en;
    assign dw_int_if.setting_done      = dut.setting_done;
    assign dw_int_if.split_mode        = dut.split_mode;
endmodule