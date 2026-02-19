//////////////////////////////////////////////////
//  ECE-593 Project                              //
//  Multiprocessor System                        //
//  Milestone2 - class based verification        //
//////////////////////////////////////////////////

`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV

import tb_pkg::*;

// TB classes are included here (include-based flow)
`include "generator.sv"
`include "driver.sv"
`include "monitor_in.sv"
`include "monitor_out.sv"
`include "scoreboard.sv"

class environment;

   // components
   generator    gen;
   driver       driv;
   monitor_in   mon_in;
   monitor_out  mon_out;
   scoreboard   scb;

   // mailboxes
   mailbox #(transaction) gen2driv;
   mailbox #(transaction) mon_in2scb;
   mailbox #(transaction) mon_out2scb;

   virtual intf vif;

   // functional coverage handler
   coverage_collector cov;

   // constructor
   function new(virtual intf vif);
      this.vif = vif;

      // Mailbox instances
      gen2driv    = new();
      mon_in2scb  = new();
      mon_out2scb = new();

      // Coverage collector instance
      cov = new();

      // Instantiate components
      gen     = new(gen2driv);
      driv    = new(gen2driv, vif, gen);
      mon_in  = new(vif, mon_in2scb, cov);
      mon_out = new(vif, mon_out2scb);
      scb     = new(mon_in2scb, mon_out2scb);
   endfunction


   task pre_test();
      $display("[ENV] Resetting");
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
      join_none
   endtask


   // ✅ FIXED: wait until mailbox is drained so directed tx reach monitor/coverage
   task post_test();
      // Wait until generator is done producing transactions
      wait(gen.ended.triggered);

      // Wait until the driver has consumed everything from generator mailbox
      wait(gen2driv.num() == 0);

      // Give monitors a few cycles to sample the last transaction
      repeat(20) @(vif.mon_cb);

      $display("[ENV] --- All Transactions Driven/Monitored ---");
      $display("[ENV] Time: %0t", $time);
      $finish;
   endtask


   task run();
      pre_test();
      test();
      post_test();
   endtask

endclass

`endif
