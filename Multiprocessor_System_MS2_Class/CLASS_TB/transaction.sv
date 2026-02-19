//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////

class transaction;

  // Optional tag (TB may drive/ignore)
  rand int unsigned burst_id;

  // Request fields
  rand bit [1:0]  core_id;     // 4 cores: 0..3
  rand bit [3:0]  opcode;      // kept for coverage/trace (DUT ignores)
  rand bit [10:0] addr;        // 2KB memory: 0..2047

  // Control
  rand bit        we;          // 1=write, 0=read
  rand bit        read_en;      // recommended: read_en == ~we

  bit             req;
  bit             gnt;
  bit             rvalid;

  // Data
  rand bit [7:0]  A;           // not used by DUT, but ok for coverage/trace
  rand bit [7:0]  B;           // not used by DUT, but ok for coverage/trace
  rand bit [7:0]  data;        // for write: data_in; for read: can be don't-care

  bit [7:0]       expected_val;

  // For monitors (compile fix: monitor_in assigns reset_n)
  bit             reset_n;

  // Constraints
  constraint c_addr      { addr < 2048; }
  constraint c_opcode    { opcode inside {[4'h0 : 4'hD]}; } // 0..D
  constraint c_rdwr_cons { read_en == ~we; }

  function void display();
    $display("T=%0t core=%0d op=%0h addr=%0d we=%0b rd=%0b data=%0h",
             $time, core_id, opcode, addr, we, read_en, data);
  endfunction

  function transaction copy();
    transaction c = new();
    c.burst_id      = this.burst_id;
    c.core_id       = this.core_id;
    c.opcode        = this.opcode;
    c.addr          = this.addr;
    c.we            = this.we;
    c.read_en       = this.read_en;
    c.req           = this.req;
    c.gnt           = this.gnt;
    c.rvalid        = this.rvalid;
    c.A             = this.A;
    c.B             = this.B;
    c.data          = this.data;
    c.expected_val  = this.expected_val;
    c.reset_n       = this.reset_n;
    return c;
  endfunction

endclass
