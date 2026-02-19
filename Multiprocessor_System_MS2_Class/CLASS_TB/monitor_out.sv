`ifndef MONITOR_OUT_SV
`define MONITOR_OUT_SV

class monitor_out;

   virtual intf vif;
   mailbox #(transaction) mon2sb;

   function new(virtual intf vif,
                mailbox #(transaction) mon2sb);
      this.vif   = vif;
      this.mon2sb = mon2sb;
   endfunction

   task run();
      transaction tx;

      forever begin
         tx = new();

        
         @(vif.mon_cb);

         tx.data   = vif.mon_cb.data_out;   // <-- FIXED
         tx.rvalid = vif.mon_cb.rvalid;
         tx.gnt    = vif.mon_cb.gnt;

         mon2sb.put(tx);
      end
   endtask

endclass

`endif

