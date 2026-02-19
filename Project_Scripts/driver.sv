//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

class driver;
    	mailbox #(transaction) gen2driv;
    	
    	virtual intf.drv vif;
	generator gen;

    	function new(mailbox #(transaction) gen2driv, virtual intf.drv vif, generator gen);
        	this.gen2driv = gen2driv;
        	this.vif = vif;
		this.gen = gen;
    	endfunction

    	// Reset
    	task reset();
        	$display("[DRV] Reset started");
        	vif.drv_cb.reset_n <= 1'b0;
        	vif.drv_cb.req     <= 1'b0;
        	vif.drv_cb.we <= 1'b0;
        	repeat(5) @(vif.drv_cb); 
        	vif.drv_cb.reset_n <= 1'b1;
        	$display("[DRV] Reset completed");
   	endtask

    	task main();
        	forever begin
            		transaction tx;
            		gen2driv.get(tx);
            
 
            		@(vif.drv_cb);
            
            		// Drive request signals 
            		vif.drv_cb.core_id <= tx.core_id;
            		vif.drv_cb.opcode  <= tx.opcode;
            		vif.drv_cb.addr    <= tx.addr;
            		vif.drv_cb.req     <= 1'b1;

            
            		//wait(vif.drv_cb.gnt === 1'b1);
			while (vif.drv_cb.gnt !== 1'b1) @(vif.drv_cb);
            
            		// If it's a STORE (0110), drive the data to be written
            		if (tx.opcode == 4'b0110) begin
                		//vif.drv_cb.data_in  <= tx.A;
				vif.drv_cb.A <= tx.A; 
				vif.drv_cb.B <= tx.B; 
                		vif.drv_cb.we <= 1'b1;
           		 end

            		@(vif.drv_cb);
            		vif.drv_cb.req      <= 1'b0;
            		vif.drv_cb.we <= 1'b0;
			-> gen.next;
            
            		$display("[DRV] Finished Core %0d transaction at %0t", tx.core_id, $time);
        	end
    	endtask
endclass