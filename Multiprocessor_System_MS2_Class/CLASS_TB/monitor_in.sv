//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Janvier Mpfizi Rutihunza		//
//////////////////////////////////////////////////
class monitor_in; // triggers on we or read_en (input-side activity)
  virtual intf.mon vif;
  mailbox #(transaction) mbox; // The monitor puts transactions in this mailbox; the scoreboard reads them out.

  function new(virtual intf.mon vif, mailbox #(transaction) mbox);
    this.vif  = vif; //Receives the interface handle so the monitor can observe DUT pins
    this.mbox = mbox; //Receives the mailbox handle so the monitor can send transactions to the scoreboard
  endfunction

  task run();
    $display("monitor_in started");
    forever begin
      @(vif.mon_cb); // wait for sampling point (posedge clk + #1step) so signals are sampled just after the clock edge to avoid race conditions.  

		// Trigger only when there is an input transaction: we=1 indicates a write request, read_en=1 indicates a read request
      if (vif.mon_cb.we || vif.mon_cb.read_en) begin
      transaction tr = new(); // create only when capturing an input transaction
   // Copy input-side interface signals into the transaction; this converts signals into transactiona.
        tr.core_id = vif.mon_cb.core_id;
		tr.opcode  = vif.mon_cb.opcode;
		tr.addr    = vif.mon_cb.addr;
        tr.data_in = vif.mon_cb.data_in;
        tr.we     = vif.mon_cb.we;
        tr.read_en = vif.mon_cb.read_en;
        tr.reset_n = vif.mon_cb.reset_n;

        $display("[moniot_in] addr=%0d we=%0b read_en=%0b data_in=%0h reset_n=%0b",
        tr.addr, tr.we, tr.read_en, tr.data_in, tr.reset_n);

        mbox.put(tr); //Send the captured request transaction to the scoreboard.
      end
    end
  endtask

endclass
