//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone4 - class based verification	//
//	Prepared by Janvier Mpfizi Rutihunza	//
//////////////////////////////////////////////////
//sequence_item / transaction
class my_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(my_sequence_item)

  // Control signals (match intf.sv)
  rand bit reset_n;
  rand bit we;
  rand bit read_en;

  // Other stimulus
  rand bit [1:0]  core_id;
  rand bit [3:0]  opcode;
  rand bit [10:0] addr;
  rand bit [7:0]  A, B;

  // Observed / scoreboard fields (not randomized)
  bit [7:0] data_out;

  // Constraints
  constraint mem       { addr < 2048; }
  constraint valid_op  { opcode inside {[4'b0000:4'b1101]}; }
  constraint rw_excl   { !(we && read_en); } // can't read+write same time

  function new(string name="my_sequence_item");
    super.new(name);
  endfunction
endclass



