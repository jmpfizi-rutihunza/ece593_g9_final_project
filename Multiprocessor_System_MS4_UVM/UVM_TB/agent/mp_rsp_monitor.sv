class mp_rsp_monitor extends uvm_monitor;

  `uvm_component_utils(mp_rsp_monitor)

  virtual intf vif;
  uvm_analysis_port #(mp_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name,parent);
    ap = new("ap",this);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))
      `uvm_fatal("RSP_MON","No vif")
  endfunction

  task run_phase(uvm_phase phase);
    mp_seq_item tr;

    forever begin
      @(posedge vif.clk);

      if(vif.rvalid) begin
        tr = mp_seq_item::type_id::create("tr");

        tr.core_id  = vif.core_id_out;
        tr.data_out = vif.data_out;
        tr.rvalid   = 1;

        ap.write(tr);

        `uvm_info("RSP_MON","Captured response",UVM_HIGH)
      end
    end
  endtask

endclass
