package dw_directed_4th_sequence_pkg;
    import dw_seq_item_pkg::*;
    import dw_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // this class is to verify the elapsed stopwatch function
    class dw_directed_4th_sequence extends uvm_sequence #(dw_seq_item);
        `uvm_object_utils(dw_directed_4th_sequence);
        dw_seq_item seq_item;
        
        // intergers to set the watch 
        int i = 2; // start
        int j = 8; // stop
        int k = 12; // resume
        int q = 4000; // stop again (4000 to reach the max min)
        int v = 4020; // clear
        int z = 0; // iterating counter

        // constructor 
        function new(string name = "dw_directed_4th_sequence");
            super.new(name);
        endfunction

        task body;
            repeat(4050)begin
                seq_item = dw_seq_item::type_id::create("seq_item");
                start_item(seq_item);
                seq_item.rst = 1;
                seq_item.mode = 0;
                seq_item.set = 0;
                if (z == 0) seq_item.mode = 1; // begin elapsed mode
                else if (z == i) seq_item.set = 1; // start
                else if (z == j) seq_item.set = 1; // stop
                else if (z == k) seq_item.set = 1; // resume
                else if (z == q) seq_item.set = 1; // stop again
                else if (z == v) seq_item.set = 1; // clear
                z++;
                finish_item(seq_item);
            end
        endtask
    endclass
endpackage
