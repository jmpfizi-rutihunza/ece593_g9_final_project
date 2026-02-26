class mp_scoreboard extends uvm_component;

  `uvm_component_utils(mp_scoreboard)

  // Streams
  uvm_tlm_analysis_fifo #(mp_seq_item) req_fifo;
  uvm_tlm_analysis_fifo #(mp_seq_item) rsp_fifo;

  // Per-core expected queues
  mp_seq_item exp_q[4][$];

  // Reference memory (MS2 parity)
  bit [7:0] ref_mem [2048];

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    req_fifo = new("req_fifo",this);
    rsp_fifo = new("rsp_fifo",this);

    // Initialize memory
    foreach(ref_mem[i]) ref_mem[i] = 0;
  endfunction

  task run_phase(uvm_phase phase);
    fork
      predict_loop();
      check_loop();
    join
  endtask


  // Prediction (reference model)

  task predict_loop();
    mp_seq_item tr;

    forever begin
      req_fifo.get(tr);

      case(tr.opcode)

        // Arithmetic
        4'b0001: tr.data_out = tr.A + tr.B;
        4'b0010: tr.data_out = tr.A & tr.B;
        4'b0011: tr.data_out = tr.A - tr.B;
        4'b0100: tr.data_out = tr.A * tr.B;

        // Memory
        4'b0101: tr.data_out = ref_mem[tr.addr];   // LOAD
        4'b0110: tr.data_out = tr.A;               // STORE

        // Shift
        4'b0111: tr.data_out = tr.A >> 1;
        4'b1000: tr.data_out = tr.A << 1;

        // Special ops (MS2 parity)
        4'b1001: tr.data_out = (tr.A * tr.B) - tr.A;
        4'b1010: tr.data_out = (tr.A * 4 * tr.B) - tr.A;
        4'b1011: tr.data_out = (tr.A * tr.B) + tr.A;
        4'b1100: tr.data_out = (tr.A * 3);
        4'b1101: tr.data_out = (tr.A * tr.B) + tr.B;

        default: tr.data_out = 0;

      endcase

      exp_q[tr.core_id].push_back(tr);

      `uvm_info("SCB","Prediction stored",UVM_HIGH)
    end
  endtask


  // Checking

  task check_loop();
    mp_seq_item act,exp;

    forever begin
      rsp_fifo.get(act);

      if(exp_q[act.core_id].size()==0) begin
        `uvm_error("SCB","Unexpected response")
        continue;
      end

      exp = exp_q[act.core_id].pop_front();

      if(act.data_out !== exp.data_out) begin
        `uvm_error("SCB",
          $sformatf("Mismatch core=%0d exp=%0h act=%0h",
          act.core_id, exp.data_out, act.data_out))
      end
      else begin
        `uvm_info("SCB","Match",UVM_LOW)
      end

      // Update reference memory on STORE

      if(act.opcode == 4'b0110) begin
        ref_mem[act.addr] = act.data_out;
      end
    end
  endtask

endclass
