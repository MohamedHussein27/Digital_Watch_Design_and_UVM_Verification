package dw_seq_item_pkg;
    import dw_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class dw_seq_item extends uvm_sequence_item;
        `uvm_object_utils(dw_seq_item)

        // dw constraints
        bit clk;
        rand bit rst;
        rand bit mode;
        rand bit set;
        logic [1:0] tens_hours_out;  // tens hours output (0-2)
        logic [3:0] units_hours_out; // units hours output (0-9)
        logic [2:0] tens_minutes_out; // tens minutes output (0-5)
        logic [3:0] units_minutes_out; // units minutes output (0-9)
        logic alarm_sound;             // alarm sound output

        // outputs for display from StopWatch
        logic [5:0] stopwatch_min_out; // stopwatch minutes output (0-59)
        logic [5:0] stopwatch_sec_out;  // stopwatch seconds output (0-59)

        

        

        function new(string name = "dw_seq_item");
            super.new(name);
            prev_mode = 0; // initialize
        endfunction

        function string convert2string();
            return $sformatf(
                "%s | rst=%0b mode=%0b set=%0b | TIME=%0d%0d:%0d%0d | ALARM=%0b | SW=%0d:%0d",
                super.convert2string(),
                rst,
                mode,
                set,
                tens_hours_out,
                units_hours_out,
                tens_minutes_out,
                units_minutes_out,
                alarm_sound,
                stopwatch_min_out,
                stopwatch_sec_out
            );
        endfunction



        function string convert2string_stimulus();
            return $sformatf(
                "%s | rst=%0b mode=%0b set=%0b",
                super.convert2string(),
                rst,
                mode,
                set
            );
        endfunction



        // constraints
        constraint reset_con {
            rst dist {0:/1, 1:/99};
        }

        constraint mode_con {
            /*if (consecutive) { // no_consecutive_mode_high
                mode == 0;
                //prev_mode == 0;
                flag == 1;
            }
            else */if (!stopwatch_task)
                mode dist {1:/11, 0:/89};
            else
                mode dist {1:/1, 0:/150};  // make mode signal happen less in stopwatch
        }

        constraint set_con {
            if (!stopwatch_task)
                set dist {1:/75, 0:/25};
            else {
                set dist {1:/15, 0:/150}; // make the set happen less when in stopwatch
                !(set && consecutive); // no set after mode
                !(set && consecutive_set); // no double set in stopwatch
            }
        }

        // mode and set must not be high together
        constraint no_mode_and_set_together {
            !(mode && set);
        }

        // mode must not be high in two consecutive items
        constraint no_consecutive_mode_high {
            /*if (prev_mode)
                mode == 0;*/
            !(mode && consecutive);
        }

    endclass
endpackage