module generator #(
  parameter int CORE_ID = 0,
  parameter int AW      = 11,  // 2KB memory -> 0..2047
  parameter int DW      = 8
)(
  input  logic          clk,
  input  logic          rst_n,

  // Bus request interface
  output logic          req,
  output logic          we,
  output logic [AW-1:0] addr,
  output logic [DW-1:0] wdata,
  input  logic          gnt,

  // Read response (PER-CORE channel is driven by mp_top)
  input  logic          rvalid,
  input  logic [DW-1:0] rdata,

  // Status
  output logic          done,
  output logic          pass
);

  logic [AW-1:0] my_addr;
  logic [DW-1:0] my_data;

  assign my_addr = 11'h040 + logic'(CORE_ID);
  assign my_data = 8'hA0    + logic'(CORE_ID);

  typedef enum logic [2:0] {
    IDLE,
    WRITE_REQ,
    WRITE_WAIT,
    READ_REQ,
    READ_WAIT,
    DONE
  } state_t;

  state_t state, next_state;
  logic [DW-1:0] read_back;

  always_comb begin
    req  = 1'b0;
    we   = 1'b0;
    addr = my_addr;
    wdata= my_data;
    done = 1'b0;
    pass = 1'b0;
    next_state = state;

    case (state)
      IDLE: next_state = WRITE_REQ;

      WRITE_REQ: begin
        req = 1'b1; we = 1'b1;
        next_state = WRITE_WAIT;
      end

      WRITE_WAIT: begin
        req = 1'b1; we = 1'b1;
        if (gnt) next_state = READ_REQ;
      end

      READ_REQ: begin
        req = 1'b1; we = 1'b0;
        next_state = READ_WAIT;
      end

      READ_WAIT: begin
        req = 1'b1; we = 1'b0;
        if (gnt && rvalid) next_state = DONE;
      end

      DONE: begin
        done = 1'b1;
        pass = (read_back == my_data);
        next_state = DONE;
      end

      default: next_state = IDLE;
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      read_back <= '0;
    end else begin
      state <= next_state;
      if (rvalid) read_back <= rdata;
    end
  end

endmodule

