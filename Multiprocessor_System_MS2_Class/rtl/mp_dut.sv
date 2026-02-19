////////////////////////////////////////////////////////////
// mp_dut.sv
// Milestone-2 DUT extracted from M1 "mp_top" concept:
// - NO internal generators
// - Exposes a simple request interface for class-based TB
// - Shared memory model (2^AW locations, DW bits wide)
// - One-cycle response: rvalid asserted 1 cycle after accepted req
////////////////////////////////////////////////////////////

module mp_dut #(
  parameter int AW = 11,
  parameter int DW = 8
)(
  input  logic            clk,
  input  logic            rst_n,

  // Request channel (from TB/driver)
  input  logic [1:0]      core_id,     // kept for coverage/trace; not required for function here
  input  logic [3:0]      opcode,      // kept for coverage/trace; not required for function here
  input  logic            req,
  output logic            gnt,
  input  logic            we,          // 1=write, 0=read
  input  logic [AW-1:0]   addr,
  input  logic [DW-1:0]   data_in,

  // Response channel (to TB/monitors)
  output logic            rvalid,
  output logic [DW-1:0]   data_out,

  // Optional transaction tag for debug/trace (TB can drive it)
  input  logic [31:0]     burst_id
);

  // Simple shared memory
  logic [DW-1:0] mem [0:(1<<AW)-1];

  // Pipeline registers for 1-cycle response
  logic          pend_valid;
  logic          pend_we;
  logic [AW-1:0] pend_addr;
  logic [DW-1:0] pend_wdata;

  // Always grant when req is high (single-request interface)
  // If you later support multi-core simultaneous requests, this becomes arbitration logic.
  always_comb begin
    gnt = req;
  end

  // Sequential behavior
  integer i;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rvalid     <= 1'b0;
      data_out   <= '0;

      pend_valid <= 1'b0;
      pend_we    <= 1'b0;
      pend_addr  <= '0;
      pend_wdata <= '0;

      // Optional: clear memory (not required, but avoids Xs in sim)
      for (i = 0; i < (1<<AW); i++) begin
        mem[i] <= '0;
      end
    end
    else begin
      // Default response low unless a pending transaction completes
      rvalid <= 1'b0;

      // Complete last cycle's accepted request
      if (pend_valid) begin
        if (pend_we) begin
          // For write, return the written data (simple ack)
          data_out <= pend_wdata;
        end
        else begin
          // For read, return memory content
          data_out <= mem[pend_addr];
        end
        rvalid <= 1'b1;
      end

      // Capture new request (if granted)
      pend_valid <= 1'b0;
      if (req && gnt) begin
        pend_valid <= 1'b1;
        pend_we    <= we;
        pend_addr  <= addr;
        pend_wdata <= data_in;

        // Write happens on accept (common simple bus behavior)
        if (we) begin
          mem[addr] <= data_in;
        end
      end
    end
  end

endmodule
