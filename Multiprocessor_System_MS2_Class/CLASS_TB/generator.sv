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

  static int id = 0;

  function new(mailbox #(transaction) gen2driv, int tx_count = 20);
    this.gen2driv = gen2driv;
    this.tx_count = tx_count;
  endfunction

  task main();

  transaction tx;

  // Directed sweep → guarantees coverage
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

        gen2driv.put(tx);

      end
    end
  end

  // Random phase (important for code coverage)
  repeat (200) begin
    tx = new();
    assert(tx.randomize());
    gen2driv.put(tx);
  end

  -> ended;

endtask
