package dw_directed_1st_sequence_pkg;
    import dw_seq_item_pkg::*;
    import dw_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // this class is to verify the normal clock function
    class dw_directed_1st_sequence extends uvm_sequence #(dw_seq_item);
        `uvm_object_utils(dw_directed_1st_sequence);
        dw_seq_item seq_item;
        
        // constructor 
        function new(string name = "dw_directed_1st_sequence");
            super.new(name);
        endfunction

        task body;
            repeat(350)begin
                directed_begin = 1;
                seq_item = dw_seq_item::type_id::create("seq_item");
                start_item(seq_item);
                seq_item.rst = 1;
                seq_item.mode = 0;
                seq_item.set = 0;
                finish_item(seq_item);
            end
        endtask
    endclass
endpackage
