package dw_config_obj_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class dw_config_obj extends uvm_object;
        `uvm_object_utils(dw_config_obj)

        // virtual interface (main)
        virtual dw_if dw_vif;

        // virtual interface (internal)
        virtual dw_internal_if dw_internal_vif;

        // constructor
        function new(string name = "dw_config_obj");
            super.new(name);
        endfunction
    endclass
endpackage
