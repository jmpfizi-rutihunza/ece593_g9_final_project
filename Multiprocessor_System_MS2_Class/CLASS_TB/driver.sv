//////////////////////////////////////////////////
//  ECE-593 Project                              //
//  Multiprocessor System                        //
//  Milestone2 - class based verification        //
//  Prepared by Frezewd Debebe                   //
//////////////////////////////////////////////////

class driver;

  mailbox gen2driv;
  virtual intf.drv vif;

  function new(mailbox gen2driv, virtual intf.drv vif);
    this.gen2driv = gen2driv;
    this.vif      = vif;
  endfunction

  // Reset
  task reset();
    $display("[DRV] Reset started");
    vif.drv_cb.reset_n <= 1'b0;

    // idle defaults
    vif.drv_cb.req     <= 1'b0;
    vif.drv_cb.we      <= 1'b0;
    vif.drv_cb.read_en <= 1'b0;
    vif.drv_cb.addr    <= '0;
    vif.drv_cb.data_in <= '0;
    vif.drv_cb.core_id <= '0;
    vif.drv_cb.opcode  <= '0;

    repeat (5) @(vif.drv_cb);
    vif.drv_cb.reset_n <= 1'b1;
    $display("[DRV] Reset completed");
  endtask

  task main();
    transaction tx;

    // Do reset once at start
    reset();

    forever begin
      gen2driv.get(tx);

      @(vif.drv_cb);

      // Drive request signals
      vif.drv_cb.core_id <= tx.core_id;
      vif.drv_cb.opcode  <= tx.opcode;
      vif.drv_cb.addr    <= tx.addr;
      vif.drv_cb.req     <= 1'b1;

      // Defaults each transaction
      vif.drv_cb.we      <= 1'b0;
      vif.drv_cb.read_en <= 1'b0;
      vif.drv_cb.data_in <= tx.data;

      $display("[DRIVER] id=%0d core=%0d op=%0h addr=%0d data=%0h",
               tx.burst_id, tx.core_id, tx.opcode, tx.addr, tx.data);

      // Wait for grant
      wait (vif.drv_cb.gnt === 1'b1);

      // Example decode:
      // STORE opcode = 4'b0110  -> write
      // otherwise -> read (or no-write)
      if (tx.opcode == 4'b0110) begin
        vif.drv_cb.we      <= 1'b1;
        vif.drv_cb.read_en <= 1'b0;
        $display("[DRIVER] WRITE id=%0d addr=%0d data=%0h", tx.burst_id, tx.addr, tx.data);
      end
      else begin
        vif.drv_cb.we      <= 1'b0;
        vif.drv_cb.read_en <= 1'b1;
        $display("[DRIVER] READ  id=%0d addr=%0d", tx.burst_id, tx.addr);
      end

      // Hold one cycle
      @(vif.drv_cb);

      // Deassert
      vif.drv_cb.req     <= 1'b0;
      vif.drv_cb.we      <= 1'b0;
      vif.drv_cb.read_en <= 1'b0;

      $display("[DRV] Finished Core %0d transaction at %0t", tx.core_id, $time);
    end
  endtask

endclass
