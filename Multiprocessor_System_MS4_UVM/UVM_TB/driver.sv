//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 4 - UVM		// 
/////////////////////////////////

class mp_driver extends uvm_driver #(mp_transaction);

	//UVM factory registration 
	`uvm_component_utils(mp_driver)

	//virtual interface
	virtual mp_intf vif;

	int core_id;
	int tx_driven = 0;

	//constructor
	function new(string name = "mp_driver", uvm_component parent = null);
    		super.new(name, parent);
  	endfunction


	//Build Phase
	 function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
    
    		if (!uvm_config_db#(virtual mp_intf)::get(this, "", "vif", vif)) begin
      			`uvm_fatal("NO_VIF", {"Virtual interface not found for ", get_full_name()})
    		end
    
    		if (!uvm_config_db#(int)::get(this, "", "core_id", core_id)) begin
      			`uvm_fatal("NO_CORE_ID", {"Core ID not found for ", get_full_name()})
    		end
    
    	`uvm_info("DRIVER", $sformatf("Driver built for Core %0d", core_id), UVM_MEDIUM)
  	endfunction


	//Run Phase 
	task run_phase(uvm_phase phase);
    		mp_transaction tx;
    
    		`uvm_info("DRIVER", $sformatf("Driver started for Core %0d", core_id), UVM_MEDIUM)
    
    		// Initialize signals
    		reset_signals();
    
    		// Wait for reset
    		wait(vif.rst_n);
    		@(posedge vif.clk);
    
    		forever begin
      			// Get transaction from sequencer
      			seq_item_port.get_next_item(tx);
      
      			// Drive transaction
     			drive_tx(tx);
      			tx_driven++;
      
      			// Done with transaction
      			seq_item_port.item_done();
      
      			if (tx_driven % 20 == 0) begin
        			`uvm_info("DRIVER", $sformatf("Core %0d: Driven %0d transactions", core_id, tx_driven), UVM_MEDIUM)
      			end
    		end
  	endtask

	//Reset Signals
	 task reset_signals();
    		vif.req[core_id]   <= 0;
    		vif.we[core_id]    <= 0;
    		vif.addr[core_id]  <= 0;
    		vif.wdata[core_id] <= 0;
  	endtask

	// Drive transaction
	task drive_tx(mp_transaction tx);
    		int grant_wait = 0;       //how many cycles until grant
    		time start_time = $time;
    
    		`uvm_info("DRIVER", $sformatf("Core %0d: Driving %s", core_id, tx.convert2string()), UVM_HIGH)
    
    		// Assert request
    		@(posedge vif.clk);			
    		vif.req[core_id]   <= 1'b1;		//Assert request signal for this core
    		vif.we[core_id]    <= tx.we;
		vif.opcode[core_id] <= tx.opcode;
   		vif.addr[core_id]  <= tx.addr;		//Address we want to access
    		vif.A[core_id] <= tx.A;	
		vif.B[core_id] <= tx.B;

		if (tx.opcode == 4'b0110) begin  	// STORE operation
 			 vif.wdata[core_id] <= tx.A;    // Drive write data
		end
    
    		// Wait for grant
    		while (!vif.gnt[core_id]) begin		//Keep looping until arbiter grants us access
      			@(posedge vif.clk);
     	 		grant_wait++;			//Count the grant wait time
      
      			if (grant_wait > 1000) begin
				//If we've waited 1000 cycles and still no grant
        			`uvm_error("DRIVER_TIMEOUT", $sformatf("Core %0d: Grant timeout after %0d cycles", core_id, grant_wait))
        		break;
      			end
    		end
    
    		repeat(1) @(posedge vif.clk);	
    		tx.gnt = 1'b1;				// got grant
    
    		`uvm_info("DRIVER", $sformatf("Core %0d: Grant received after %0d cycles", core_id, grant_wait), UVM_HIGH)
    
    		//Wait one more cycle while DUT processes the transaction
    		@(posedge vif.clk);
    
    		// Deassert request
    		vif.req[core_id]   <= 1'b0;
    		vif.we[core_id]    <= 1'b0;
		vif.A[core_id] <= 0;
    		vif.B[core_id] <= 0;
    
    		// Small delay before next transaction
    		repeat(2) @(posedge vif.clk);
    
  	endtask


	//report phase
	function void report_phase(uvm_phase phase);
    		`uvm_info("DRIVER_REPORT", $sformatf("Core %0d: Total transactions driven = %0d", core_id, tx_driven), UVM_LOW)
  	endfunction

endclass