`include "environment.sv"
`timescale 1ns/1ps

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

  // connect reset + burst tag
  //assign vif.reset_n  = rst_n;
  assign vif.burst_id = 32'd0;   // driver can override if you want

  // REAL DUT instance
 mp_dut #(.AW(11), .DW(8)) dut (
    .clk          (clk),
    .rst_n        (vif.reset_n),

    // Request signals
    .core_id      (vif.core_id),
    .opcode       (vif.opcode),
    .req          (vif.req),
    .addr         (vif.addr),
    .A            (vif.A),      
    .B            (vif.B),      
    .we           (vif.we),
    
    .gnt          (vif.gnt),

    // Response signals
    .rvalid       (vif.rvalid),
    .data_out     (vif.data_out),
    .core_id_out  (vif.core_id_out) // Added: essential for scoreboard
    
   
  );

  environment env;

  initial begin
    env = new(vif);
    env.gen.tx_count = 100;   
    env.run();
  end

endmodule
