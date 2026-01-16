// this shared package is to make the set signal happen much less while in stopwatch
package dw_shared_pkg;
    bit stopwatch_task;
    bit directed_begin = 0;
    bit reset_sequence; // flag to indicate if we used reset seq or not
    bit keep_low = 1; // flag to toggle the mode signal
    bit prev_mode; // to avoid consecutive mode high
    bit prev_set; // to avoid consecutive sets in stopwatch
    bit flag; // for making sure
    bit consecutive; // to make mode signal goes low after high
    bit consecutive_set; // to make set signal not to be high in consecutive cycles in stopwatch mode
    bit next_is_stopwatch; // flag to indicate that the next state is stopwatch so we will lower the prop. of set signal
endpackage