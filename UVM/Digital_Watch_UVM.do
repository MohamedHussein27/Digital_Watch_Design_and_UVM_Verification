vlib work
vlog -f digital_watch_files.txt +cover -covercells
vsim -voptargs=+acc work.dw_top -cover
add wave /dw_top/dwif/*
coverage save top.ucdb -onexit
run 0
add wave -position insertpoint  \
sim:/dw_top/dut/fsm_inst/Normal \
sim:/dw_top/dut/fsm_inst/SetTime \
sim:/dw_top/dut/fsm_inst/SetAlarm \
sim:/dw_top/dut/fsm_inst/StopWatch \
sim:/dw_top/dut/fsm_inst/clk \
sim:/dw_top/dut/fsm_inst/rst \
sim:/dw_top/dut/fsm_inst/mode \
sim:/dw_top/dut/fsm_inst/set \
sim:/dw_top/dut/fsm_inst/setting_done \
sim:/dw_top/dut/fsm_inst/split_mode \
sim:/dw_top/dut/fsm_inst/normal_mode_en \
sim:/dw_top/dut/fsm_inst/setting_mode_en \
sim:/dw_top/dut/fsm_inst/alarm_mode_en \
sim:/dw_top/dut/fsm_inst/stopwatch_mode_en \
sim:/dw_top/dut/fsm_inst/current_state \
sim:/dw_top/dut/fsm_inst/next_state \
sim:/dw_top/dut/clock_inst/sec_count \
sim:/dw_top/dut/clock_inst/set_hours \
sim:/dw_top/dut/clock_inst/set_minutes \
sim:/dw_top/dut/clock_inst/alarm_minutes \
sim:/dw_top/dut/clock_inst/alarm_hours \
sim:/dw_top/dut/clock_inst/alarm_counter \

add wave -position insertpoint  \
sim:/uvm_root/uvm_test_top/env/sb/sb_export \
sim:/uvm_root/uvm_test_top/env/sb/seconds \
sim:/uvm_root/uvm_test_top/env/sb/stopwatch_internal_min \
sim:/uvm_root/uvm_test_top/env/sb/stopwatch_internal_sec \
sim:/uvm_root/uvm_test_top/env/sb/stopwatch_split_counter \
sim:/uvm_root/uvm_test_top/env/sb/stopwatch_elapsed_counter \
sim:/uvm_root/uvm_test_top/env/sb/stopwatch_counter \
sim:/uvm_root/uvm_test_top/env/sb/i \
sim:/uvm_root/uvm_test_top/env/sb/saved_values \
sim:/uvm_root/uvm_test_top/env/sb/which_digit \
sim:/uvm_root/uvm_test_top/env/sb/split_mode \
sim:/uvm_root/uvm_test_top/env/sb/alarm_done \
sim:/uvm_root/uvm_test_top/env/sb/setting_done \
sim:/uvm_root/uvm_test_top/env/sb/alarm_task \
sim:/uvm_root/uvm_test_top/env/sb/time_setting_task \
sim:/uvm_root/uvm_test_top/env/sb/timekeeping_task \
sim:/uvm_root/uvm_test_top/env/sb/stopwatch_sec_out_ref \
sim:/uvm_root/uvm_test_top/env/sb/stopwatch_min_out_ref \
sim:/uvm_root/uvm_test_top/env/sb/alarm_sound_ref \
sim:/uvm_root/uvm_test_top/env/sb/units_minutes_out_ref \
sim:/uvm_root/uvm_test_top/env/sb/tens_minutes_out_ref \
sim:/uvm_root/uvm_test_top/env/sb/units_hours_out_ref \
sim:/uvm_root/uvm_test_top/env/sb/tens_hours_out_ref \
sim:/uvm_root/uvm_test_top/env/sb/stopwatch_fail \
sim:/uvm_root/uvm_test_top/env/sb/normal_clock_fail \
sim:/uvm_root/uvm_test_top/env/sb/stopwatch_correct_count \
sim:/uvm_root/uvm_test_top/env/sb/stopwatch_error_count \
sim:/uvm_root/uvm_test_top/env/sb/normal_correct_count \
sim:/uvm_root/uvm_test_top/env/sb/normal_error_count \
sim:/uvm_root/uvm_test_top/env/sb/seq_item_sb \
sim:/uvm_root/uvm_test_top/env/sb/reset_1st_digit \
sim:/uvm_root/uvm_test_top/env/sb/k \
sim:/dw_shared_pkg::stopwatch_task \
sim:/dw_shared_pkg::directed_begin \
sim:/dw_shared_pkg::keep_low \
sim:/dw_shared_pkg::prev_mode \
sim:/dw_shared_pkg::flag \
sim:/dw_shared_pkg::consecutive \
sim:/dw_shared_pkg::consecutive_set
run -all