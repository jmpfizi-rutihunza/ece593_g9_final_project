//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

`include "transaction.sv"

class generator;
	rand transaction tx;
	mailbox gen2driv;
	int tx_count;

	function new (mailbox gen2driv);
		this.gen2driv = gen2driv;
	endfunction

	task main();
		$display ("Generator started");
		repeat (tx_count) begin
			tx = new();
			assert (tx.randomize());
			gen2driv.put(tx.copy());
		end
		
		$display ("Generator completed");
	endtask
endclass