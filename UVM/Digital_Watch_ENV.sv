package dw_env_pkg;
    import dw_config_obj_pkg::*;
    import dw_seq_item_pkg::*;
    import dw_sequencer_pkg::*;
    import dw_agent_pkg::*;
    import dw_coverage_collector_pkg::*;
    import dw_scoreboard_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class dw_env extends uvm_env;
        `uvm_component_utils (dw_env)

        // agent, scoreboard and coverage collector
        dw_agent agt;
        dw_scoreboard sb;
        dw_coverage_collector cov;

        // configuration object 
        dw_config_obj dw_cfg; // configuration object     
    
        // construction
        function new (string name = "dw_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction


        // new modification: i am using this build phase to get the configuration object for the internal interface
        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            agt = dw_agent::type_id::create("agt",this);            
            sb = dw_scoreboard::type_id::create("sb", this);
            cov = dw_coverage_collector::type_id::create("cov", this);

            // here we get the cofiguration object
            if(!uvm_config_db #(dw_config_obj)::get(this,"","CFG", dw_cfg)) begin
                    `uvm_fatal("build_phase","agent error");
            end
        endfunction

        // connection between agent and scoreboard and between agent and coverage collector
        function void connect_phase (uvm_phase phase);
            agt.agt_ap.connect(sb.sb_export);
            agt.agt_ap.connect(cov.cov_export);

            // new modification to connect the virtual interface to the coverage virtual interface to cover the internal signals
            cov.dw_internal_vif = dw_cfg.dw_internal_vif;
        endfunction
    endclass
endpackage