class mp_driver extends uvm_driver #(mp_seq_item);

  `uvm_component_utils(mp_driver)

  virtual intf vif;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))
      `uvm_fatal("DRV","No vif")
  endfunction

  task run_phase(uvm_phase phase);
    mp_seq_item tr;

    forever begin
      seq_item_port.get_next_item(tr);

      @(posedge vif.clk);

      vif.req     <= 1;
      vif.core_id <= tr.core_id;
      vif.opcode  <= tr.opcode;
      vif.addr    <= tr.addr;
      vif.A       <= tr.A;
      vif.B       <= tr.B;
      vif.we      <= (tr.opcode==4'b0110);

      @(posedge vif.clk);
      vif.req <= 0;

      seq_item_port.item_done();

      `uvm_info("DRV",$sformatf("Sent opcode=%0b core=%0d",tr.opcode,tr.core_id),UVM_MEDIUM)
    end
  endtask

endclass
