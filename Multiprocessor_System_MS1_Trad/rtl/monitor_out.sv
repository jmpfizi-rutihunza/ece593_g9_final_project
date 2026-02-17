class monitor_out; // Triggers on valid_out
  virtual intf.mon vif;
  mailbox #(transaction) mbox;   // sends response transactions to scoreboard

  function new(virtual intf.mon vif, mailbox #(transaction) mbox);
    this.vif  = vif; //Receives the interface handle so the monitor can observe DUT pins
    this.mbox = mbox; //Receives the mailbox handle so the monitor can send transactions to the scoreboard
  endfunction

  task run();
    forever begin
      @(vif.mon_cb); //wait for sampling point (posedge clk + #1step) so signals are sampled just after the clock edge to avoid race conditions.


      if (vif.mon_cb.valid_out) begin //      // Capture only when DUT output is valid
        transaction tr = new();  // new snapshot each time
// Copy output-side interface signals into the transaction; this converts signals into transactiona.
        tr.data_out  = vif.mon_cb.data_out;
        tr.valid_out = vif.mon_cb.valid_out;
        $display("[moniot_out] data_out=%0h valid_out=%0b",tr.data_out, tr.valid_out);
        mbox.put(tr); // Send the captured transaction to the scoreboard via mailbox.
      end
    end
  endtask
endclass
