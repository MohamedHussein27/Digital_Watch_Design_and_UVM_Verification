package dw_directed_2nd_sequence_pkg;
    import dw_seq_item_pkg::*;
    import dw_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // this class is to verify the setiing time function
    class dw_directed_2nd_sequence extends uvm_sequence #(dw_seq_item);
        `uvm_object_utils(dw_directed_2nd_sequence);
        dw_seq_item seq_item;
        
        // intergers to set the watch 
        int i = 2; // to set tens hours (2)
        int ii = 0; // counter for tens hours
        int j = 3; // to set units hours (3)
        int jj = 0; // counter for units hours 
        int k = 5; // to set tens minutes
        int kk = 0; // to set the tens minutes
        int q = 9; // to set units minutes
        int qq = 0; // counter for tens minutes

        // constructor 
        function new(string name = "dw_directed_2nd_sequence");
            super.new(name);
        endfunction

        task body;
            repeat(200)begin
                seq_item = dw_seq_item::type_id::create("seq_item");
                start_item(seq_item);
                seq_item.rst = 1;
                seq_item.mode = 0;
                seq_item.set = 0;
                if (ii < i + 1)begin
                    if(ii == 0) seq_item.mode = 1; // make it high once
                    else seq_item.set = !seq_item.set; // as not to be high in two consecutive cycles
                    ii++;
                end
                else if (jj < j + 1) begin
                    if(jj == 0) seq_item.mode = 1; // make it high once
                    else seq_item.set = 1; // as not to be high in two consecutive cycles
                    jj++;
                end
                else if (kk < k + 1) begin
                    if(kk == 0) seq_item.mode = 1; // make it high once
                    else seq_item.set = 1; // as not to be high in two consecutive cycles
                    kk++;
                end
                else if (qq < q + 1) begin
                    if(qq == 0) seq_item.mode = 1; // make it high once
                    else seq_item.set = !seq_item.set; // as not to be high in two consecutive cycles
                    qq++;
                end
                finish_item(seq_item);
            end
        endtask
    endclass
endpackage
