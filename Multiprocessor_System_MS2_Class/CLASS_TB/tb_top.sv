////////////////////////////////////////////////////////////
// tb_top.sv
// Top-level testbench
////////////////////////////////////////////////////////////

`timescale 1ns/1ps

`include "intf.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor_in.sv"
`include "monitor_out.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "environment.sv"

module tb_top;

  bit clk;
  bit rst_n;

  // clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // reset
  initial begin
    rst_n = 0;
    #20;
    rst_n = 1;
  end

  // interface instance
  intf vif(clk);

  // connect reset
  assign vif.reset_n = rst_n;

  // DUT instance (replace dut_stub with your real DUT)
  dut_stub dut (
    .clk       (clk),
    .reset_n   (vif.reset_n),
    .core_id   (vif.core_id),
    .opcode    (vif.opcode),
    .addr      (vif.addr),
    .data_in   (vif.data_in),
    .data_out  (vif.data_out),
    .req       (vif.req),
    .gnt       (vif.gnt),
    .we        (vif.we),
    .rvalid    (vif.rvalid),
    .burst_id  (vif.burst_id)
  );

  environment env;

  initial begin
    env = new(vif);
    env.gen.tx_count = 20;   // required 15–20 transactions
    env.run();
    #100;
    $finish;
  end

endmodule
