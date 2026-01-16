package dw_main_sequence_pkg;
    import dw_seq_item_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class dw_main_sequence extends uvm_sequence #(dw_seq_item);
        `uvm_object_utils(dw_main_sequence);
        dw_seq_item seq_item;

        function new(string name = "dw_main_sequence");
            super.new(name);
        endfunction

        task body;
            repeat(20000)begin
                seq_item = dw_seq_item::type_id::create("seq_item");
                start_item(seq_item);
                assert(seq_item.randomize());
                finish_item(seq_item);
            end
        endtask
    endclass
endpackage