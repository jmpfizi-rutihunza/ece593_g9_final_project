//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 4 - UVM		// 
/////////////////////////////////

class mp_monitor extends uvm_monitor;

	//UVM factory registration
	`uvm_component_utils(mp_monitor)

	//Virtual Interface
	virtual mp_intf vif;
    	int core_id;

	//Analysis Port
	uvm_analysis_port #(mp_transaction) monitor_A_port;

	//constructor
	function new(string name = "mp_monitor", uvm_component parent = null);
        	super.new(name, parent);
        	monitor_A_port = new("monitor_A_port", this);
    	endfunction


	//Build Phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		//Get virtual interface pointer from the config db
        	if (!uvm_config_db#(virtual mp_intf)::get(this, "", "vif", vif))
            		`uvm_fatal("MON", "Virtual interface not found")

        	// Get core_id from config_db 
        	if (!uvm_config_db#(int)::get(this, "", "core_id", core_id))
            		`uvm_fatal("MON", "Core ID not found")
    	endfunction

	//Run Phase
	task run_phase(uvm_phase phase);
		super.run_phase (phase);

		forever begin
			mp_transaction observed_tx;

			// Wait for a Grant signal on the bus
			@(posedge vif.clk iff (vif.gnt[core_id] === 1'b1));
            		if (vif.gnt[core_id] === 1'b1) begin
				//create object for transaction
				observed_tx = mp_transaction::type_id::create("observed_tx");


				// Sample input data
                		observed_tx.core_id = core_id;
                		observed_tx.opcode  = vif.opcode[core_id];
                		observed_tx.addr    = vif.addr[core_id];
                		observed_tx.we      = vif.we[core_id];
                		observed_tx.A       = vif.A[core_id];
                		observed_tx.B       = vif.B[core_id];

				
                    		//wait(vif.rvalid[core_id] === 1'b1);
				@(posedge vif.clk iff (vif.rvalid[core_id] === 1'b1));
					
				observed_tx.data = vif.data[core_id];
					
                		

				`uvm_info("MON", $sformatf("Observed Core %0d: %s", core_id, observed_tx.convert2string()), UVM_HIGH)

				// Send to Scoreboard via analysis port
                		monitor_A_port.write(observed_tx);
				@(posedge vif.clk);
			end
		end
	endtask

endclass
			