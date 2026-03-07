//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 5 - UVM		// 
/////////////////////////////////

class mp_agent extends uvm_agent;

	//UVM factory registration
	`uvm_component_utils (mp_agent)

	//instantiate sub-components
	mp_driver drv;
	mp_monitor mon;
	mp_sequencer seqr;

	int core_id;

	//constructor
	function new (string name = "mp_agent", uvm_component parent = null);
		super.new (name, parent);
	endfunction

	//Build Phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get core_id from config_db to pass it down to sub-components
        	if (!uvm_config_db#(int)::get(this, "", "core_id", core_id)) begin
            		
			`uvm_fatal("AGENT", $sformatf("No core_id set for %s", get_full_name()))
        	end

        	// Pass the core_id down to driver and monitor before creating them
        	uvm_config_db#(int)::set(this, "drv", "core_id", core_id);
        	uvm_config_db#(int)::set(this, "mon", "core_id", core_id);

        	// Create the components
        	mon = mp_monitor::type_id::create("mon", this);
        
        	// Only create driver and sequencer if agent is ACTIVE
        	if (get_is_active() == UVM_ACTIVE) begin
            		drv = mp_driver::type_id::create("drv", this);
            		seqr = mp_sequencer::type_id::create("seqr", this);
        	end
    	endfunction


	//Connect Phase : connect driver and sequencer
     	function void connect_phase(uvm_phase phase);
        	super.connect_phase(phase);
        
        	if (get_is_active() == UVM_ACTIVE) begin
            		drv.seq_item_port.connect(seqr.seq_item_export);
        	end
    	endfunction

	//Run Phase
	task run_phase (uvm_phase phase);
		super.run_phase (phase);
	endtask

endclass