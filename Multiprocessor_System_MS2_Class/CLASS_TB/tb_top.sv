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
  assign vif.reset_n  = rst_n;
  

  // REAL DUT instance
  mp_dut #(.AW(11), .DW(8)) dut (
    .clk      (clk),
    .rst_n    (vif.reset_n),

    .core_id  (vif.core_id),
    .opcode   (vif.opcode),
    .req      (vif.req),
    .gnt      (vif.gnt),
    .we       (vif.we),
    .addr     (vif.addr),
    .data_in  (vif.data_in),

    .rvalid   (vif.rvalid),
    .data_out (vif.data_out),

    .burst_id (vif.burst_id)
  );

  environment env;

  initial begin
    env = new(vif);
    env.gen.tx_count = 20;   // required 15–20 transactions
    env.run();
  end

endmodule
