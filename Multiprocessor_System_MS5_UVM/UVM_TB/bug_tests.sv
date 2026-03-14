//////////////////////////////////////////////////
// ECE-593 Milestone 5 — Bug Injection Test Suite
// QuestaSim 2025.2_1 compatible
//////////////////////////////////////////////////


// ==============================================================
// BUG 1 SEQUENCE: Directed ADD — catches A-B instead of A+B
// ==============================================================

class mp_add_directed_seq extends uvm_sequence #(mp_transaction);
    `uvm_object_utils(mp_add_directed_seq)

    function new(string name = "mp_add_directed_seq");
        super.new(name);
    endfunction

    task body();
        mp_transaction tx;
        bit [7:0] A_vec [8];
        bit [7:0] B_vec [8];

        A_vec[0]=8'h01; B_vec[0]=8'h01;
        A_vec[1]=8'h0A; B_vec[1]=8'h05;
        A_vec[2]=8'hFF; B_vec[2]=8'h01;
        A_vec[3]=8'h10; B_vec[3]=8'h20;
        A_vec[4]=8'h55; B_vec[4]=8'h33;
        A_vec[5]=8'hAB; B_vec[5]=8'h12;
        A_vec[6]=8'h7F; B_vec[6]=8'h7F;
        A_vec[7]=8'h00; B_vec[7]=8'hFF;

        `uvm_info("BUG1_SEQ", "Starting Directed ADD Test (Bug 1 Detection)", UVM_LOW)

        for (int i = 0; i < 8; i++) begin
            tx = mp_transaction::type_id::create("tx");
            if (!tx.randomize() with {
                opcode == 4'b0001;
                A      == local::A_vec[i];
                B      == local::B_vec[i];
            }) `uvm_fatal("BUG1_SEQ", "Randomize failed")
            start_item(tx);
            finish_item(tx);
        end

        `uvm_info("BUG1_SEQ", "ADD Directed Sequence Done", UVM_LOW)
    endtask
endclass


// ==============================================================
// BUG 2 SEQUENCE: Directed SHIFT — catches swapped SHR/SHL
// ==============================================================

