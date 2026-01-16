package dw_test_pkg;
    import dw_config_obj_pkg::*;
    import dw_env_pkg::*;
    import dw_reset_sequence_pkg::*;
    import dw_main_sequence_pkg::*;
    
    // Importing all 5 directed sequence packages
    import dw_directed_1st_sequence_pkg::*;
    import dw_directed_2nd_sequence_pkg::*;
    import dw_directed_3rd_sequence_pkg::*;
    import dw_directed_4th_sequence_pkg::*;
    import dw_directed_5th_sequence_pkg::*;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class dw_test extends uvm_test;
        `uvm_component_utils(dw_test)

        dw_env env; 
        dw_config_obj dw_cfg;    
        
        // Sequence Handles
        dw_reset_sequence        reset_seq;
        dw_main_sequence         main_seq;
        dw_directed_1st_sequence directed_1st_seq;
        dw_directed_2nd_sequence directed_2nd_seq;
        dw_directed_3rd_sequence directed_3rd_seq;
        dw_directed_4th_sequence directed_4th_seq;
        dw_directed_5th_sequence directed_5th_seq;

        function new(string name = "dw_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env    = dw_env::type_id::create("env", this);
            dw_cfg = dw_config_obj::type_id::create("dw_cfg");

            // Sequence Creation
            reset_seq        = dw_reset_sequence::type_id::create("reset_seq");
            main_seq         = dw_main_sequence::type_id::create("main_seq");
            directed_1st_seq = dw_directed_1st_sequence::type_id::create("directed_1st_seq");
            directed_2nd_seq = dw_directed_2nd_sequence::type_id::create("directed_2nd_seq");
            directed_3rd_seq = dw_directed_3rd_sequence::type_id::create("directed_3rd_seq");
            directed_4th_seq = dw_directed_4th_sequence::type_id::create("directed_4th_seq");
            directed_5th_seq = dw_directed_5th_sequence::type_id::create("directed_5th_seq");

            // Config DB gets
            if (!uvm_config_db #(virtual dw_if)::get(this,"","dw_V", dw_cfg.dw_vif))
                `uvm_fatal("build_phase", "Main interface not found");

            if (!uvm_config_db #(virtual dw_internal_if)::get(this,"","dw_IV", dw_cfg.dw_internal_vif))
                `uvm_fatal("build_phase", "Internal interface not found");

            uvm_config_db #(dw_config_obj)::set(this,"*","CFG", dw_cfg);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);

            // 1. Initial Reset to start the simulation
            `uvm_info("run_phase", "Initial reset asserted", UVM_LOW)
            reset_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Initial reset deasserted", UVM_LOW)

            // 2. Main Random/Standard Sequence
            `uvm_info("run_phase", "Starting Main Sequence", UVM_LOW)
            main_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Main Sequence finished", UVM_LOW)

            // 3. SECOND RESET: Prepare for Directed Testing
            // This ensures the FSM starts from IDLE for your directed scenarios
            `uvm_info("run_phase", "Intermediate reset for Directed Tests", UVM_LOW)
            reset_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Intermediate reset deasserted", UVM_LOW)

            // 4. Executing Directed Sequences in Order
            `uvm_info("run_phase", "Executing Directed Test Battery", UVM_LOW)

            `uvm_info("run_phase", "Starting Directed Seq 1", UVM_LOW)
            directed_1st_seq.start(env.agt.sqr);

            `uvm_info("run_phase", "Starting Directed Seq 2", UVM_LOW)
            directed_2nd_seq.start(env.agt.sqr);

            `uvm_info("run_phase", "Starting Directed Seq 3", UVM_LOW)
            directed_3rd_seq.start(env.agt.sqr);

            `uvm_info("run_phase", "Starting Directed Seq 4", UVM_LOW)
            directed_4th_seq.start(env.agt.sqr);

            `uvm_info("run_phase", "Starting Directed Seq 5", UVM_LOW)
            directed_5th_seq.start(env.agt.sqr);

            `uvm_info("run_phase", "Starting Directed Seq 1", UVM_LOW)
            directed_1st_seq.start(env.agt.sqr);

            phase.drop_objection(this);
        endtask
    endclass
endpackage