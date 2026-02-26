class mp_req_monitor extends uvm_monitor;

  `uvm_component_utils(mp_req_monitor)

  virtual intf vif;
  uvm_analysis_port #(mp_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name,parent);
    ap = new("ap",this);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))
      `uvm_fatal("REQ_MON","No vif")
  endfunction

  task run_phase(uvm_phase phase);
    mp_seq_item tr;

    forever begin
      @(posedge vif.clk);

      if(vif.req) begin
        tr = mp_seq_item::type_id::create("tr");

        tr.core_id = vif.core_id;
        tr.opcode  = vif.opcode;
        tr.addr    = vif.addr;
        tr.A       = vif.A;
        tr.B       = vif.B;

        ap.write(tr);

        `uvm_info("REQ_MON","Captured request",UVM_HIGH)
      end
    end
  endtask

endclass
