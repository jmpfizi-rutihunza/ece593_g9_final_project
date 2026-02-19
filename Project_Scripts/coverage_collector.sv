//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

class coverage_collector;
    	transaction tr;

    	covergroup op_cov;
        	option.per_instance = 1;
        	option.name = "Processor_Coverage";

        	// Ensure all 4 Cores are active
       		 CP_CORE: coverpoint tr.core_id {
            		bins cores[] = {0, 1, 2, 3};
        		}

        		// Ensure all instructions are tested
       		 CP_OPCODE: coverpoint tr.opcode {
            		bins NOP = {4'b0000};                    // No operation
			bins ALU = {4'b0001, 4'b0010};           // ADD, SUB
			bins shift = {4'b0111, 4'b1000};	 // Left and right shift
            		bins memory   = {4'b0101, 4'b0110};      // LOAD, STORE
            		bins logical    = {4'b0011, 4'b0100};    // AND, OR
            		bins special  = {[4'b1001: 4'b1101]};    // special function
			illegal_bins invalid = { [4'b1110 : 4'b1111] };  
        		}

        	// CROSS Coverage: Did every core do every operation?
        	CROSS_CORE_OP: cross CP_CORE, CP_OPCODE;
        
        	// Memory Coverage: Did we hit different areas of the 2KB?
        	CP_ADDR: coverpoint tr.addr {
            		bins low_mem  = {[0:511]};
            		bins mid_mem  = {[512:1535]};
            		bins high_mem = {[1536:2047]};
        		}
    	endgroup

    	function new();
        	op_cov = new();
    	endfunction

    	function void sample(transaction t);
        	this.tr = t;
        	op_cov.sample();
    	endfunction
endclass