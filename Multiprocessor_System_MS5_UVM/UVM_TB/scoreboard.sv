//////////////////////////////////
//    ECE-593 Project           //
//    Multiprocessor System     //
//    Milestone 5 - UVM        //
/////////////////////////////////

class mp_scoreboard extends uvm_scoreboard;

    // UVM factory registration
    `uvm_component_utils(mp_scoreboard)

    // Analysis FIFO - receives transactions from all monitors
    uvm_tlm_analysis_fifo #(mp_transaction) item_collected_fifo;

    // Counters
    int match_count = 0;
    int error_count = 0;
    int burst_id    = 0;   // Transaction counter (professor requires burst_id in SCB messages)

    // Reference memory to track STOREs for subsequent LOAD checks
    bit [7:0] ref_mem [2048];

    // Constructor
    function new(string name = "mp_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        item_collected_fifo = new("item_collected_fifo", this);
    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);
        mp_transaction tx;
        forever begin
            // Get next observed transaction from monitor
            item_collected_fifo.get(tx);
            burst_id++;

            // Step 1: Run reference model to compute expected result
            predict_result(tx);

            // Step 2: Compare actual vs expected
            compare_result(tx);
        end
    endtask

    // Reference Model - mirrors DUT behavior
    virtual function void predict_result(mp_transaction tx);
        case (tx.opcode)
            4'b0001: tx.expected_val = tx.A + tx.B;               // ADD
            4'b0010: tx.expected_val = tx.A & tx.B;               // AND
            4'b0011: tx.expected_val = tx.A - tx.B;               // SUB
            4'b0100: tx.expected_val = tx.A * tx.B;               // MUL
            4'b0101: tx.expected_val = ref_mem[tx.addr];          // LOAD
            4'b0110: begin                                         // STORE
                         ref_mem[tx.addr] = tx.A;
                         tx.expected_val  = tx.A;
                     end
            4'b0111: tx.expected_val = tx.A >> 1;                 // SHR
            4'b1000: tx.expected_val = tx.A << 1;                 // SHL
            4'b1001: tx.expected_val = (tx.A * tx.B) - tx.A;     // (A*B)-A
            4'b1010: tx.expected_val = (tx.A * 4 * tx.B) - tx.A; // (A*4*B)-A
            4'b1011: tx.expected_val = (tx.A * tx.B) + tx.A;     // (A*B)+A
            4'b1100: tx.expected_val = (tx.A * 3);               // A*3
            4'b1101: tx.expected_val = (tx.A * tx.B) + tx.B;     // (A*B)+B
            default: tx.expected_val = 8'h00;                     // NOP / invalid
        endcase
    endfunction

    // Comparison Logic
    virtual function void compare_result(mp_transaction tx);
        // Check result for ALU ops, LOAD, and STORE
        // Skip NOP (0000)
        if (tx.opcode != 4'b0000) begin
            if (tx.data === tx.expected_val) begin
                `uvm_info("[SCB]", $sformatf("MATCH burstid=%0d Core=%0d Op=0x%0h Exp=0x%02h Act=0x%02h",
                    burst_id, tx.core_id, tx.opcode, tx.expected_val, tx.data), UVM_LOW)
                match_count++;
            end else begin
                `uvm_error("[SCB]", $sformatf("MISMATCH burstid=%0d Core=%0d Op=0x%0h Exp=0x%02h Act=0x%02h",
                    burst_id, tx.core_id, tx.opcode, tx.expected_val, tx.data))
                error_count++;
            end
        end
    endfunction

    // Final Summary Report
    virtual function void report_phase(uvm_phase phase);
        `uvm_info("[SCB]", "========================================", UVM_LOW)
        `uvm_info("[SCB]", "       SCOREBOARD FINAL REPORT          ", UVM_LOW)
        `uvm_info("[SCB]", "========================================", UVM_LOW)
        `uvm_info("[SCB]", $sformatf("  Total Transactions : %0d", burst_id),    UVM_LOW)
        `uvm_info("[SCB]", $sformatf("  Total Matches      : %0d", match_count), UVM_LOW)
        `uvm_info("[SCB]", $sformatf("  Total Errors       : %0d", error_count), UVM_LOW)
        if (error_count == 0)
            `uvm_info("[SCB]", "  RESULT: ALL TESTS PASSED", UVM_LOW)
        else
            `uvm_error("[SCB]", $sformatf("  RESULT: %0d TESTS FAILED", error_count))
        `uvm_info("[SCB]", "========================================", UVM_LOW)
    endfunction

endclass
