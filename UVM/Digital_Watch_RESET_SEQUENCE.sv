package dw_reset_sequence_pkg;
    import dw_seq_item_pkg::*;
    import dw_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class dw_reset_sequence extends uvm_sequence #(dw_seq_item);
        `uvm_object_utils(dw_reset_sequence);
        dw_seq_item seq_item;
        
        // constructor 
        function new(string name = "dw_reset_sequence");
            super.new(name);
        endfunction

        task body;
            seq_item = dw_seq_item::type_id::create("seq_item");
            start_item(seq_item);
            seq_item.rst = 0;
            seq_item.mode = 0;
            seq_item.set = 0;
            finish_item(seq_item);
        endtask
    endclass
endpackage
