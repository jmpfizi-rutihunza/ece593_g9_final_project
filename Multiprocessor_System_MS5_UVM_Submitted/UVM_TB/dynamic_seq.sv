class mp_dynamic_vseq extends uvm_sequence;
    `uvm_object_utils(mp_dynamic_vseq)

    // Shared resources
    int total_tasks = 100; 
    semaphore bucket_lock = new(1); 

    // Handles to your 4 sequencers (assigned by the test)
    mp_sequencer seqr_0, seqr_1, seqr_2, seqr_3;

    task body();
        `uvm_info("VSEQ_START", "Starting Dynamic Stress Test: 100 tasks shared by 4 cores", UVM_LOW)
        
        fork
            core_worker(seqr_0, "CORE_0");
            core_worker(seqr_1, "CORE_1");
            core_worker(seqr_2, "CORE_2");
            core_worker(seqr_3, "CORE_3");
        join

        `uvm_info("VSEQ_END", "Test Complete: All 100 tasks processed.", UVM_LOW)
    endtask

    task core_worker(mp_sequencer s, string id);
        int tasks_done_by_this_core = 0;
        
        while (1) begin
            // 1. Grab the "Talking Stick"
            bucket_lock.get(1); 
            
            if (total_tasks <= 0) begin
                bucket_lock.put(1); // Return stick and exit
                break;
            end
            
            total_tasks--; // Claim a task
            tasks_done_by_this_core++;
            
            // Print progress so you can see the 'race' in the transcript
            `uvm_info(id, $sformatf("Claimed task! Tasks remaining: %0d", total_tasks), UVM_MEDIUM)
            
            bucket_lock.put(1); // Release stick so other cores can grab

            // 2. Start the actual Hardware Transaction
            execute_transaction(s);
        end
        
        `uvm_info(id, $sformatf("Finished. Total tasks handled by this core: %0d", tasks_done_by_this_core), UVM_LOW)
    endtask

    task execute_transaction(mp_sequencer s);
        mp_sequence seq = mp_sequence::type_id::create("seq");
        seq.num_tx = 1; // We handle them one by one for maximum dynamic balancing
        seq.start(s);
    endtask
endclass