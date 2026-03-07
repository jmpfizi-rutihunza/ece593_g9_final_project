//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 5 - UVM		// 
/////////////////////////////////

class mp_env extends uvm_env;

	// UVM factory registration
	`uvm_component_utils(mp_env)

	// Instantiate 4 agents for 4 cores
	mp_agent core_agnt[4];

	// Instantiate the scoreboard
	mp_scoreboard scb;
	
	//instantiate functional coverage
	mp_coverage cov;

	// Constructor
	function new(string name = "mp_env", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	// Build Phase
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Create the coverage
		cov = mp_coverage::type_id::create("cov", this);

		// Create the scoreboard
		scb = mp_scoreboard::type_id::create("scb", this);

		// Create the 4 agents 
		for (int i = 0; i < 4; i++) begin
			string agent_name = $sformatf("core_agnt_%0d", i);
			
			// Set the core_id for each agent so they know which part of the bus to drive
			uvm_config_db#(int)::set(this, agent_name, "core_id", i);
			
			core_agnt[i] = mp_agent::type_id::create(agent_name, this);
		end
		`uvm_info("ENV", "All 4 Core Agents successfully instantiated and configured.", UVM_LOW)
	endfunction

	// Connect Phase: connecting monitors to the scoreboard
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		for (int i = 0; i < 4; i++) begin
			// Connect each monitor's analysis port to the scoreboard's FIFO
			core_agnt[i].mon.monitor_A_port.connect(scb.item_collected_fifo.analysis_export);

			core_agnt[i].mon.monitor_A_port.connect(cov.analysis_export);
		end
	endfunction

endclass