//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone4 - class based verification	//
//	Prepared by Janvier Mpfizi Rutihunza	//
//////////////////////////////////////////////////

// my_sequencer: arbitrates sequences and provides items to the driver.
// The driver connects to this sequencer via: driver.seq_item_port.connect(sequencer.seq_item_export);

class my_sequencer extends uvm_sequencer #(my_sequence_item);

  // Factory registration (so you can do type_id::create and overrides)
  `uvm_component_utils(my_sequencer)

  // Constructor: every UVM component takes a name and a parent
  function new(string name = "my_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // build_phase: create subcomponents / read config / setup defaults
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
`uvm_info(get_type_name(), "build_phase my_sequencer", UVM_HIGH);
  endfunction

  // connect_phase: connect TLM ports/exports between components
function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info(get_type_name(), "this is connect my_sequencer", UVM_HIGH);
endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

endclass