//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 4 - UVM		// 
/////////////////////////////////

interface mp_intf (input logic clk, input logic rst_n);

    	//arrays of size [4] to support Core 0 through Core 3
    	logic [3:0]  req;          // Request from Core to Arbiter
    	logic [3:0]  gnt;          // Grant from Arbiter to Core
    	logic [3:0][3:0]  opcode;  // ALU Opcode
    	logic [3:0][10:0] addr;    // Memory Address
    	logic [3:0][7:0]  A;       // Operand A
    	logic [3:0][7:0]  B;       // Operand B
    	logic [3:0][7:0]  wdata;   // Write Data (for STORE)
	logic [3:0]  we;

    
    	// Shared or per-core response signals
    	logic [3:0][7:0]  data;       // Read Data (from LOAD or ALU result)
    	logic [3:0]      rvalid;      // Response Valid signal

endinterface