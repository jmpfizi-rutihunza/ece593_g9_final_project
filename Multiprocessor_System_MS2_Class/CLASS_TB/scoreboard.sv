`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV



class scoreboard;

   mailbox #(transaction) mon_in2scb;
   mailbox #(transaction) mon_out2scb;

   function new(mailbox #(transaction) mon_in2scb,
                mailbox #(transaction) mon_out2scb);
      this.mon_in2scb  = mon_in2scb;
      this.mon_out2scb = mon_out2scb;
   endfunction

   task run();
      transaction in_tx, out_tx;

      forever begin
         mon_in2scb.get(in_tx);
         mon_out2scb.get(out_tx);

         if (out_tx.data !== in_tx.expected_val) begin
            $display("[SB] MISMATCH exp=%h got=%h",
                     in_tx.expected_val, out_tx.data);
         end
      end
   endtask

endclass

`endif


