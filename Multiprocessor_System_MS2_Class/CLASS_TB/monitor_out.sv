//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Janvier Mpfizi Rutihunza		//
//////////////////////////////////////////////////
class monitor_out; // Triggers on rvalid
  virtual intf.mon vif;
  mailbox #(transaction) mbox;   // sends response transactions to scoreboard

  function new(virtual intf.mon vif, mailbox #(transaction) mbox);
    this.vif  = vif;
    this.mbox = mbox;
  endfunction

  task run();
    forever begin
      @(vif.mon_cb);

      // Capture only when DUT output is valid
      if (vif.mon_cb.rvalid) begin
        transaction tr = new();

        // Capture ID/context + actual output
        tr.core_id = vif.mon_cb.core_id;
        tr.opcode  = vif.mon_cb.opcode;
        tr.addr    = vif.mon_cb.addr;

        // Put DUT output into the same field the scoreboard checks
        tr.data    = vif.mon_cb.data_out;

        $display("[oMon] core=%0d op=%0h addr=%0d data_out=%0h rvalid=%0b",
                 tr.core_id, tr.opcode, tr.addr, tr.data, vif.mon_cb.rvalid);

        mbox.put(tr);
      end
    end
  endtask

endclass
