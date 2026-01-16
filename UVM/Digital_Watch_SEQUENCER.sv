package dw_sequencer_pkg;
    import dw_seq_item_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class dw_sequencer extends uvm_sequencer #(dw_seq_item);
        `uvm_component_utils(dw_sequencer)

        function new (string name = "dw_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass
endpackage