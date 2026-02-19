//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

class scoreboard;

  mailbox #(transaction) mon_in2scb;
  mailbox #(transaction) mon_out2scb;

  // Reference Memory
  bit [7:0] ref_mem [0:2047];

  // One FIFO per processor
  transaction exp_queue[4][$];

  function new(mailbox #(transaction) mon_in2scb,
               mailbox #(transaction) mon_out2scb);
    this.mon_in2scb  = mon_in2scb;
    this.mon_out2scb = mon_out2scb;
    foreach (ref_mem[i]) ref_mem[i] = 8'h00;
  endfunction

  task run();
    fork
      // Predict results from inputs
      forever begin
        transaction tr_in;
        mon_in2scb.get(tr_in);
        predict_result(tr_in);
      end

      // Compare with outputs
      forever begin
        transaction tr_out;
        mon_out2scb.get(tr_out);
        check_result(tr_out);
      end
    join_none
  endtask

  // Reference Model: computes expected_val based on opcode/A/B/addr
  function void predict_result(transaction tx);
    case (tx.opcode)
      4'b0001: tx.expected_val = tx.A + tx.B;        // Add
      4'b0010: tx.expected_val = tx.A & tx.B;        // And
      4'b0011: tx.expected_val = tx.A - tx.B;        // Sub
      4'b0100: tx.expected_val = tx.A * tx.B;        // Mul
      4'b0101: tx.expected_val = ref_mem[tx.addr];   // Load
      4'b0111: tx.expected_val = tx.A >> 1;          // Shift right
      4'b1000: tx.expected_val = tx.A << 1;          // Shift left
      4'b1001: tx.expected_val = (tx.A * tx.B) - tx.A;
      4'b1010: tx.expected_val = (tx.A * 4 * tx.B) - tx.A;
      4'b1011: tx.expected_val = (tx.A * tx.B) + tx.A;
      4'b1100: tx.expected_val = (tx.A * 3);
      4'b1101: tx.expected_val = (tx.A * tx.B) + tx.B;

      // STORE (0110): update memory using input write data
      4'b0110: begin
        ref_mem[tx.addr] = tx.data;
        tx.expected_val  = 8'h00; // (optional) no return value for store
      end

      default: tx.expected_val = 8'h00;
    endcase

    exp_queue[tx.core_id].push_back(tx);

    $display("[SCB] predicted core=%0d op=%0h addr=%0d exp=%0h",
             tx.core_id, tx.opcode, tx.addr, tx.expected_val);
  endfunction

  // Compare actual output with expected
  function void check_result(transaction act);
    transaction exp;

    if (exp_queue[act.core_id].size() == 0) begin
      $display("[SCB] WARNING: No expected item for core=%0d (dropping output)", act.core_id);
      return;
    end

    exp = exp_queue[act.core_id].pop_front();

    if (act.data === exp.expected_val) begin
      $display("[SCB PASS] core=%0d op=%0h exp=%0h act=%0h",
               act.core_id, act.opcode, exp.expected_val, act.data);
    end else begin
      $error("[SCB FAIL] core=%0d op=%0h exp=%0h act=%0h",
             act.core_id, act.opcode, exp.expected_val, act.data);
    end
  endfunction

endclass
