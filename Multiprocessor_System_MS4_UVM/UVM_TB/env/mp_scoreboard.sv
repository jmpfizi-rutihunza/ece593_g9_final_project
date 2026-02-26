class mp_scoreboard extends uvm_component;

  `uvm_component_utils(mp_scoreboard)

  uvm_tlm_analysis_fifo #(mp_seq_item) req_fifo;
  uvm_tlm_analysis_fifo #(mp_seq_item) rsp_fifo;

  mp_seq_item exp_q[4][$];

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    req_fifo = new("req_fifo",this);
    rsp_fifo = new("rsp_fifo",this);
  endfunction

  task run_phase(uvm_phase phase);
    fork
      predict_loop();
      check_loop();
    join
  endtask

  // Reference model (MS2 logic reused)

  task predict_loop();
    mp_seq_item tr;

    forever begin
      req_fifo.get(tr);

      case(tr.opcode)
        4'b0001: tr.data_out = tr.A + tr.B;
        4'b0011: tr.data_out = tr.A - tr.B;
        4'b0100: tr.data_out = tr.A * tr.B;
        4'b0010: tr.data_out = tr.A & tr.B;
        4'b0111: tr.data_out = tr.A >> 1;
        4'b1000: tr.data_out = tr.A << 1;
        default: tr.data_out = 0;
      endcase

      exp_q[tr.core_id].push_back(tr);

      `uvm_info("SCB","Prediction stored",UVM_HIGH)
    end
  endtask
  
  task check_loop();
    mp_seq_item act,exp;

    forever begin
      rsp_fifo.get(act);

      if(exp_q[act.core_id].size()==0) begin
        `uvm_error("SCB","Unexpected response")
        continue;
      end

      exp = exp_q[act.core_id].pop_front();

      if(act.data_out !== exp.data_out)
        `uvm_error("SCB","Mismatch detected")
      else
        `uvm_info("SCB","Match",UVM_LOW)
    end
  endtask

endclass
