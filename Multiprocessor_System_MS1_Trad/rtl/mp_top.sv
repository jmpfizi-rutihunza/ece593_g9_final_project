module mp_top #(
  parameter int AW = 11,
  parameter int DW = 8
)(
  input  logic clk,
  input  logic rst_n,
  output logic [2:0] core_done,
  output logic [2:0] core_pass
);

  // Generator bus signals
  logic [2:0]           req, we;
  logic [2:0][AW-1:0]   addr;
  logic [2:0][DW-1:0]   wdata;
  logic [2:0]           gnt;

  // PER-CORE read responses (fixes your core_pass issue)
  logic [2:0]           rvalid_i;
  logic [2:0][DW-1:0]   rdata_i;

  // ----------------------------
  // Rotating grant (simple RR stub)
  // Grants core0 -> core1 -> core2 -> repeat
  // ----------------------------
  logic [1:0] rr;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) rr <= 2'd0;
    else        rr <= rr + 2'd1;
  end

  always_comb begin
    gnt = 3'b000;
    case (rr)
      2'd0: gnt = 3'b001;      // core0
      2'd1: gnt = 3'b010;      // core1
      default: gnt = 3'b100;   // core2
    endcase
  end

  // ----------------------------
  // Per-core response:
  // ONLY the granted core sees rvalid=1 and its own rdata.
  // Stubbed: return that core's wdata.
  // ----------------------------
  always_comb begin
    rvalid_i = 3'b000;
    rdata_i  = '{default:'0};

    if (gnt[0]) begin
      rvalid_i[0] = 1'b1;
      rdata_i[0]  = wdata[0];
    end else if (gnt[1]) begin
      rvalid_i[1] = 1'b1;
      rdata_i[1]  = wdata[1];
    end else if (gnt[2]) begin
      rvalid_i[2] = 1'b1;
      rdata_i[2]  = wdata[2];
    end
  end

  // ----------------------------
  // 3 Generator instances
  // ----------------------------
  generator #(.CORE_ID(0), .AW(AW), .DW(DW)) gen0 (
    .clk(clk), .rst_n(rst_n),
    .req(req[0]), .we(we[0]), .addr(addr[0]), .wdata(wdata[0]),
    .gnt(gnt[0]),
    .rvalid(rvalid_i[0]), .rdata(rdata_i[0]),
    .done(core_done[0]), .pass(core_pass[0])
  );

  generator #(.CORE_ID(1), .AW(AW), .DW(DW)) gen1 (
    .clk(clk), .rst_n(rst_n),
    .req(req[1]), .we(we[1]), .addr(addr[1]), .wdata(wdata[1]),
    .gnt(gnt[1]),
    .rvalid(rvalid_i[1]), .rdata(rdata_i[1]),
    .done(core_done[1]), .pass(core_pass[1])
  );

  generator #(.CORE_ID(2), .AW(AW), .DW(DW)) gen2 (
    .clk(clk), .rst_n(rst_n),
    .req(req[2]), .we(we[2]), .addr(addr[2]), .wdata(wdata[2]),
    .gnt(gnt[2]),
    .rvalid(rvalid_i[2]), .rdata(rdata_i[2]),
    .done(core_done[2]), .pass(core_pass[2])
  );

endmodule

