//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

class scoreboard;
	mailbox mon_in2scb;  
	mailbox mon_out2scb; 

    	// Reference Memory
    	bit [7:0] ref_mem [2048]; 

    	// One FIFO per processor
   	transaction exp_queue[4][$]; 

    	function new (mailbox mon_in2scb, mailbox mon_out2scb);
        	this.mon_in2scb = mon_in2scb;
        	this.mon_out2scb = mon_out2scb;
        	// Initialize reference memory to 0
        	foreach(ref_mem[i]) ref_mem[i] = 8'h00;
    	endfunction

    
    	task run();
        	fork
            // predicting results from Core inputs
            		forever begin
                		transaction tr_in;
                		mon_in2scb.get(tr_in);
               		 	predict_result(tr_in);
            		end

            // comparing with actual Bus/Cache outputs
            		forever begin
                		transaction tr_out;
                		mon_out2scb.get(tr_out);
                		check_result(tr_out);
            		end
        	join_none
    	endtask

    	// Reference Model
	function void predict_result(transaction tx);
        	case(tx.opcode)
            		4'b0001: tx.expected_val = tx.A + tx.B;               // Add A and B 
            		4'b0010: tx.expected_val = tx.A & tx.B;               // And 
            		4'b0011: tx.expected_val = tx.A - tx.B;               // A - B 
            		4'b0100: tx.expected_val = tx.A * tx.B;               // A * B
            		4'b0101: tx.expected_val = ref_mem[tx.addr];          // Load from memmory 
            		4'b0111: tx.expected_val = tx.A >> 1;                 // Shift right 
            		4'b1000: tx.expected_val = tx.A << 1;                 // Shift left 
            
            		// Special Functions 
            		4'b1001: tx.expected_val = (tx.A * tx.B) - tx.A;     // (A*B)-A 
            		4'b1010: tx.expected_val = (tx.A * 4 * tx.B) - tx.A; // (A*4*B)-A 
            		4'b1011: tx.expected_val = (tx.A * tx.B) + tx.A;     // (A*B)+A 
            		4'b1100: tx.expected_val = (tx.A * 3);               // (A*3) 
            		4'b1101: tx.expected_val = (tx.A * tx.B) + tx.B;     // (A*B)+B 
            
            		default: tx.expected_val = 8'h00; 
        	endcase
        
        	// Push the predicted transaction into the FIFO for the specific Core ID
        	exp_queue[tx.core_id].push_back(tx);
    	endfunction

    	// Comparison Logic
    	function void check_result(transaction act);
        	transaction exp;
        	if (exp_queue[act.core_id].size() > 0) begin
            		exp = exp_queue[act.core_id].pop_front();
            
            	// Check Actual Data Vs Expected Data
            		if (act.data === exp.expected_val) begin
                		$display("[SCB PASS] Core %0d | Op: %h | Data: %h", act.core_id, act.opcode, act.data);
            		end else begin
                		$error("[SCB FAIL] Core %0d | Op: %h | Exp: %h | Act: %h", act.core_id, act.opcode, exp.expected_val, act.data);
            		end

            	// Update memory if the core performed a STORE 
            		if (act.opcode == 4'b0110) begin
                		ref_mem[act.addr] = act.data;
            		end
        	end
    	endfunction

endclass
