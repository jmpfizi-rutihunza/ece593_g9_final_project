package mp_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "seq/mp_seq_item.sv"
  `include "seq/mp_sequence.sv"

  `include "agent/mp_driver.sv"
  `include "agent/mp_req_monitor.sv"
  `include "agent/mp_rsp_monitor.sv"
  `include "agent/mp_agent.sv"

  `include "env/mp_scoreboard.sv"
  `include "env/mp_env.sv"

  `include "test/mp_test.sv"

endpackage
