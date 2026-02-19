//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

class generator;

  transaction tx;
  mailbox #(transaction) gen2driv;
  int tx_count;

  event ended;

  // Transaction numbering (burst id)
  static int id = 0;

  function new(mailbox #(transaction) gen2driv, int tx_count = 20);
    this.gen2driv = gen2driv;
    this.tx_count = tx_count;
  endfunction

  task main();
    $display("[GENERATOR] started (tx_count=%0d)", tx_count);

    repeat (tx_count) begin
      tx = new();

      // Assign burst id BEFORE randomize/put
      tx.burst_id = id++;

      // Randomize the rest
      if (!tx.randomize()) begin
        $error("[GENERATOR] randomize FAILED for id=%0d", tx.burst_id);
      end

      // Transcript requirement print
      $display("[GENERATOR] id=%0d core=%0d op=%0h we=%0b read_en=%0b addr=%0d A=%0h B=%0h data=%0h",
               tx.burst_id, tx.core_id, tx.opcode, tx.we, tx.read_en, tx.addr, tx.A, tx.B, tx.data);

      // Send ORIGINAL object (preferred). If you want copy(), keep copy() but ensure it copies burst_id.
      gen2driv.put(tx);
    end

    $display("[GENERATOR] completed");
    -> ended;
  endtask

endclass
