package dw_directed_3rd_sequence_pkg;
    import dw_seq_item_pkg::*;
    import dw_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // this class is to verify the setiing alarm function
    class dw_directed_3rd_sequence extends uvm_sequence #(dw_seq_item);
        `uvm_object_utils(dw_directed_3rd_sequence);
        dw_seq_item seq_item;
        
        // intergers to set the watch 
        int i = 0; // to set tens hours 
        int ii = 0; // counter for tens hours
        int j = 1; // to set units hours 
        int jj = 0; // counter for units hours 
        int k = 1; // to set tens minutes
        int kk = 0; // to set the tens minutes
        int q = 2; // to set units minutes
        int qq = 0; // counter for tens minutes

        // we are setting the alarm on 01:12

        // flags to indicate which digit we are setting
        bit j_flag = 0;
        bit k_flag = 0;
        bit q_flag = 0;

        // constructor 
        function new(string name = "dw_directed_3rd_sequence");
            super.new(name);
        endfunction

        task body;
            repeat(200)begin
                seq_item = dw_seq_item::type_id::create("seq_item");
                start_item(seq_item);
                seq_item.rst = 1;
                seq_item.mode = 0;
                seq_item.set = 0;
                j_flag = 0;
                k_flag = 0;
                q_flag = 0;
                if (ii < i + 1)begin
                    if(ii == 0) seq_item.mode = 1; // make it high once
                    else seq_item.set = 1; // as not to be high in two consecutive cycles
                    ii++;
                end
                else if (jj < j + 1) begin
                    if (keep_low) begin 
                        seq_item.mode = 0;
                        keep_low = 0;
                        jj--;
                    end
                    else if(jj == 0)begin 
                        seq_item.mode = 1; // make it high once
                    end
                    else seq_item.set = 1; // as not to be high in two consecutive cycles
                    jj++;
                    j_flag = 1;
                end
                else if (kk < k + 1) begin
                    if (keep_low) begin 
                        seq_item.mode = 0;
                        keep_low = 0;
                        kk--;
                    end
                    else if(kk == 0)begin 
                        seq_item.mode = 1; // make it high once
                    end
                    else seq_item.set = 1; // as not to be high in two consecutive cycles
                    kk++;
                    k_flag = 1;
                end
                else if (qq < q + 1) begin
                    if (keep_low) begin 
                        seq_item.mode = 0;
                        keep_low = 0;
                        qq--;
                    end
                    else if(qq == 0)begin 
                        seq_item.mode = 1; // make it high once
                    end
                    else seq_item.set = !seq_item.set; // as not to be high in two consecutive cycles
                    qq++;
                    q_flag = 1;
                end
                if ((qq == q + 1) && q_flag) keep_low = 1; // reset the flag after finishing units hours
                else if ((kk == k + 1) && k_flag) keep_low = 1; // reset the flag after finishing tens minutes
                else if ((jj == j + 1) && j_flag) keep_low = 1; // reset the flag after finishing units minutes
                finish_item(seq_item);
            end
        endtask
    endclass
endpackage
