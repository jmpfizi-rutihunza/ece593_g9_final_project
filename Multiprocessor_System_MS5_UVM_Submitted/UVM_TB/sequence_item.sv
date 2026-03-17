//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 4 - UVM		// 
/////////////////////////////////

class mp_transaction extends uvm_sequence_item;

	//control field
	rand bit [1:0]  core_id;   // core 0, core 1, core 2, core 3
  	rand bit [3:0]  opcode;    // Operation code
  	rand bit [10:0] addr;      // Memory address (0-2047)
  	rand bit        we; 	   //write enable

	//data field
	rand bit [7:0] A;          // Operand A
 	rand bit [7:0] B;          // Operand B
  	bit [7:0] data;            // Actual data from bus

	//protocol field
	bit req;                   // Request signal
  	bit gnt;                   // Grant received
  	bit rvalid;                // Read valid

  	bit [7:0] expected_val;    // // Used by the scoreboard to store the predicted result


	//UVM field automation macro
	`uvm_object_utils_begin(mp_transaction)
    		`uvm_field_int(core_id, UVM_ALL_ON)
    		`uvm_field_int(opcode, UVM_ALL_ON)
    		`uvm_field_int(addr, UVM_ALL_ON)
    		`uvm_field_int(we, UVM_ALL_ON)
    		`uvm_field_int(A, UVM_ALL_ON)
    		`uvm_field_int(B, UVM_ALL_ON)
    		`uvm_field_int(data, UVM_ALL_ON)
    		//`uvm_field_int(req, UVM_ALL_ON)
    		//`uvm_field_int(gnt, UVM_ALL_ON)
    		`uvm_field_int(rvalid, UVM_ALL_ON)
  	`uvm_object_utils_end

	//constraints

	constraint valid_addr { addr inside {[0:2047]}; }  // 11-bit address for 2KB memory so 0 to 2047

	//valid opcodes 
	constraint valid_op { opcode dist {
        			[4'b0000:4'b0100] := 40, // ALU, NOP, Logic 
        			[4'b0101:4'b0110] := 30, // Load/Store 
        			[4'b0111:4'b1010] := 15, // SHIFT and SPL
        			[4'b1011:4'b1111] := 15
    			}; }

	// constraint for operand A
	constraint c_operands { A dist { 
        			8'h00      := 35,  
        			8'hFF      := 35,  
        			[8'h01:8'hFE] := 30   
   			}; }

	//core id
	constraint core { core_id inside {[0:3]}; }

	//constructor
	function new(string name = "mp_transaction");
    		super.new(name);
  	endfunction

	function string convert2string();
  		return $sformatf("Core=%0d Op=0x%0h Addr=0x%03h A=0x%02h B=0x%02h", core_id, opcode, addr, A, B);
	endfunction

endclass 