//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 4 - UVM		// 
/////////////////////////////////

class mp_scoreboard extends uvm_scoreboard;

	//UVM factory registration
	`uvm_component_utils(mp_scoreboard)

	// Analysis FIFO to receive transactions from any monitor
    	uvm_tlm_analysis_fifo #(mp_transaction) item_collected_fifo;

	//counters
    	int match_count = 0;
    	int error_count = 0;

	//Reference memory to track STOREs so LOADs
	bit [7:0] ref_mem [2048];

	//constructor 
	function new(string name = "mp_scoreboard", uvm_component parent = null);
        	super.new(name, parent);
        	item_collected_fifo = new("item_collected_fifo", this);
    	endfunction

	// Run Phase
   	task run_phase(uvm_phase phase);
        	mp_transaction tx;
        	forever begin
            	// Wait for a transaction to be pushed into the FIFO by a monitor
            	item_collected_fifo.get(tx);
            
            	// Reference Model
            	predict_result(tx);
            
            	// Compare the result
            	compare_result(tx);
        	end
   	endtask

	// Reference Model Logic
 	virtual function void predict_result(mp_transaction tx);
        	case(tx.opcode)
            		4'b0001: tx.expected_val = tx.A + tx.B;               // Add A and B 
            		4'b0010: tx.expected_val = tx.A & tx.B;               // And 
            		4'b0011: tx.expected_val = tx.A - tx.B;               // A - B 
            		4'b0100: tx.expected_val = tx.A * tx.B;               // A * B
            		4'b0101: tx.expected_val = ref_mem[tx.addr];          // Load from memmory 
            		4'b0111: tx.expected_val = tx.A >> 1;                 // Shift right 
            		4'b1000: tx.expected_val = tx.A << 1;                 // Shift left
			4'b0110: begin                               	      // STORE
                         		ref_mem[tx.addr] = tx.A; 
                         		tx.expected_val = tx.A;
                     		end 
            
            		// Special Functions 
            		4'b1001: tx.expected_val = (tx.A * tx.B) - tx.A;     // (A*B)-A 
            		4'b1010: tx.expected_val = (tx.A * 4 * tx.B) - tx.A; // (A*4*B)-A 
            		4'b1011: tx.expected_val = (tx.A * tx.B) + tx.A;     // (A*B)+A 
            		4'b1100: tx.expected_val = (tx.A * 3);               // (A*3) 
            		4'b1101: tx.expected_val = (tx.A * tx.B) + tx.B;     // (A*B)+B 
            
            		default: tx.expected_val = 8'h00;  
        	endcase
   	endfunction

	// Comparison Logic
    	virtual function void compare_result (mp_transaction tx);
        	// compare data for READs or ALU results appearing on the bus
        	if (tx.we == 1'b0 || tx.opcode != 4'b0000) begin 
            		if (tx.data === tx.expected_val) begin
                		`uvm_info("SCB_MATCH", $sformatf("Core %0d: Match! Op:%h, Exp:%h, Act:%h", tx.core_id, tx.opcode, tx.expected_val, tx.data), UVM_LOW)
                		match_count++;
           		end else begin
                		`uvm_error("SCB_MISMATCH", $sformatf("Core %0d: Mismatch! Op:%h, Exp:%h, Act:%h", tx.core_id, tx.opcode, tx.expected_val, tx.data))
                		error_count++;
            		end
        	end
    	endfunction

	//Final reporting
    	virtual function void report_phase(uvm_phase phase);
        	`uvm_info("SCB_FINAL", $sformatf("--- SCOREBOARD REPORT ---"), UVM_LOW)
        	`uvm_info("SCB_FINAL", $sformatf("Total Matches: %0d", match_count), UVM_LOW)
        	`uvm_info("SCB_FINAL", $sformatf("Total Errors : %0d", error_count), UVM_LOW)
        	`uvm_info("SCB_FINAL", $sformatf("-------------------------"), UVM_LOW)
    	endfunction

endclass