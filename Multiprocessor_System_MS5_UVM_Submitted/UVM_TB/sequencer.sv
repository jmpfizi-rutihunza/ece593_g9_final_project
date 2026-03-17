//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 4 - UVM		// 
/////////////////////////////////


class mp_sequencer extends uvm_sequencer #(mp_transaction);

	`uvm_component_utils(mp_sequencer)

	function new(string name = "mp_sequencer", uvm_component parent = null);
    		super.new(name, parent);
  	endfunction

endclass