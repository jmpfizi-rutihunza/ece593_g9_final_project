//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////


class environment;

  // components
  generator    gen;
  driver       driv;
  monitor_in   mon_in;
  monitor_out  mon_out;
  scoreboard   scb;

  // mailboxes
  mailbox gen2driv;

  // input mailbox bridge: monitor -> env -> scoreboard
  mailbox #(transaction) mon_in2env;
  mailbox #(transaction) mon_in2scb;

  // output mailbox directly monitor -> scoreboard
  mailbox #(transaction) mon_out2scb;

  virtual intf vif;

  // functional coverage
  coverage cov;

  function new(virtual intf vif);
    this.vif = vif;

    // Mailboxes
    gen2driv    = new();
    mon_in2env  = new();
    mon_in2scb  = new();
    mon_out2scb = new();

    // Coverage
    cov = new();

    // Components
    gen     = new(gen2driv);
    driv    = new(gen2driv, vif.drv);

    // NOTE: monitor constructors are (vif, mailbox)
    mon_in  = new(vif.mon, mon_in2env);
    mon_out = new(vif.mon, mon_out2scb);

    // Scoreboard consumes env->scb input mailbox + output mailbox
    scb     = new(mon_in2scb, mon_out2scb);
  endfunction

  task pre_test();
    $display("[ENV] Resetting...");
    driv.reset();
  endtask

  task test();
    $display("[ENV] Starting Test Execution...");
    fork
      gen.main();
      driv.main();
      mon_in.run();
      mon_out.run();
      scb.run();

      // Coverage bridge: take each input transaction once, sample, then forward to scoreboard
      forever begin
        transaction tr;
        mon_in2env.get(tr);
        cov.sample(tr);
        mon_in2scb.put(tr);
      end
    join_any
  endtask

  task post_test();
    // Wait until generator ends
    wait(gen.ended.triggered);
    repeat (50) @(vif.mon_cb);

    $display("[ENV] --- All Transactions Verified ---");
    $display("[ENV] Time: %0t", $time);
    $finish;
  endtask

  task run();
    pre_test();
    test();
    post_test();
  endtask

endclass
