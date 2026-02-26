//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone4 - class based verification	//
//	Prepared by Janvier Mpfizi Rutihunza	//
//////////////////////////////////////////////////

// Base sequence type for this environment.
// Parameterizing with #(my_sequence_item) tells UVM what item type this sequence will generate.

class my_sequence extends uvm_sequence #(my_sequence_item);

  // Factory registration for sequences 
  `uvm_object_utils(my_sequence)

  function new(string name = "my_sequence");
    super.new(name);
  endfunction

endclass


// reset_sequence: sends ONE transaction that asserts reset.
//reset_n == 0 means reset asserted (active-low).
class reset_sequence extends my_sequence;

  `uvm_object_utils(reset_sequence)

  // Handle to the item we will generate
  my_sequence_item tx;

  function new(string name="reset_sequence");
    super.new(name);
  endfunction

  // body() is what runs when you call seq.start(sequencer)
  virtual task body();

    // Create item via factory (enables overrides)
    tx = my_sequence_item::type_id::create("tx");

    // start_item/finish_item is the handshake with the sequencer/driver
    start_item(tx);

    // Randomize item, but force reset asserted and no read/write
    assert (tx.randomize() with { reset_n == 0; we == 0; read_en == 0; })
      else $error("randomization failed (reset_sequence)");

    finish_item(tx);
  endtask

endclass


// read_sequence: generates read transactions.
class read_sequence extends my_sequence;

  `uvm_object_utils(read_sequence)

  my_sequence_item tx;
  int unsigned num_transactions = 500;

  function new (string name = "read_sequence");
    super.new(name);
  endfunction

  // Helper task to generate one read transaction
  task gen_tx();
    tx = my_sequence_item::type_id::create("tx");
    start_item(tx);

    // Force: out of reset, read enabled, write disabled
    assert (tx.randomize() with { reset_n == 1; we == 0; read_en == 1; })
      else $error("randomization failed (read_sequence)");

    finish_item(tx);
  endtask

  // body(): generate num_transactions items
  virtual task body();
    repeat(num_transactions) gen_tx();
  endtask

endclass


// write_sequence: generates N write transactions.
class write_sequence extends my_sequence;

  `uvm_object_utils(write_sequence)

  my_sequence_item tx;
  int unsigned num_transactions = 1000;

  function new (string name = "write_sequence");
    super.new(name);
  endfunction

  // Helper task to generate one write transaction
  task gen_tx();
    tx = my_sequence_item::type_id::create("tx");
    start_item(tx);

    // Force: out of reset, write enabled, read disabled
    assert (tx.randomize() with { reset_n == 1; we == 1; read_en == 0; })
      else $error("randomization failed (write_sequence)");

    finish_item(tx);
  endtask

  virtual task body();
    repeat(num_transactions) gen_tx();
  endtask

endclass


// write_read_sequence: alternates READ then WRITE then READ then WRITE...
class write_read_sequence extends my_sequence;

  `uvm_object_utils(write_read_sequence)

  my_sequence_item tx;
  int unsigned num_transactions = 8000;

  function new (string name = "write_read_sequence");
    super.new(name);
  endfunction

  // Generate one write item
  task gen_write();
    tx = my_sequence_item::type_id::create("tx");
    start_item(tx);
    assert (tx.randomize() with { reset_n == 1; we == 1; read_en == 0; })
      else $error("randomization failed (write_read_sequence write)");
    finish_item(tx);
  endtask

  // Generate one read item
  task gen_read();
    tx = my_sequence_item::type_id::create("tx");
    start_item(tx);
    assert (tx.randomize() with { reset_n == 1; we == 0; read_en == 1; })
      else $error("randomization failed (write_read_sequence read)");
    finish_item(tx);
  endtask

  // Main sequence: for i=0..N-1
  // even i -> read, odd i -> write
  virtual task body();
    for (int i = 0; i < num_transactions; i++) begin
      if (i % 2 == 0) gen_read();
      else            gen_write();
    end
  endtask

endclass