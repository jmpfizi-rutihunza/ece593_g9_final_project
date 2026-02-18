//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

class transaction;
 
	rand bit [1:0] core_id;   // Id for the 4 cores (0, 1, 2, 3)
  	rand bit [3:0] opcode;    // The 4-bit instruction code 
  	rand bit [10:0] addr;     // 11-bit address for 2KB memory 

	bit we;       // Write enable
	bit req;      // Request signal
	bit gnt;      // Grant  
	bit rvalid;   // Read data valid


  	//operands
  	rand bit [7:0] A;         // Operand A (1 byte) 
  	rand bit [7:0] B;         // Operand B (1 byte) 
  	bit [7:0] data;           // Actual data collected from the bus
  
  
  	bit [7:0] expected_val;   // Used by the scoreboard to store the predicted result

  	// Constraints for Randomization
  	constraint mem { addr < 2048; }
  
  	// valid opcodes 
  	constraint valid_op { opcode inside {[4'b0000 : 4'b1101]}; }

  	// Utility function to display transaction details in the transcript [cite: 74]
  	function void display();
    		$display(" Time: %0t | Core: %0d | Op: %b | Addr: %h | A: %h | B: %h | Data: %h", $time, core_id, opcode, addr, A, B, data);
  	endfunction

	// Deep copy function
  	function transaction copy();
    		copy = new();
    		copy.core_id = this.core_id;
    		copy.opcode  = this.opcode;
    		copy.addr    = this.addr;
		copy.we      = this.we;      
    		copy.req     = this.req;    
    		copy.gnt     = this.gnt;     
    		copy.rvalid  = this.rvalid;  
    		copy.A       = this.A;
    		copy.B       = this.B;
    		copy.data    = this.data;
		copy.expected_val = this.expected_val;
    		return copy;
  	endfunction
endclass