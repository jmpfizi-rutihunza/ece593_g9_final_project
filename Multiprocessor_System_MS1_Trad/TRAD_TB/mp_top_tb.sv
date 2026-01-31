`timescale 1ns/1ps

module mp_top_tb;

  logic clk, rst_n;
  logic [2:0] core_done, core_pass;
  int cycles;

  mp_top dut (
    .clk(clk),
    .rst_n(rst_n),
    .core_done(core_done),
    .core_pass(core_pass)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk; // 100 MHz

  initial begin
    cycles = 0;

    rst_n = 1'b0;
    repeat (5) @(posedge clk);
    rst_n = 1'b1;

    while (cycles < 400) begin
      @(posedge clk);
      cycles++;

      if (&core_done) begin
        $display("DONE in %0d cycles", cycles);
        $display("core_done=%b core_pass=%b", core_done, core_pass);

        if (&core_pass)
          $display("PASS: All generators finished and passed.");
        else
          $display("FAIL: One or more generators failed.");

        $finish;
      end
    end

    $display("FAIL: Timeout. core_done=%b core_pass=%b", core_done, core_pass);
    $finish;
  end

endmodule

