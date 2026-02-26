//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV
`include "transaction.sv"
`include "coverage_collector.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor_in.sv"
`include "monitor_out.sv"
`include "scoreboard.sv"


class environment;
	
	//components
	generator gen;
	driver driv;
	monitor_in mon_in;
	monitor_out mon_out;
	scoreboard scb;

	//mailboxes
	mailbox #(transaction) gen2driv;
	mailbox #(transaction) mon_in2scb;
	mailbox #(transaction) mon_out2scb;

	virtual intf vif;
	//Handler for functional coverage
	coverage_collector cov;

	//constructors
	function new(virtual intf vif);
       
        	this.vif = vif;
        
        	// Mailbox instances
        	gen2driv    = new();
        	mon_in2scb  = new();
        	mon_out2scb = new();
		
		//instantiate coverage
		cov = new();
        
        	// Instantiate Components
        	gen     = new(gen2driv);
        	driv    = new(gen2driv, vif, gen); 
        	mon_in  = new(vif, mon_in2scb, cov); 
        	mon_out = new(vif, mon_out2scb);
        	scb     = new(mon_in2scb, mon_out2scb);
   	 endfunction

    
    	task pre_test();
        	$display("[ENV] Resetting");
        	driv.reset(); 
    	endtask

    	//parallel excusion 
    	task test();
        	$display("[ENV] Starting Test Execution...");
        	fork
            		gen.main();      // Generator starts producing tx_count transactions
            		driv.main();     // Driver starts feeding the Arbiter
            		mon_in.run();   // Monitor_In starts capturing operands A and B
            		mon_out.run();  // Monitor_Out starts capturing bus results
            		scb.run();       // Scoreboard starts comparing results


			//forever begin
                		//transaction tr;
                		//mon_in2scb.peek(tr); 
                		//cov.sample(tr);
				//@(vif.mon_cb);
            		//end
        	//join_any 
		join_none           
    	endtask

   
    	task post_test();
        	// Wait until generator is done
        	wait(gen.ended.triggered);
       		repeat(100) @(vif.mon_cb);
        
        	$display("[ENV] --- All Transactions Verified ---");
        	$display("[ENV] Time: %0t", $time);
       		 $finish; 
    	endtask

   
    	task run();
        	pre_test();
        	test();
        	post_test();
    	endtask

endclass
`endif	
