package dw_driver_pkg;
    import dw_config_obj_pkg::*;
    import dw_seq_item_pkg::*;
    import dw_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"    
    class dw_driver extends uvm_driver #(dw_seq_item);
        `uvm_component_utils(dw_driver)

        virtual dw_if dw_vif; // virtual interface
        dw_seq_item stim_seq_item; // sequence item

        function new(string name = "dw_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                stim_seq_item = dw_seq_item::type_id::create("stim_seq_item");
                seq_item_port.get_next_item(stim_seq_item);
                dw_vif.rst = stim_seq_item.rst;
                dw_vif.mode = stim_seq_item.mode;
                dw_vif.set = stim_seq_item.set;
                prev_mode = stim_seq_item.mode; // update prev_mode
                prev_set = stim_seq_item.set; // update prev_set
                @(negedge dw_vif.clk);
                // for mode and set constraints, see shared package for more detailes
                if (prev_mode)
                    consecutive = 1;
                else
                    consecutive = 0;
                if (prev_set)
                    consecutive_set = 1;
                else 
                    consecutive_set = 0;
                seq_item_port.item_done();
                `uvm_info("run_phase", stim_seq_item.convert2string_stimulus(), UVM_HIGH)
            end
        endtask
    endclass
endpackage
            
