//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 4 - UVM		// 
/////////////////////////////////

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "interface.sv"
`include "sequence_item.sv"
`include "sequencer.sv"
`include "sequence.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "agent.sv"
`include "env.sv"
`include "test.sv"

module tb_top;

	logic clk;
    	logic rst_n;

	// Instantiate the physical interface
    	mp_intf intf(clk, rst_n);


	//===========================
	//Arbiter logic
	//===========================

	logic [1:0] selected_core;      // Which core is granted access
    	logic       dut_req;            // Request to DUT
    	logic       dut_we;             // Write enable to DUT
    	logic [1:0] dut_core_id;        // Core ID to DUT
    	logic [3:0] dut_opcode;         // Opcode to DUT
    	logic [10:0] dut_addr;          // Address to DUT
    	logic [7:0] dut_A;              // Operand A to DUT
    	logic [7:0] dut_B; 		// Operand B to DUT

	// Round-Robin Arbiter
    	always_ff @(posedge clk or negedge rst_n) begin
    		if (!rst_n) begin
        		selected_core <= 2'b00;
    		end else begin
        	// Check if the core that currently HAS the bus is still using it
        	if (intf.req[selected_core] == 1'b1) begin
            		// HOLD: Stay on the same core
            		selected_core <= selected_core; 
        	end else begin
           	 	// MOVE: Current core is done (req=0), look for the next one
            		if (selected_core == 2'b11)
                		selected_core <= 2'b00;
            		else
                	selected_core <= selected_core + 1'b1;
        		end
    		end
	end

	// MUX: Select active core's signals to send to DUT
    	always_comb begin
        	dut_core_id = selected_core;
		case(selected_core)
            		2'b00: begin  // Core 0
                		dut_req    = intf.req[0];
                		dut_we     = intf.we[0];
                		dut_opcode = intf.opcode[0];
                		dut_addr   = intf.addr[0];
                		dut_A      = intf.A[0];
                		dut_B      = intf.B[0];
            			end

			2'b01: begin  // Core 1
               			dut_req    = intf.req[1];
                		dut_we     = intf.we[1];
                		dut_opcode = intf.opcode[1];
                		dut_addr   = intf.addr[1];
                		dut_A      = intf.A[1];
               	 		dut_B      = intf.B[1];
            			end

			2'b10: begin  // Core 2
                		dut_req    = intf.req[2];
                		dut_we     = intf.we[2];
                		dut_opcode = intf.opcode[2];
                		dut_addr   = intf.addr[2];
                		dut_A      = intf.A[2];
                		dut_B      = intf.B[2];
            			end

			2'b11: begin  // Core 3
                		dut_req    = intf.req[3];
                		dut_we     = intf.we[3];
                		dut_opcode = intf.opcode[3];
                		dut_addr   = intf.addr[3];
                		dut_A      = intf.A[3];
                		dut_B      = intf.B[3];
            			end
		endcase
    	end

	// DEMUX: Route DUT response back to appropriate core
    	logic dut_gnt;
    	logic dut_rvalid;
    	logic [7:0] dut_data_out;
    	logic [1:0] dut_core_id_out;

	// DEMUX: Route DUT grant back to selected core
    	always_comb begin
        	intf.gnt = 4'b0000;  // Default: no grants
        	intf.gnt[selected_core] = dut_gnt;  // Grant to selected core
    	end

    
    	always_comb begin
        	intf.rvalid = 4'b0000;  // Default: no valid signals
        	intf.data = '{default: '0};  // Default: all zeros
        
        	// Route response to core indicated by DUT
        	if (dut_rvalid) begin
            		intf.rvalid[dut_core_id_out] = 1'b1;
            		intf.data[dut_core_id_out] = dut_data_out;
        	end
   	end


	// Instantiate the DUT
    	mp_dut dut (
		.clk(clk),
        	.rst_n(rst_n),
		// Arbitrated inputs
        	.core_id(dut_core_id),
        	.opcode(dut_opcode),
        	.req(dut_req),
        	.addr(dut_addr),
        	.A(dut_A),
        	.B(dut_B),
        	.we(dut_we),
        
        	// Outputs
        	.gnt(dut_gnt),
        	.rvalid(dut_rvalid),
        	.data_out(dut_data_out),
        	.core_id_out(dut_core_id_out)

    		);

	// Clock Generation
    	initial begin
        	clk = 0;
        	forever #5 clk = ~clk; 
    	end

	// Reset Generation
    	initial begin
        	rst_n = 0;
        	#20 rst_n = 1;
    	end

    	initial begin
        	// Pass the physical interface into the UVM Config DB
        	uvm_pkg:: uvm_config_db#(virtual mp_intf)::set(null, "*", "vif", intf);
        
        	// Start the UVM simulation
        	run_test("mp_test");
    	end

endmodule