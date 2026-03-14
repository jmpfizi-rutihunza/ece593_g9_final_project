// ==============================================================
//  ECE-593 Group 9 — Milestone 5
//  mp_pkg.sv — UVM package (flat include, matches UVM_TB/ layout)
// ==============================================================

package mp_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "sequence_item.sv"
    `include "sequencer.sv"
    `include "sequence.sv"
    `include "driver.sv"
    `include "monitor.sv"
    `include "scoreboard.sv"
    `include "coverage.sv"
    `include "agent.sv"
    `include "env.sv"
    `include "test.sv"
    `include "bug_tests.sv"

endpackage
