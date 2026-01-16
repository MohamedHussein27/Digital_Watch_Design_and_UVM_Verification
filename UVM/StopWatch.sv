// this module is to make a stopwatch which has elapsed time and split time functions
module StopWatch (
    input clk,
    input rst,
    input mode, // to transition between elapsed time and split time
    input set, // to start and stop the stopwatch

    // input from Digital_Watch FSM
    input stopwatch_mode_en, // to indicate if it's in stopwatch mode
    
    
    // outputs for display (mm:ss) 
    output reg [5:0] min_out, // minutes output (0-59)
    output reg [5:0] sec_out,  // seconds output (0-59)
    output reg split_mode // to indicate if it's in split time mode as if mode=1 we will go back to normal time
);
    // Stopwatch internal signals
    reg stopwatch_mode; // if it's Elapsed time (default) or Split Time
    reg split_captured; // to indicate if split time is captured
    reg split_pulse; // to maintain a pulse for split time capture (for timing purposes)
    reg split_pulse_captured; // to indicate if split pulse is captured
    reg reset_states; // flag to reset the states if the enable if off

    // internal seconds and minutes
    reg [5:0] sec_count;
    reg [5:0] min_count;
    reg [5:0] sec_count_split;
    reg [5:0] min_count_split;

    // counters for different states in each mode
    reg [2:0] Elapsed_state; // states for elapsed time mode
    reg [2:0] Split_state;   // states for split time mode

    // Stopwatch seconds counter
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            sec_count <= 6'd0;
            min_count <= 6'd0;
            stopwatch_mode <= 1'b0; // default to elapsed time
            split_captured <= 1'b0;
            sec_count_split <= 6'd0;
            min_count_split <= 6'd0;
            split_mode <= 1'b0;
            split_pulse <= 1'b0;
            reset_states <= 1'b0;
        end 
        else if (stopwatch_mode_en) begin
            reset_states <= 1'b0;
            if (mode) begin
                stopwatch_mode <= ~stopwatch_mode; // toggle between elapsed and split time
            end
            // In elapsed time mode, do not increment the stopwatch when stop, incerement it otherwise
            else if (!stopwatch_mode) begin
                split_mode <= 1'b0; // indicate we are not in split mode
                if (Elapsed_state == 3'b001 || Elapsed_state == 3'b011) begin // running states    
                    if (sec_count == 6'd59) begin
                        sec_count <= 6'd0;
                        if (min_count == 6'd59) begin
                            min_count <= 6'd0;
                        end else begin
                            min_count <= min_count + 6'd1;
                        end
                    end else begin
                        sec_count <= sec_count + 6'd1;
                    end
                end else if (Elapsed_state == 3'b000) begin
                    // In cleared state, reset the stopwatch
                    sec_count <= 6'd0;
                    min_count <= 6'd0;
                end
            end
            // In split time mode, increment the stopwatch even when splitting
            else begin
                split_mode <= 1'b1; // indicate we are in split mode
                if (split_pulse) begin
                    split_pulse <= 1'b0; // reset the split pulse after one cycle
                end
                if (Split_state == 3'b010 && !split_captured) begin // in split state, we should keep the time we are at without stopping incrementing
                    sec_count_split <= sec_count;
                    min_count_split <= min_count;
                    split_captured <= 1'b1;
                    split_pulse <= 1'b1;
                end
                if (Split_state == 3'b001 || Split_state == 3'b010 || Split_state == 3'b011) begin // running states (start and split released)   
                    if (sec_count == 6'd59) begin
                        sec_count <= 6'd0;
                        if (min_count == 6'd59) begin
                            min_count <= 6'd0;
                        end else begin
                            min_count <= min_count + 6'd1;
                        end
                    end else begin
                        sec_count <= sec_count + 6'd1;
                    end
                end else if (Split_state == 3'b000) begin
                    // In cleared state, reset the stopwatch
                    sec_count <= 6'd0;
                    min_count <= 6'd0;
                    split_captured <= 1'b0;
                end 
            end
        end
        else begin
            sec_count <= 6'd0;
            min_count <= 6'd0;
            reset_states <= 1'b1;
            //stopwatch_mode <= 1'b0; // default to elapsed time
            //split_captured <= 1'b0;
            sec_count_split <= 6'd0;
            min_count_split <= 6'd0;
            //split_mode <= 1'b0;
            //split_pulse <= 1'b0;
        end
    end

    // which state we are in
    always @(*) begin
        if (!rst) begin
            Elapsed_state = 3'b000;
            Split_state = 3'b000;
        end 
        else if (stopwatch_mode_en) begin
            if (!stopwatch_mode) begin
                // Elapsed time mode state transitions
                case (Elapsed_state)
                    3'b000: if (set) Elapsed_state = 3'b001; // start
                    3'b001: if (set) Elapsed_state = 3'b010; // stop
                    3'b010: if (set) Elapsed_state = 3'b011; // resume
                    3'b011: if (set) Elapsed_state = 3'b100; // stop again
                    3'b100: if (set) Elapsed_state = 3'b000; // clear
                    default: Elapsed_state = 3'b000;
                endcase
            end else begin
                // Split time mode state transitions
                case (Split_state)
                    3'b000: if (set) Split_state = 3'b001; // start 
                    3'b001: if (set) Split_state = 3'b010; // split
                    3'b010: if (set) Split_state = 3'b011; // split release
                    3'b011: if (set) Split_state = 3'b100; // stop
                    3'b100: if (set) Split_state = 3'b000; // clear
                    default: Split_state = 3'b000;
                endcase
            end
        end
        else if (reset_states) begin
            Elapsed_state = 3'b000;
            Split_state = 3'b000;
        end
    end

    // output assignments
    always @(*) begin
        if (split_pulse) begin // the whole split pulse and split pulse captured thing is for timing purposes
            min_out = min_count_split;
            sec_out = sec_count_split;
            split_pulse_captured = 1;
        end
        else if (split_pulse_captured && Split_state == 3'b010) begin
            min_out = min_count_split;
            sec_out = sec_count_split;
            split_pulse_captured = 1;
        end
        else begin
            min_out = min_count;
            sec_out = sec_count;
            split_pulse_captured = 0;
        end
    end

    //assign min_out = (Split_state == 3'b010) ? min_count_split : min_count;
    //assign sec_out = (Split_state == 3'b010) ? sec_count_split : sec_count;
endmodule