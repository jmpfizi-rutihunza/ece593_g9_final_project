//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

class generator;

  // Mailbox to driver
  mailbox #(transaction) gen2driv;

  // Optional legacy count (not used now but kept)
  int tx_count;

  // End event
  event ended;

  static int id = 0;

  function new(mailbox #(transaction) gen2driv, int tx_count = 20);
    this.gen2driv = gen2driv;
    this.tx_count = tx_count;
  endfunction

  //------------------------------------------------
  // Main stimulus task
  //------------------------------------------------
  task main();

    transaction tx;

    $display("[GEN] Starting directed coverage sweep...");

    // ---------- Directed sweep (guarantees functional coverage) ----------
    for (int c = 0; c < 4; c++) begin
      for (int op = 0; op <= 4'hD; op++) begin
        for (int w = 0; w < 2; w++) begin

          tx = new();

          tx.core_id = c;
          tx.opcode  = op;
          tx.we      = w;
          tx.read_en = ~w;

          tx.addr = $urandom_range(0,2047);
          tx.data = $urandom;

          tx.display();

          gen2driv.put(tx);
        end
      end
    end

    $display("[GEN] Directed sweep completed.");

    // ---------- Random closure phase (improves code coverage) ----------
    $display("[GEN] Starting random closure phase...");

    repeat (200) begin
      tx = new();

      assert(tx.randomize() with {
        addr inside {[0:10], [2037:2047]}; // edge bias
      });

      tx.display();

      gen2driv.put(tx);
    end

    $display("[GEN] Random phase completed.");

    -> ended;

  endtask

endclass
