package dw_monitor_pkg;
    import dw_seq_item_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"   
    class dw_monitor extends uvm_monitor;
        `uvm_component_utils(dw_monitor)

        virtual dw_if dw_vif; // virtual interface
        dw_seq_item rsp_seq_item; // sequence item
        uvm_analysis_port #(dw_seq_item) mon_ap;

        function new(string name = "dw_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        // building share point
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new("mon_ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                rsp_seq_item = dw_seq_item::type_id::create("rsp_seq_item");
                @(negedge dw_vif.clk);
                rsp_seq_item.rst = dw_vif.rst;
                rsp_seq_item.mode = dw_vif.mode;
                rsp_seq_item.set = dw_vif.set;
                rsp_seq_item.tens_hours_out = dw_vif.tens_hours_out;
                rsp_seq_item.units_hours_out = dw_vif.units_hours_out;
                rsp_seq_item.tens_minutes_out = dw_vif.tens_minutes_out;
                rsp_seq_item.units_minutes_out = dw_vif.units_minutes_out;
                rsp_seq_item.alarm_sound = dw_vif.alarm_sound;
                rsp_seq_item.stopwatch_min_out = dw_vif.stopwatch_min_out;
                rsp_seq_item.stopwatch_sec_out = dw_vif.stopwatch_sec_out;
                mon_ap.write(rsp_seq_item);
                `uvm_info("run_phase", rsp_seq_item.convert2string(), UVM_HIGH);
            end
        endtask
    endclass
endpackage