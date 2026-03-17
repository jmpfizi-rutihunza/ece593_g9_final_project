//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 4 - UVM		// 
/////////////////////////////////


class mp_test extends uvm_test;

	//UVM factory registration
	`uvm_component_utils(mp_test)

	int logfile;

	//handle
	mp_env env;

	//constructor
	function new(string name = "mp_test", uvm_component parent = null);
       		super.new(name, parent);
    	endfunction

	// Build Phase
    	virtual function void build_phase(uvm_phase phase);

        	super.build_phase(phase);
        	env = mp_env::type_id::create("env", this);

		//create log file
      		logfile = $fopen("uvm_log.txt", "w");

     		uvm_root::get().set_report_default_file_hier(logfile);
        	uvm_root::get().set_report_severity_action_hier(UVM_INFO,    UVM_DISPLAY | UVM_LOG);
        	uvm_root::get().set_report_severity_action_hier(UVM_WARNING, UVM_DISPLAY | UVM_LOG);
        	uvm_root::get().set_report_severity_action_hier(UVM_ERROR,   UVM_DISPLAY | UVM_LOG);
        	uvm_root::get().set_report_severity_action_hier(UVM_FATAL,   UVM_DISPLAY | UVM_LOG | UVM_EXIT);
		//uvm_top.set_report_verbosity_level_hier(UVM_HIGH);
    	endfunction


	//ASCII Report - Connectivity Map
	function void start_of_simulation_phase(uvm_phase phase);
    		super.start_of_simulation_phase(phase);
    		
		$display("\n--- UVM TESTBENCH TOPOLOGY ---");
    		uvm_top.print_topology(); 
    
    		$display("\n--- UVM CONFIGURATION DATABASE ---");
    		this.print_config(1); 
    		$display("----------------------------------\n");
	endfunction


	//Topology
	virtual function void end_of_elaboration_phase(uvm_phase phase);
    		super.end_of_elaboration_phase(phase);

		// 'tree' format ASCII printer
   	 	uvm_default_tree_printer.knobs.separator = "|";
   		`uvm_info("TOPOLOGY", "Displaying ASCII Testbench Topology", UVM_LOW)
    		this.print(uvm_default_tree_printer); 
	endfunction

	// Run Phase
	task run_phase(uvm_phase phase);
        	
		mp_vseq vseq;
    		vseq = mp_vseq::type_id::create("vseq");

        	phase.raise_objection(this); // Tell UVM simulation has started
		`uvm_info("TEST", "Starting Virtual Sequence for Parallel Stress Test", UVM_LOW)

		// Connect the virtual sequence handles to the actual agent sequencers

		if (!$cast(vseq.seqr_0, env.core_agnt[0].seqr)) `uvm_fatal("TEST", "Cast failed for Core 0")
		if (!$cast(vseq.seqr_1, env.core_agnt[1].seqr)) `uvm_fatal("TEST", "Cast failed for Core 1")
		if (!$cast(vseq.seqr_2, env.core_agnt[2].seqr)) `uvm_fatal("TEST", "Cast failed for Core 2")
		if (!$cast(vseq.seqr_3, env.core_agnt[3].seqr)) `uvm_fatal("TEST", "Cast failed for Core 3")
    

		// Start virtual sequences
		vseq.start(null);
        
        	phase.drop_objection(this); // Tell UVM simulation is safe to end
    	endtask
endclass


//------------------------------------------------------------------
// Test Class for ALU testing
//------------------------------------------------------------------

class mp_alu_test extends mp_test; 
    
	`uvm_component_utils(mp_alu_test)

    	function new(string name = "mp_alu_test", uvm_component parent = null);
        	super.new(name, parent);
    	endfunction

    	task run_phase(uvm_phase phase);

		// Create a dynamic sequence
        	mp_dynamic_vseq vseq = mp_dynamic_vseq::type_id::create("vseq");
        
        	phase.raise_objection(this);
        
        	// Connect sequencer handles from the env to the virtual sequence
        	if (!$cast(vseq.seqr_0, env.core_agnt[0].seqr)) `uvm_fatal("TEST", "[ALU] Cast failed for Core 0")
		if (!$cast(vseq.seqr_1, env.core_agnt[1].seqr)) `uvm_fatal("TEST", "[ALU] Cast failed for Core 1")
		if (!$cast(vseq.seqr_2, env.core_agnt[2].seqr)) `uvm_fatal("TEST", "[ALU] Cast failed for Core 2")
		if (!$cast(vseq.seqr_3, env.core_agnt[3].seqr)) `uvm_fatal("TEST", "[ALU] Cast failed for Core 3")
            	
		vseq.start(null);
        
       	 	#100ns; // Drain time
        	phase.drop_objection(this);
    	endtask
endclass