//////////////////////////////////
//    ECE-593 Project		//
//    Multiprocessor System	//
//    Milestone 4 - UVM		// 
/////////////////////////////////


class mp_sequence extends uvm_sequence #(mp_transaction);

	//UVM factory registration
	`uvm_object_utils (mp_sequence)

	rand int num_tx = 1000;

	//constructor
	function new(string name = "mp_sequence");
    		super.new(name);
  	endfunction
	
	//Main Task
	task body();
		
		`uvm_info("SEQ", $sformatf("Starting with %0d transactions", num_tx), UVM_LOW)

		repeat(num_tx) begin
			//create handle
			mp_transaction tx;

			//uvm factory object
			tx = mp_transaction::type_id::create("tx");

			// Randomize it
    			if (!tx.randomize()) begin
      				`uvm_error("SEQ", "Randomization failed")
    			end
    
   			start_item(tx);   // Tells sequencer "I want to send this transaction", Wait for driver to be ready
    			finish_item(tx);  // Send to driver and wait for completion
		end

		`uvm_info("SEQ", "Base Sequence Finished", UVM_LOW)
	endtask

endclass

//------------------------------------------------------------
//Read - Only sequence
//------------------------------------------------------------

class mp_read_only_sequence extends mp_sequence;
    	`uvm_object_utils(mp_read_only_sequence)
    
    
   	function new(string name = "mp_read_only_sequence");
        	super.new(name);
    	endfunction
    
    	task body();
        	`uvm_info("SEQ", "Starting READ-ONLY sequence", UVM_LOW)
        
        	repeat(num_tx) begin
            		mp_transaction tx;
            		tx = mp_transaction::type_id::create("tx");
            
            	// Force LOAD operation only
            	assert(tx.randomize() with {opcode == 4'b0101; });
            
            	start_item(tx);
            	finish_item(tx);
        	end
        
        	`uvm_info("SEQ", "READ-ONLY sequence completed", UVM_LOW)
    	endtask
endclass

//------------------------------------------------------------
//Write - Only sequence
//------------------------------------------------------------

class mp_write_only_sequence extends mp_sequence;
    	`uvm_object_utils(mp_write_only_sequence)
    
    
    	function new(string name = "mp_write_only_sequence");
        	super.new(name);
    	endfunction
    
    	task body();
        	`uvm_info("SEQ", "Starting WRITE-ONLY sequence", UVM_LOW)
        
        	repeat(num_tx) begin
            		mp_transaction tx;
            		tx = mp_transaction::type_id::create("tx");
            
            		// Force STORE operation only
            		assert(tx.randomize() with {opcode == 4'b0110; });
            
            		start_item(tx);
            		finish_item(tx);
        	end
        
        	`uvm_info("SEQ", "WRITE-ONLY sequence completed", UVM_LOW)
    	endtask
endclass

//------------------------------------------------------------
//Write then Read Sequence 
//------------------------------------------------------------

class mp_write_read_sequence extends mp_sequence;
    	
	`uvm_object_utils(mp_write_read_sequence)
    
    
    	function new(string name = "mp_write_read_sequence");
        	super.new(name);
    	endfunction
    
    	task body();
        	`uvm_info("SEQ", "Starting WRITE-READ sequence", UVM_LOW)
        
        	repeat(num_tx) begin
            		mp_transaction write_tx, read_tx;
            		bit [10:0] test_addr;
            		bit [7:0] test_data;
            
            		// Randomize address and data
            		test_addr = $urandom_range(0, 2047);
            		test_data = $urandom();
            
            		// WRITE to address
            		write_tx = mp_transaction::type_id::create("write_tx");
            		assert(write_tx.randomize() with {
                			opcode == 4'b0110;        // STORE
                			addr == local::test_addr;
               				A == local::test_data;    // Data to write
            				});
            
            		start_item(write_tx);
            		finish_item(write_tx);
            
            		`uvm_info("SEQ", $sformatf("WRITE: addr=0x%03h data=0x%02h", test_addr, test_data), UVM_HIGH)
            
            		// READ from same address
            		read_tx = mp_transaction::type_id::create("read_tx");
            		assert(read_tx.randomize() with {
                			opcode == 4'b0101;        // LOAD
                			addr == local::test_addr;
            				});
            
            		start_item(read_tx);
            		finish_item(read_tx);
            
            		`uvm_info("SEQ", $sformatf("READ: addr=0x%03h (expect 0x%02h)", test_addr, test_data), UVM_HIGH)
        	end
        
        	`uvm_info("SEQ", "WRITE-READ sequence completed", UVM_LOW)
   	endtask
endclass

//------------------------------------------------------------
//Read then Write then Read (Overwrite)
//------------------------------------------------------------

class mp_read_write_read_sequence extends mp_sequence;
    
	`uvm_object_utils(mp_read_write_read_sequence)
    
    
    	function new(string name = "mp_read_write_read_sequence");
        	super.new(name);
    	endfunction
    
    	task body();
        	`uvm_info("SEQ", "Starting READ-WRITE-READ sequence", UVM_LOW)
        
        	repeat(num_tx) begin
            		mp_transaction read_tx1, write_tx, read_tx2;
            		bit [10:0] test_addr;
            		bit [7:0] new_data;
            
            		test_addr = $urandom_range(0, 2047);
            		new_data = $urandom();
            
            	// READ (old value)
            	read_tx1 = mp_transaction::type_id::create("read_tx1");
            	assert(read_tx1.randomize() with {
                		opcode == 4'b0101;	// LOAD
                		addr == local::test_addr;
            			});
            
		start_item(read_tx1);
            	finish_item(read_tx1);
            
            	// WRITE new value
            	write_tx = mp_transaction::type_id::create("write_tx");
            	assert(write_tx.randomize() with {
                		opcode == 4'b0110;	//STORE
                		addr == local::test_addr;
               			A == local::new_data;
            			});
            
		start_item(write_tx);
            	finish_item(write_tx);
            
            	// READ (new value)
            	read_tx2 = mp_transaction::type_id::create("read_tx2");
           	assert(read_tx2.randomize() with {
                		opcode == 4'b0101;	//LOAD
                		addr == local::test_addr;
            			});
            
		start_item(read_tx2);
            	finish_item(read_tx2);
            
            	`uvm_info("SEQ", $sformatf("Tested overwrite at addr=0x%03h", test_addr), UVM_HIGH)
        	end
        
        	`uvm_info("SEQ", "READ-WRITE-READ sequence completed", UVM_LOW)
   	endtask
endclass

//------------------------------------------------------------
//Virtual Sequence for Directed test
//------------------------------------------------------------


class mp_vseq extends uvm_sequence;
    
	`uvm_object_utils(mp_vseq)
    	mp_sequencer seqr_0, seqr_1, seqr_2, seqr_3;

    	function new(string name = "mp_vseq");
        	super.new(name);
   	endfunction

    	task body();
        	`uvm_info("VSEQ", "Starting Directed Parallel Execution", UVM_LOW)
        	fork
            		begin
                		mp_write_only_sequence seq = mp_write_only_sequence::type_id::create("seq");
                		seq.num_tx = 20;
                		seq.start(seqr_0);
            		end
            		begin
                		mp_read_only_sequence seq = mp_read_only_sequence::type_id::create("seq");
                		seq.num_tx = 20;
                		seq.start(seqr_1);
           		end
           		begin
                		mp_write_read_sequence seq = mp_write_read_sequence::type_id::create("seq");
                		seq.num_tx = 10;
                		seq.start(seqr_2);
            		end
            		begin
               	 		mp_read_write_read_sequence seq = mp_read_write_read_sequence::type_id::create("seq");
                		seq.num_tx = 10;
                		seq.start(seqr_3);
            		end
        	join
    	endtask
endclass


//------------------------------------------------------------
//Virtual Sequence for Dynamic test - shared pool
//------------------------------------------------------------


class mp_dynamic_vseq extends mp_sequence; 


	`uvm_object_utils(mp_dynamic_vseq)

	semaphore bucket_lock = new(1);
	mp_sequencer seqr_0, seqr_1, seqr_2, seqr_3;

    	function new(string name = "mp_dynamic_vseq");
        	super.new(name);
   	endfunction

    	task body();
        	
        	`uvm_info("VSEQ", $sformatf("Dynamic Test: Sharing %0d total tasks", num_tx), UVM_LOW)
        
        	fork
            		core_worker(seqr_0, "CORE_0");
            		core_worker(seqr_1, "CORE_1");
            		core_worker(seqr_2, "CORE_2");
            		core_worker(seqr_3, "CORE_3");
        	join
    	endtask

    	task core_worker(mp_sequencer s, string id);
        	while (1) begin
            		bucket_lock.get(1);
            		if (num_tx <= 0) begin 
               			bucket_lock.put(1);
				`uvm_info(id, "Pool is empty, core is retiring.", UVM_LOW)
                	break;
            	end
            	num_tx--; 	// Decrement the shared pool
            	bucket_lock.put(1);

            	// Execute 1 transaction on the hardware
            	execute_single_tx(s);
        	end
    	endtask

    	task execute_single_tx(mp_sequencer s);
        	mp_sequence seq = mp_sequence::type_id::create("seq");
        	seq.num_tx = 1;  
        	seq.start(s);
    	endtask
endclass