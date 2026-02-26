`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
import mp_pkg::*;

module tb_top_uvm;

  
  // Clock
  
  bit clk;

  initial clk = 0;
  always #5 clk = ~clk;

  
  // Interface (same as MS2)
  
  intf vif(clk);

  
  // DUT (same mapping as MS2)
  
  mp_dut #(.AW(11), .DW(8)) dut (
    .clk(clk),
    .rst_n(vif.reset_n),

    .core_id(vif.core_id),
    .opcode(vif.opcode),
    .req(vif.req),
    .addr(vif.addr),
    .A(vif.A),
    .B(vif.B),
    .we(vif.we),

    .gnt(vif.gnt),

    .rvalid(vif.rvalid),
    .data_out(vif.data_out),
    .core_id_out(vif.core_id_out)
  );

  
  // Reset (ACTIVE LOW — same as MS2)
  
  initial begin
    vif.reset_n = 0;
    #20;
    vif.reset_n = 1;
  end

  initial begin
    uvm_config_db#(virtual intf)::set(null,"*","vif",vif);
    run_test("mp_test");
  end

endmodule
