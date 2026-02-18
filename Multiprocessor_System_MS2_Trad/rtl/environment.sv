//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

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
	mailbox gen2driv;
	mailbox mon_in2scb;
	mailbox mon_out2scb;

	virtual intf vif;

	//constructors
	function new(virtual intf vif);
       
        	this.vif = vif;
        
        	// Mailbox instances
        	gen2driv    = new();
        	mon_in2scb  = new();
        	mon_out2scb = new();
        
        	// Instantiate Components
        	gen     = new(gen2driv);
        	driv    = new(gen2driv, vif.drv); 
        	mon_in  = new(mon_in2scb, vif.mon); 
        	mon_out = new(mon_out2scb, vif.mon);
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
            		mon_in.main();   // Monitor_In starts capturing operands A and B
            		mon_out.main();  // Monitor_Out starts capturing bus results
            		scb.run();       // Scoreboard starts comparing results
        	join_any            
    	endtask

   
    	task post_test();
        	// Wait until generator is done
        	wait(gen.ended.triggered);
       		repeat(50) @(vif.mon_cb);
        
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
		
