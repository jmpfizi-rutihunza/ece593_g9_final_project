//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Janvier Mpfizi Rutihunza		//
//////////////////////////////////////////////////
interface intf(input logic clk);
  parameter ADDR_WIDTH = 11;
  parameter DATA_WIDTH = 8;
  logic reset_n;
  logic read_en;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic [ADDR_WIDTH-1:0] addr;
  logic we;
  logic rvalid;
  
  	logic [1:0] core_id;
	logic [3:0] opcode;
	logic req;
	logic gnt;

  // Driver clocking block (TB drives DUT inputs)
  clocking drv_cb @(posedge clk);
    default input #1step output #1step;
    output data_in;
    output addr;
    output we;
    output read_en;
    output reset_n;
    input  data_out;
    input  rvalid;
  endclocking

  // this Clocking Block will be used by the MONITOR to observe activity in a race-free way.
  // Monitor samples both DUT inputs and DUT outputs
  clocking mon_cb @(posedge clk);
    default input #1step; // add a small delay between clocks
    input data_in;
    input addr;
    input we;;
    input read_en;
    input reset_n;
    input data_out;
    input rvalid;
  endclocking
  
  /*organize access to an interface, preventing components from accidentally driving or reading the wrong signals.
  Modports restrict what a component can access, so:
  the driver only sees drv_cb
 the monitor only sees mon_cb */
 
	modport drv (clocking drv_cb);
	modport mon (clocking mon_cb);

endinterface




