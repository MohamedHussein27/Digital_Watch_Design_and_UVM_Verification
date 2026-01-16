package dw_scoreboard_pkg;
    import dw_seq_item_pkg::*;
    import dw_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class dw_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(dw_scoreboard)
        uvm_analysis_export #(dw_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(dw_seq_item) sb_fifo;
        dw_seq_item seq_item_sb;


        // correct and error counter
        int normal_error_count = 0;
        int normal_correct_count = 0;
        int stopwatch_error_count = 0;
        int stopwatch_correct_count = 0;
        bit normal_clock_fail; // indicate a normal clock failed transaction
        bit stopwatch_fail; // indicates a stopwatch failed transaction

        // reference outputs
        // Normal_Clock
        logic [1:0] tens_hours_out_ref;
        logic [3:0] units_hours_out_ref;
        logic [2:0] tens_minutes_out_ref;
        logic [3:0] units_minutes_out_ref;
        bit alarm_sound_ref;

        // StopWatch
        logic [5:0] stopwatch_min_out_ref;
        logic [5:0] stopwatch_sec_out_ref;

        
        // internal signals
        bit timekeeping_task;
        bit time_setting_task;
        bit alarm_task;
        bit first_after_rst; // flag not to make the alarm sound after reset
        bit reset_1st_digit; // flag to reset the outputs in the first digit just for once
        
        bit setting_done;
        bit alarm_done;
        bit split_mode;
        bit load_set; // flag to indicate loading the set time into normal time


        // fixed array for setting digit
        bit which_digit[4];

        // array to store setting and alarm times (first four places are for setting, last for places are for alarm)
        bit [3:0] saved_values [8];

        int i = -1; // internal counter to determine which digit 
        int j = 0; // just for matching requirements in setting and alarm
        int k = 0; // flag for one clock delay in setting task
        int q = 0; // flag for one clock delay in timekeeping task
        
        // counters 
        int alarm_time = 0; // to make the alarm sound for only 20 seconds
        int stopwatch_counter = 0; // to determine the mode in stopwatch
        int stopwatch_elapsed_counter = 0; // counter to indicate which operation in elapsed mode in stopwatch
                                           // start -> stop -> resume -> stop -> clear
        int stopwatch_split_counter = 0; // counter to indicate which operation in split mode in stopwatch
        int stopwatch_internal_sec = 0; // for split mode
        int stopwatch_internal_min = 0; 
        int seconds = 0; // seconds counter

        function new(string name = "dw_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction


        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
        endfunction

        // connect
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        // run
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb);
                ref_model(seq_item_sb);
                normal_clock_fail = 0; // reset the normal_clock_fail transaction flag every new sequence item
                stopwatch_fail = 0;
                
                // compare for normal clock 
                if (seq_item_sb.tens_hours_out !== tens_hours_out_ref) begin
                    normal_clock_fail = 1;
                    $display("error in tens_hours_out at %0d", normal_error_count+1);
                    `uvm_error("run_phase", $sformatf("comparison normal_clock_failed transaction received by the DUT:%s while the reference out:0b%0b",
                    seq_item_sb.convert2string(), tens_hours_out_ref));
                end
                if (seq_item_sb.units_hours_out !== units_hours_out_ref) begin
                    normal_clock_fail = 1;
                    $display("error in units_hours_out at %0d", normal_error_count+1);
                    `uvm_error("run_phase", $sformatf("comparison normal_clock_failed transaction received by the DUT:%s while the reference out:0b%0b",
                    seq_item_sb.convert2string(), units_hours_out_ref));
                end
                if (seq_item_sb.tens_minutes_out !== tens_minutes_out_ref) begin
                    normal_clock_fail = 1;
                    $display("error in tens_minutes_out at %0d", normal_error_count+1);
                    `uvm_error("run_phase", $sformatf("comparison normal_clock_failed transaction received by the DUT:%s while the reference out:0b%0b",
                    seq_item_sb.convert2string(), tens_minutes_out_ref));
                end
                if (seq_item_sb.units_minutes_out !== units_minutes_out_ref) begin
                    normal_clock_fail = 1;
                    $display("error in units_minutes_out at %0d", normal_error_count+1);
                    `uvm_error("run_phase", $sformatf("comparison normal_clock_failed transaction received by the DUT:%s while the reference out:0b%0b",
                    seq_item_sb.convert2string(), units_minutes_out_ref));
                end
                if (seq_item_sb.alarm_sound !== alarm_sound_ref) begin
                    normal_clock_fail = 1;
                    $display("error in alarm_sound at %0d", normal_error_count+1);
                    `uvm_error("run_phase", $sformatf("comparison normal_clock_failed transaction received by the DUT:%s while the reference out:0b%0b",
                    seq_item_sb.convert2string(), alarm_sound_ref));
                end
                if (normal_clock_fail) begin
                    normal_error_count++;
                end
                else begin
                    `uvm_info("run_phase", $sformatf("correct normal clock out: %s", seq_item_sb.convert2string()), UVM_HIGH);
                    normal_correct_count++;
                end

                // compare for stopwatch
                if (seq_item_sb.stopwatch_min_out !== stopwatch_min_out_ref) begin
                    stopwatch_fail = 1;
                    $display("error in stopwatch_min_out at %0d", stopwatch_error_count+1);
                    `uvm_error("run_phase", $sformatf("comparison normal_clock_failed transaction received by the DUT:%s while the reference out:0b%0b",
                    seq_item_sb.convert2string(), stopwatch_min_out_ref));
                end
                if (seq_item_sb.stopwatch_sec_out !== stopwatch_sec_out_ref) begin
                    stopwatch_fail = 1;
                    $display("error in stopwatch_sec_out at %0d", stopwatch_error_count+1);
                    `uvm_error("run_phase", $sformatf("comparison normal_clock_failed transaction received by the DUT:%s while the reference out:0b%0b",
                    seq_item_sb.convert2string(), stopwatch_sec_out_ref));
                end
                if (stopwatch_fail) begin
                    stopwatch_error_count++;
                end
                else begin
                    `uvm_info("run_phase", $sformatf("correct stopwatch out: %s", seq_item_sb.convert2string()), UVM_HIGH);
                    stopwatch_correct_count++;
                end
            end
        endtask

        // reference model
        task ref_model (dw_seq_item seq_item_chk);
            // assigning reference variables
            if(!seq_item_chk.rst) begin
                // counters
                i = -1;
                j = 0;
                k = 0;
                q = 0;
                stopwatch_counter = 0;
                // Normal clock
                tens_hours_out_ref = 2'd0;
                units_hours_out_ref = 4'd0;
                tens_minutes_out_ref = 3'd0;
                units_minutes_out_ref = 4'd0;
                saved_values = '{default:0}; // delete all the saved values either for alarm or setting
                seconds = 0;
                which_digit = '{default:0}; 
                first_after_rst = 1; // flag not ot make the alarm sound after rst
                reset_1st_digit = 1;
                load_set = 1;
                // tasks flags
                timekeeping_task = 1; 
                time_setting_task = 0;
                alarm_task = 0;
                stopwatch_task = 0;
                setting_done = 0;
                alarm_done = 0;
                next_is_stopwatch = 0;
                // stopwatch
                stopwatch_min_out_ref = 0;
                stopwatch_sec_out_ref = 0; 
                stopwatch_internal_min = 0;
                stopwatch_internal_sec = 0;
                split_mode = 0;
            end
            else begin
                // if mode so go to the setting operation, but if 4 times mode is pressed go to the next operation 
                if (seq_item_chk.mode && !setting_done) begin
                    // flags
                    time_setting_task = 1;
                    alarm_task = 0;
                    timekeeping_task = 0;
                    stopwatch_task = 0;
                    first_after_rst = 0;
                    split_mode = 0;
                    which_digit = '{default:0};
                    i++;
                    which_digit[i] = 1;
                    load_set = 1;
                    seconds = 0; // reset seconds counter when going to setting
                    time_setting(seq_item_chk); // go to time setting task
                end
                else if (seq_item_chk.mode && !alarm_done) begin
                    // flags
                    alarm_task = 1;
                    timekeeping_task = 0;
                    time_setting_task = 0;
                    stopwatch_task = 0;
                    which_digit = '{default:0};
                    i++;
                    which_digit[i] = 1;
                    stopwatch_elapsed_counter = 0;
                    stopwatch_split_counter = 0;
                    q = 0;
                    alarm(seq_item_chk); // go to alarm task
                end
                else if (seq_item_chk.mode && stopwatch_counter < 2) begin
                    stopwatch_task = 1;
                    timekeeping_task = 0;
                    time_setting_task = 0;
                    alarm_task = 0;
                    j = 0;
                    if (stopwatch_counter == 1) j = 1; // after first enter to the stopwatch task make the split high as when second entry the mode turns to split mode
                    fork // run normal clock along with the stopwatch
                        begin
                            stopwatch(seq_item_chk); // go to stopwatch task
                        end
                        begin
                            if (q == 0) // just for matching the dut in time
                                q = 1;
                            else
                                timekeeping(seq_item_chk);
                        end
                    join
                    stopwatch_counter++;
                end
                // normal clock conditions
                else if (seq_item_chk.mode && stopwatch_counter == 2) begin
                    timekeeping(seq_item_chk);
                    timekeeping_task = 1;
                    stopwatch_task = 0;
                    split_mode = 0; // make it the default
                    time_setting_task = 0;
                    alarm_task = 0;
                    setting_done = 0;
                    alarm_done = 0;
                    next_is_stopwatch = alarm_done; 
                    stopwatch_counter = 0;
                    j = 0;
                end

                // following checks is for if user didn't press mode and we are still in specific operation
                if (time_setting_task && !seq_item_chk.mode) time_setting(seq_item_chk);
                else if (alarm_task && !seq_item_chk.mode) alarm(seq_item_chk);
                else if (stopwatch_task && !seq_item_chk.mode) begin 
                    if (j == 1) begin 
                        split_mode = 1; // i just did this to delay it one cylce to match dut
                        j = 0;
                    end
                    fork // run normal clock along with the stopwatch
                        begin
                            stopwatch(seq_item_chk); // go to stopwatch task
                        end
                        begin
                            timekeeping(seq_item_chk);
                        end
                    join  
                end   
                else if (timekeeping_task && !seq_item_chk.mode) timekeeping(seq_item_chk);   
            end
        endtask

        // this task is to make the clock runs normally
        task timekeeping (dw_seq_item seq_item_chk);        
            if (seconds < 59)
                seconds++;
            else begin
                seconds = 0;
                if (units_minutes_out_ref < 9)
                    units_minutes_out_ref++;  // Increment units of minutes
                else begin
                    units_minutes_out_ref = 0;  // Reset units of minutes
                    if (tens_minutes_out_ref < 5)
                        tens_minutes_out_ref++;  // Increment tens of minutes
                    else begin
                        tens_minutes_out_ref = 0;  // Reset tens of minutes
                        if (units_hours_out_ref < 9 && tens_hours_out_ref != 2)
                            units_hours_out_ref++;  // Increment units of hours
                        else begin
                            units_hours_out_ref = 0;  // Reset units of hours
                            if (tens_hours_out_ref < 2)
                                tens_hours_out_ref++;  // Increment tens of hours
                            else
                                tens_hours_out_ref = 0;  // Reset hours (24-hour cycle)
                        end
                    end
                end
            end  
            // for loading the setting time into the normal time
            if (stopwatch_task && load_set) begin
                tens_hours_out_ref = saved_values[0];
                units_hours_out_ref = saved_values[1];
                tens_minutes_out_ref = saved_values[2];
                units_minutes_out_ref = saved_values[3];
                load_set = 0;
            end
            // if we are not in the stopwatch reset its signals
            if(!stopwatch_task) begin
                stopwatch_min_out_ref = 0;
                stopwatch_sec_out_ref = 0; 
                stopwatch_internal_min = 0;
                stopwatch_internal_sec = 0;
                split_mode = 0;
            end
            // alarm time matching with normal time check to enable the alarm sound
            if (tens_hours_out_ref == saved_values[4] && units_hours_out_ref == saved_values[5] && 
                tens_minutes_out_ref == saved_values[6] && units_minutes_out_ref == saved_values[7] &&
                alarm_time < 21 && !first_after_rst && !stopwatch_task) begin
                if (alarm_time != 0) alarm_sound_ref = 1;
                alarm_time++;
            end
            else
                alarm_sound_ref = 0;        
        endtask

        // this task is to set the time 
        task time_setting (dw_seq_item seq_item_chk);
            if (time_setting_task) begin
                // resetting all values at beggining of setting
                if (k == 1) begin
                    if (!seq_item_chk.set) // as if set at first we will incerement the digit at the moment, so we need to prevent the reset
                        tens_hours_out_ref = 2'd0;
                    units_hours_out_ref = 4'd0;
                    tens_minutes_out_ref = 3'd0;
                    units_minutes_out_ref = 4'd0;
                    k = 0;
                end
                if (reset_1st_digit && which_digit[0]) begin
                    k = 1; // flag for timing purposes
                    reset_1st_digit = 0;
                end
                if (which_digit[0]) begin
                    // resetting all values at beggining of setting
                    if (reset_1st_digit) begin
                        tens_hours_out_ref = 2'd0;
                        units_hours_out_ref = 4'd0;
                        tens_minutes_out_ref = 3'd0;
                        units_minutes_out_ref = 4'd0;
                        reset_1st_digit = 0;
                    end
                    if(seq_item_chk.set) begin
                        if (tens_hours_out_ref < 2)
                            tens_hours_out_ref++;
                        else
                            tens_hours_out_ref = 0;
                    end
                end
                else if (which_digit[1]) begin
                    if(seq_item_chk.set) begin
                        if (tens_hours_out_ref == 2)
                            if (units_hours_out_ref < 3)
                                units_hours_out_ref++;
                            else
                                units_hours_out_ref = 0;
                        else if (units_hours_out_ref < 9)
                            units_hours_out_ref++;
                        else
                            units_hours_out_ref = 0;
                    end
                end
                else if (which_digit[2]) begin
                    if(seq_item_chk.set) begin
                        if (tens_minutes_out_ref < 5)
                            tens_minutes_out_ref++;
                        else 
                            tens_minutes_out_ref = 0;
                    end
                end
                else if (which_digit[3]) begin
                    setting_done = 1;
                    i = -1; // reset i for the alarm setting mode
                    if(seq_item_chk.set) begin
                        if (units_minutes_out_ref < 9) 
                            units_minutes_out_ref++;
                        else 
                            units_minutes_out_ref = 0;
                    end
                    saved_values[0] = tens_hours_out_ref;
                    saved_values[1] = units_hours_out_ref;
                    saved_values[2] = tens_minutes_out_ref;
                    saved_values[3] = units_minutes_out_ref;
                    reset_1st_digit = 1; // making it high for alarm setting
                end
            end
        endtask

        // this task is to set the alarm time
        task alarm (dw_seq_item seq_item_chk);
            if (alarm_task) begin
                // resetting all values at beggining of setting
                if (reset_1st_digit && which_digit[0] && j == 1) begin
                    if (!seq_item_chk.set) // as if set at first we will incerement the digit at the moment, so we need to prevent the reset
                        tens_hours_out_ref = 2'd0;
                    units_hours_out_ref = 4'd0;
                    tens_minutes_out_ref = 3'd0;
                    units_minutes_out_ref = 4'd0;
                    reset_1st_digit = 0;
                end
                j++;
                if (which_digit[0]) begin
                    if(seq_item_chk.set) begin
                        if (tens_hours_out_ref < 2)
                            tens_hours_out_ref++;
                        else
                            tens_hours_out_ref = 0;
                    end
                end
                else if (which_digit[1]) begin
                    if(seq_item_chk.set) begin
                        if (tens_hours_out_ref == 2)
                            if (units_hours_out_ref < 3)
                                units_hours_out_ref++;
                            else
                                units_hours_out_ref = 0;
                        else if (units_hours_out_ref < 9)
                            units_hours_out_ref++;
                        else
                            units_hours_out_ref = 0;
                    end
                end
                else if (which_digit[2]) begin
                    if(seq_item_chk.set) begin
                        if (tens_minutes_out_ref < 5)
                            tens_minutes_out_ref++;
                        else 
                            tens_minutes_out_ref = 0;
                    end
                end
                else if (which_digit[3]) begin
                    alarm_done = 1;
                    next_is_stopwatch = alarm_done;
                    i = -1; // reset i for the time setting mode
                    if(seq_item_chk.set) begin
                        if (units_minutes_out_ref < 9) 
                            units_minutes_out_ref++;
                        else 
                            units_minutes_out_ref = 0;
                    end
                    saved_values[4] = tens_hours_out_ref;
                    saved_values[5] = units_hours_out_ref;
                    saved_values[6] = tens_minutes_out_ref;
                    saved_values[7] = units_minutes_out_ref;
                    reset_1st_digit = 1; // making it high for next time
                end
            end
        endtask

        // this task it to begin stopwatch
        task stopwatch (dw_seq_item seq_item_chk);
            if(split_mode) begin
                split_mode = 1;
                stopwatch_elapsed_counter = 0;
                // start again in the next mode
                if (stopwatch_split_counter == 0) begin
                    stopwatch_min_out_ref = 0;
                    stopwatch_sec_out_ref = 0; 
                    stopwatch_internal_min = 0;
                    stopwatch_internal_sec = 0;
                end
                if (seq_item_chk.set && !seq_item_chk.mode) begin
                    stopwatch_split_counter++;
                end
                if (stopwatch_split_counter != 0 && (stopwatch_split_counter != 4 || stopwatch_split_counter != 5)) begin // internal counters run when it's not stop nor clear
                    if (stopwatch_internal_sec < 59)
                        stopwatch_internal_sec++;
                    else begin
                        stopwatch_internal_sec = 0;
                        if (stopwatch_internal_min < 59)
                            stopwatch_internal_min++;
                        else 
                            stopwatch_internal_min = 0;
                    end
                end 
                if (stopwatch_split_counter == 1 || stopwatch_split_counter == 3) begin // 1 -> start, 3 -> release split
                    stopwatch_min_out_ref = stopwatch_internal_min;
                    stopwatch_sec_out_ref = stopwatch_internal_sec;
                end
                if (stopwatch_split_counter == 2 || stopwatch_split_counter == 4) begin // 2 -> split (1st), 4 -> stop
                    stopwatch_min_out_ref = stopwatch_min_out_ref;
                    stopwatch_sec_out_ref = stopwatch_sec_out_ref;                    
                end
                if (stopwatch_split_counter == 5) begin // clear
                    stopwatch_min_out_ref = 0;
                    stopwatch_sec_out_ref = 0; 
                    stopwatch_internal_min = 0;
                    stopwatch_internal_sec = 0;
                    stopwatch_split_counter = 0;
                end
            end
            else if (j != 1 && !split_mode) begin // elapsed mode
                split_mode = 0;
                stopwatch_split_counter = 0;
                // start agai
                if (stopwatch_elapsed_counter == 0) begin
                    stopwatch_min_out_ref = 0;
                    stopwatch_sec_out_ref = 0; 
                    stopwatch_internal_min = 0;
                    stopwatch_internal_sec = 0;
                end
                if (seq_item_chk.set && !seq_item_chk.mode) begin
                    stopwatch_elapsed_counter++;
                end
                if (stopwatch_elapsed_counter == 1 || stopwatch_elapsed_counter == 3) begin // 1 -> start, 3 -> resume
                    if (stopwatch_sec_out_ref < 59)
                        stopwatch_sec_out_ref++;
                    else begin
                        stopwatch_sec_out_ref = 0;
                        if (stopwatch_min_out_ref < 59)
                            stopwatch_min_out_ref++;
                        else 
                            stopwatch_min_out_ref = 0;
                    end
                end 
                if (stopwatch_elapsed_counter == 2 || stopwatch_elapsed_counter == 4) begin // 2 -> stop (1st), 4 -> stop(2nd)
                    stopwatch_min_out_ref = stopwatch_min_out_ref;
                    stopwatch_sec_out_ref = stopwatch_sec_out_ref;                    
                end
                if (stopwatch_elapsed_counter == 5) begin // clear
                    stopwatch_min_out_ref = 0;
                    stopwatch_sec_out_ref = 0; 
                    stopwatch_elapsed_counter = 0;
                end
            end
        endtask
        
        // report
        function void report_phase(uvm_phase phase);
            int total_success_rand;
            int total_fail_rand;
            real success_rate;

            super.report_phase(phase);

            // Calculate totals
            total_success_rand = normal_correct_count + stopwatch_correct_count;
            total_fail_rand    = normal_error_count + stopwatch_error_count;

            // Calculate Success Rate (Avoid division by zero)
            if ((total_success_rand + total_fail_rand) > 0) begin
                success_rate = (real'(total_success_rand) / (total_success_rand + total_fail_rand)) * 100.0;
            end else begin
                success_rate = 0.0;
            end

            // Display formatted summary
            `uvm_info("STIM_SUMMARY", $sformatf("\n\n*** Randomization + Directed Stimulus Summary ***\ntotal successful transactions: %0d\nSuccess Rate: %0.2f%%", 
                    total_success_rand, success_rate), UVM_MEDIUM)

        endfunction
    endclass
endpackage