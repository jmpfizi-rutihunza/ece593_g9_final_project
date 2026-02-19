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

    forever begin
      gen2driv.get(tx);

      // Drive request + fields on next clock
      @(vif.drv_cb);

      vif.drv_cb.core_id <= tx.core_id;
      vif.drv_cb.opcode  <= tx.opcode;     // trace/coverage only
      vif.drv_cb.addr    <= tx.addr;
      vif.drv_cb.data_in <= tx.data;

      // IMPORTANT: drive we/read_en from transaction (not opcode)
      vif.drv_cb.we      <= tx.we;
      vif.drv_cb.read_en <= tx.read_en;

      // Assert req
      vif.drv_cb.req     <= 1'b1;

      $display("[DRV] core=%0d op=%0h addr=%0d we=%0b rd=%0b data_in=%0h",
               tx.core_id, tx.opcode, tx.addr, tx.we, tx.read_en, tx.data);

      // Wait for grant (gnt is combinational from req in this DUT)
      wait (vif.drv_cb.gnt === 1'b1);

      // Keep signals stable until response is observed (1-cycle response DUT)
      // This makes monitor_out capture correct core/op/addr context.
      do begin
        @(vif.drv_cb);
      end while (vif.drv_cb.rvalid !== 1'b1);

      $display("[DRV] rvalid seen: core=%0d addr=%0d data_out=%0h",
               tx.core_id, tx.addr, vif.drv_cb.data_out);

      // Deassert after response
      @(vif.drv_cb);
      vif.drv_cb.req     <= 1'b0;
      vif.drv_cb.we      <= 1'b0;
      vif.drv_cb.read_en <= 1'b0;

    end
  endtask

endclass
