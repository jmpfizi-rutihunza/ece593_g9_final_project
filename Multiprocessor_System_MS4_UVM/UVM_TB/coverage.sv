//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 4 - UVM		// 
/////////////////////////////////

class mp_coverage extends uvm_subscriber #(mp_transaction);
    
	//UVM factory registration 
	`uvm_component_utils(mp_coverage)

	//handle
    	mp_transaction tr;

    	covergroup op_cov with function sample(mp_transaction t);
        	option.per_instance = 1;
        	option.name = "Processor_Coverage";

        	// Core Activity
        	CP_CORE: coverpoint t.core_id {
            			bins cores[] = {0, 1, 2, 3};
        			}

        	// Instruction Set Coverage
        	CP_OPCODE: coverpoint t.opcode {
            			bins NOP     = {4'b0000};
           			bins ALU     = {4'b0001, 4'b0010};
            			bins shift   = {4'b0111, 4'b1000};
           			bins memory  = {4'b0101, 4'b0110};
            			bins logical = {4'b0011, 4'b0100};
            			bins special = {[4'b1001: 4'b1101]};
            			illegal_bins invalid = { [4'b1110 : 4'b1111] };  
        			}

        	// Memory Addressing (2KB Range)
        	CP_ADDR: coverpoint t.addr {
            			bins low_mem  = {[0:511]};
            			bins mid_mem  = {[512:1535]};
            			bins high_mem = {[1536:2047]};
        			}

        	// Operand Data (Corner Cases)
        	CP_OPERAND_A: coverpoint t.A {
            			bins zero = {8'h00};
            			bins max  = {8'hFF};
           			bins others = {[8'h01:8'hFE]};
        			}

       		// CROSS Coverage:
        	CROSS_CORE_OP: cross CP_CORE, CP_OPCODE;
        
        	// Did we perform memory ops (LOAD/STORE) in all memory regions?
       	 	CROSS_MEM_REGION: cross CP_OPCODE, CP_ADDR {
            				ignore_bins non_mem = CROSS_MEM_REGION with (!(CP_OPCODE inside {4'b0101, 4'b0110}));
        			}
   	endgroup

    	function new(string name = "mp_coverage", uvm_component parent = null);
        	super.new(name, parent);
        	op_cov = new();
    	endfunction

    	// Standard UVM Subscriber function
    	virtual function void write(mp_transaction t);
        	//this.tr = t;
        	op_cov.sample(t);
    	endfunction

endclass