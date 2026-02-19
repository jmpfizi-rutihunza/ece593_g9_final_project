`ifndef MONITOR_IN_SV
`define MONITOR_IN_SV

class monitor_in;

   virtual intf vif;
   mailbox #(transaction) mon2sb;
   coverage_collector cov;

   function new(virtual intf vif,
                mailbox #(transaction) mon2sb,
                coverage_collector cov);
      this.vif   = vif;
      this.mon2sb = mon2sb;
      this.cov   = cov;
   endfunction


   task run();
      transaction tx;

      forever begin
         // sample on monitor clocking block edge
         @(vif.mon_cb);

         // Only sample real requests (important for correct coverage)
         if (vif.mon_cb.req) begin
            tx = new();

            // IMPORTANT: use core_id (the TB drives this)
            // Do NOT use core_id_out unless your covergroup was built for it
            tx.core_id = vif.mon_cb.core_id;
            tx.opcode  = vif.mon_cb.opcode;
            tx.addr    = vif.mon_cb.addr;

            tx.A       = vif.mon_cb.A;
            tx.B       = vif.mon_cb.B;

            // sample functional coverage immediately after capture
            cov.sample(tx);

            // send to scoreboard
            mon2sb.put(tx);
         end
      end
   endtask

endclass

`endif

