import uvm_pkg::*;
`include "uvm_macros.svh"

class mp_test extends uvm_test;

  `uvm_component_utils(mp_test)

  // Environment
  
  mp_env env;

  // Constructor
  
  function new(string name="mp_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  // Build phase

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = mp_env::type_id::create("env", this);
  endfunction

  // Run phase (starts stimulus)

task run_phase(uvm_phase phase);

  phase.raise_objection(this);

  fork
    predict_loop();
    check_loop();
  join_none

  // allow simulation to run
  wait(0);

  phase.drop_objection(this);

endtask

endclass
