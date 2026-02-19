`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV

import tb_pkg::*;

`include "generator.sv"
`include "driver.sv"
`include "monitor_in.sv"
`include "monitor_out.sv"
`include "scoreboard.sv"

class environment;

 
   generator    gen;
   driver       driv;
   monitor_in   mon_in;
   monitor_out  mon_out;
   scoreboard   scb;

   
   mailbox #(transaction) gen2driv;
   mailbox #(transaction) mon_in2scb;
   mailbox #(transaction) mon_out2scb;

   virtual intf vif;

  
   coverage_collector cov;

   
   function new(virtual intf vif);
      this.vif = vif;

      // Mailbox instances
      gen2driv    = new();
      mon_in2scb  = new();
      mon_out2scb = new();

     
      cov = new();

      
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

  
   task post_test();

      wait(gen.ended.triggered);

      wait(gen2driv.num() == 0);
      
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