class mp_shift_directed_seq extends uvm_sequence #(mp_transaction);
    `uvm_object_utils(mp_shift_directed_seq)

    function new(string name = "mp_shift_directed_seq");
        super.new(name);
    endfunction

    task body();
        mp_transaction tx;
        bit [7:0] shr_vec [6];
        bit [7:0] shl_vec [6];

        shr_vec[0]=8'hFF; shr_vec[1]=8'h80; shr_vec[2]=8'hAA;
        shr_vec[3]=8'h01; shr_vec[4]=8'h10; shr_vec[5]=8'h5A;

        shl_vec[0]=8'h01; shl_vec[1]=8'h02; shl_vec[2]=8'h7F;
        shl_vec[3]=8'h55; shl_vec[4]=8'h0F; shl_vec[5]=8'hAA;

        `uvm_info("BUG2_SEQ", "Starting Directed SHIFT Test (Bug 2 Detection)", UVM_LOW)

        for (int i = 0; i < 6; i++) begin
            tx = mp_transaction::type_id::create("tx");
            if (!tx.randomize() with {
                opcode == 4'b0111;
                A      == local::shr_vec[i];
            }) `uvm_fatal("BUG2_SEQ", "Randomize failed")
            start_item(tx);
            finish_item(tx);
        end

        for (int i = 0; i < 6; i++) begin
            tx = mp_transaction::type_id::create("tx");
            if (!tx.randomize() with {
                opcode == 4'b1000;
                A      == local::shl_vec[i];
            }) `uvm_fatal("BUG2_SEQ", "Randomize failed")
            start_item(tx);
            finish_item(tx);
        end

        `uvm_info("BUG2_SEQ", "SHIFT Directed Sequence Done", UVM_LOW)
    endtask
endclass


// ==============================================================
// BUG 3 SEQUENCE: STORE->LOAD integrity — catches silent STORE
// ==============================================================

class mp_mem_integrity_seq extends uvm_sequence #(mp_transaction);
    `uvm_object_utils(mp_mem_integrity_seq)

    int num_pairs = 20;

    function new(string name = "mp_mem_integrity_seq");
        super.new(name);
    endfunction

    task body();
        mp_transaction wr_tx, rd_tx;
        bit [10:0] test_addr;
        bit [7:0]  test_data;

        `uvm_info("BUG3_SEQ", "Starting Memory Integrity Test (Bug 3 Detection)", UVM_LOW)

        repeat(num_pairs) begin
            test_addr = $urandom_range(0, 2047);
            test_data = $urandom_range(1, 255);

            wr_tx = mp_transaction::type_id::create("wr_tx");
            if (!wr_tx.randomize() with {
                opcode == 4'b0110;
                addr   == local::test_addr;
                A      == local::test_data;
            }) `uvm_fatal("BUG3_SEQ", "Randomize failed")
            start_item(wr_tx);
            finish_item(wr_tx);

            rd_tx = mp_transaction::type_id::create("rd_tx");
            if (!rd_tx.randomize() with {
                opcode == 4'b0101;
                addr   == local::test_addr;
            }) `uvm_fatal("BUG3_SEQ", "Randomize failed")
            start_item(rd_tx);
            finish_item(rd_tx);

            `uvm_info("BUG3_SEQ",
                $sformatf("STORE addr=0x%03h data=0x%02h -> LOAD same addr",
                test_addr, test_data), UVM_HIGH)
        end

        `uvm_info("BUG3_SEQ", "Memory Integrity Sequence Done", UVM_LOW)
    endtask
endclass


// ==============================================================
// BUG 1 TEST — directed ADD on all 4 cores in parallel
// ==============================================================

class mp_bug1_test extends mp_test;
    `uvm_component_utils(mp_bug1_test)

    function new(string name = "mp_bug1_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mp_add_directed_seq seq0, seq1, seq2, seq3;
        phase.raise_objection(this);
        `uvm_info("BUG1_TEST", "=== BUG INJECTION TEST 1: ADD returns SUB ===", UVM_LOW)
        `uvm_info("BUG1_TEST", "Expected: SCB_MISMATCH on ALL ADD transactions (all 4 cores)", UVM_LOW)

        seq0 = mp_add_directed_seq::type_id::create("seq0");
        seq1 = mp_add_directed_seq::type_id::create("seq1");
        seq2 = mp_add_directed_seq::type_id::create("seq2");
        seq3 = mp_add_directed_seq::type_id::create("seq3");

        fork
            seq0.start(env.core_agnt[0].seqr);
            seq1.start(env.core_agnt[1].seqr);
            seq2.start(env.core_agnt[2].seqr);
            seq3.start(env.core_agnt[3].seqr);
        join

        #200ns;
        phase.drop_objection(this);
    endtask
endclass


// ==============================================================
// BUG 2 TEST — directed SHIFT on all 4 cores in parallel
// ==============================================================

class mp_bug2_test extends mp_test;
    `uvm_component_utils(mp_bug2_test)

    function new(string name = "mp_bug2_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mp_shift_directed_seq seq0, seq1, seq2, seq3;
        phase.raise_objection(this);
        `uvm_info("BUG2_TEST", "=== BUG INJECTION TEST 2: SHR/SHL directions swapped ===", UVM_LOW)
        `uvm_info("BUG2_TEST", "Expected: SCB_MISMATCH on ALL shift transactions (all 4 cores)", UVM_LOW)

        seq0 = mp_shift_directed_seq::type_id::create("seq0");
        seq1 = mp_shift_directed_seq::type_id::create("seq1");
        seq2 = mp_shift_directed_seq::type_id::create("seq2");
        seq3 = mp_shift_directed_seq::type_id::create("seq3");

        fork
            seq0.start(env.core_agnt[0].seqr);
            seq1.start(env.core_agnt[1].seqr);
            seq2.start(env.core_agnt[2].seqr);
            seq3.start(env.core_agnt[3].seqr);
        join

        #200ns;
        phase.drop_objection(this);
    endtask
endclass


// ==============================================================
// BUG 3 TEST — STORE->LOAD integrity on all 4 cores in parallel
// ==============================================================

class mp_bug3_test extends mp_test;
    `uvm_component_utils(mp_bug3_test)

    function new(string name = "mp_bug3_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mp_mem_integrity_seq seq0, seq1, seq2, seq3;
        phase.raise_objection(this);
        `uvm_info("BUG3_TEST", "=== BUG INJECTION TEST 3: STORE never writes to memory ===", UVM_LOW)
        `uvm_info("BUG3_TEST", "Expected: SCB_MISMATCH on ALL LOAD-after-STORE transactions (all 4 cores)", UVM_LOW)

        seq0 = mp_mem_integrity_seq::type_id::create("seq0");
        seq1 = mp_mem_integrity_seq::type_id::create("seq1");
        seq2 = mp_mem_integrity_seq::type_id::create("seq2");
        seq3 = mp_mem_integrity_seq::type_id::create("seq3");

        seq0.num_pairs = 20;
        seq1.num_pairs = 20;
        seq2.num_pairs = 20;
        seq3.num_pairs = 20;

        fork
            seq0.start(env.core_agnt[0].seqr);
            seq1.start(env.core_agnt[1].seqr);
            seq2.start(env.core_agnt[2].seqr);
            seq3.start(env.core_agnt[3].seqr);
        join

        #200ns;
        phase.drop_objection(this);
    endtask
endclass
