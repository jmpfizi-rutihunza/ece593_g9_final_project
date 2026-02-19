//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

`ifndef GENERATOR_SV
`define GENERATOR_SV
`include "transaction.sv"

class generator;
	rand transaction tx;
	mailbox #(transaction) gen2driv;
	int tx_count;

	event ended;
	event next;

	function new (mailbox #(transaction) gen2driv);
		this.gen2driv = gen2driv;
	endfunction

	task main();
		$display ("Generator started");
		repeat (tx_count) begin
			tx = new();
			assert (tx.randomize());
			gen2driv.put(tx.copy());
			@(next);
		end
		
		$display ("Generator completed");

		-> ended;
	endtask
endclass
`endif