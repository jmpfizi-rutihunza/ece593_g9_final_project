//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

class scoreboard;

  mailbox #(transaction) mon_in2scb;
  mailbox #(transaction) mon_out2scb;

  // Reference Memory (2KB, 8-bit)
  bit [7:0] ref_mem [0:2047];

  // One FIFO per core
  transaction exp_queue[4][$];

  function new(mailbox #(transaction) mon_in2scb,
               mailbox #(transaction) mon_out2scb);
    this.mon_in2scb  = mon_in2scb;
    this.mon_out2scb = mon_out2scb;

    foreach (ref_mem[i]) ref_mem[i] = 8'h00;
  endfunction

  task run();
    fork
      // Predict expected response for each accepted input request
      forever begin
        transaction tr_in;
        mon_in2scb.get(tr_in);
        predict_result(tr_in);
      end

      // Compare outputs as they arrive
      forever begin
        transaction tr_out;
        mon_out2scb.get(tr_out);
        check_result(tr_out);
      end
    join_none
  endtask

  // DUT Reference Model (matches mp_dut.sv):
  // - write: mem[addr]=data_in, response returns written data
  // - read : response returns mem[addr]
  function void predict_result(transaction tx);
    if (tx.we) begin
      ref_mem[tx.addr] = tx.data;
      tx.expected_val  = tx.data;           // DUT returns written data next cycle
    end
    else begin
      tx.expected_val  = ref_mem[tx.addr];  // DUT returns memory content next cycle
    end

    exp_queue[tx.core_id].push_back(tx);

    $display("[SCB] predicted core=%0d addr=%0d we=%0b exp=%0h",
             tx.core_id, tx.addr, tx.we, tx.expected_val);
  endfunction

  function void check_result(transaction act);
    transaction exp;

    if (exp_queue[act.core_id].size() == 0) begin
      $display("[SCB] WARNING: No expected item for core=%0d (dropping output)", act.core_id);
      return;
    end

    exp = exp_queue[act.core_id].pop_front();

    if (act.data === exp.expected_val) begin
      $display("[SCB PASS] core=%0d exp=%0h act=%0h",
               act.core_id, exp.expected_val, act.data);
    end
    else begin
      $error("[SCB FAIL] core=%0d exp=%0h act=%0h (addr=%0d we=%0b)",
             act.core_id, exp.expected_val, act.data, exp.addr, exp.we);
    end
  endfunction

endclass
endclass

