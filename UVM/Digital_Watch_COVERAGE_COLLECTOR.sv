package dw_coverage_collector_pkg;
    import dw_seq_item_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class dw_coverage_collector extends uvm_component;
        `uvm_component_utils(dw_coverage_collector)
        uvm_analysis_export #(dw_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(dw_seq_item) cov_fifo;

        dw_seq_item dw_item_cov;
        virtual dw_internal_if dw_internal_vif; // virtual interface (internal) (to monitor internals)

        // cover group
        covergroup dw_Group; // all crosses will be with read enable and write enable and each one of the output signals
            // cover points
            cp_mode: coverpoint dw_item_cov.mode;
            cp_set: coverpoint dw_item_cov.set;
            cp_tens_hours_out: coverpoint dw_item_cov.tens_hours_out{
                bins early_day = {0};
                bins mid_day = {1};
                bins late_day = {2};
                illegal_bins more_than_2 = {[3:$]}; // can't be more than 2
            }
            cp_units_hours_out: coverpoint dw_item_cov.units_hours_out{
                bins first_half = {[0:4]};
                bins senond_half = {[5:9]};
                illegal_bins more_than_9 = {[10:$]}; // can't be more than 9
            }
            cp_tens_minutes_out: coverpoint dw_item_cov.tens_minutes_out{
                bins start_of_hour = {[0:2]};
                bins half_an_hour = {3};
                bins almost_an_hour = {[4:5]};
                illegal_bins more_than_5 = {[6:$]}; // can't be more than 5
            }
            cp_units_minutes_out: coverpoint dw_item_cov.units_minutes_out{
                bins first_half = {[0:4]};
                bins senond_half = {[5:9]};
                illegal_bins more_than_9 = {[10:$]}; // can't be more than 9
            }
            cp_alarm_sound: coverpoint dw_item_cov.alarm_sound;
            cp_stopwatch_min_out: coverpoint dw_item_cov.stopwatch_min_out{
                bins start = {[0:10]};
                bins middle = {[20:40]};
                bins hit_max = {59};
                illegal_bins more_than_59 = {[60:$]}; // can't be more than 59

            } 
            cp_stopwatch_sec_out: coverpoint dw_item_cov.stopwatch_sec_out{
                bins start = {[0:10]};
                bins middle = {[20:40]};
                bins hit_max = {59};
                illegal_bins more_than_59 = {[60:$]}; // can't be more than 59
            }

            // internals
            cp_normal_mode_en: coverpoint dw_internal_vif.normal_mode_en;
            cp_setting_mode_en: coverpoint dw_internal_vif.setting_mode_en{
                bins count = (0 => 1);
            } // raise
            cp_alarm_mode_en: coverpoint dw_internal_vif.alarm_mode_en{
                bins count = (0 => 1);
            } // raise
            cp_split_mode: coverpoint dw_internal_vif.split_mode{
                bins elapsed_times = (1 => 0);
                bins split_times   = (0 => 1);
            } // raise and fall
            cp_setting_done: coverpoint dw_internal_vif.setting_done{
                bins done_count = (0 => 1);
            } // raise

            // cross coverage
            almost_new_day_C: cross cp_tens_hours_out, cp_units_hours_out, cp_tens_minutes_out, cp_units_minutes_out{ // when the clock is 23:59
                bins day_23_59 = binsof(cp_tens_hours_out) intersect {2} && 
                                 binsof(cp_units_hours_out) intersect {3} &&
                                 binsof(cp_tens_minutes_out) intersect {5} &&
                                 binsof(cp_units_minutes_out) intersect {9}; 
                                 option.cross_auto_bin_max = 0;
            } // cross coverage to indicate an end of a day

            day_start_day_C: cross cp_tens_hours_out, cp_units_hours_out, cp_tens_minutes_out, cp_units_minutes_out{ // when the clock is 23:59
                bins day_00_00 = binsof(cp_tens_hours_out) intersect {0} && 
                                 binsof(cp_units_hours_out) intersect {0} &&
                                 binsof(cp_tens_minutes_out) intersect {0} &&
                                 binsof(cp_units_minutes_out) intersect {0}; 
                                 option.cross_auto_bin_max = 0;
            } // cross coverage to indicate a start of a day
        endgroup

        function new (string name = "dw_coverage_collector", uvm_component parent = null);
            super.new(name, parent);
            dw_Group = new;
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(dw_item_cov);        
                dw_Group.sample();
            end
        endtask
    endclass
endpackage
