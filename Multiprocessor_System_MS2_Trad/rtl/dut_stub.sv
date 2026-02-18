////////////////////////////////////////////////////////////
// dut_stub.sv
// Simple memory-based RTL model for simulation only
////////////////////////////////////////////////////////////

module dut_stub (
  input  logic        clk,
  input  logic        reset_n,
  input  logic [1:0]  core_id,
  input  logic [3:0]  opcode,
  input  logic [10:0] addr,
  input  logic [31:0] data_in,
  output logic [31:0] data_out,
  input  logic        req,
  output logic        gnt,
  input  logic        we,
  output logic        rvalid,
  input  logic [31:0] burst_id
);

  logic [31:0] mem [0:2047];

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      gnt     <= 0;
      rvalid  <= 0;
      data_out<= 0;
    end
    else begin
      gnt <= req;

      if (req) begin
        if (we) begin
          mem[addr] <= data_in;
          data_out  <= data_in;
        end
        else begin
          data_out <= mem[addr];
        end
        rvalid <= 1;
      end
      else begin
        rvalid <= 0;
      end
    end
  end

endmodule
