//////////////////////////////////////////////////
//  ECE-593 Project                              //
//  Multiprocessor System                        //
//  Milestone2 - class based verification        //
//  Prepared by Janvier Mpfizi Rutihunza         //
//////////////////////////////////////////////////

interface intf(input logic clk);
  parameter ADDR_WIDTH = 11;
  parameter DATA_WIDTH = 8;

  // DUT control/data
  logic reset_n;
  logic read_en;
  logic we;
  //logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] A;           // Changed from data_in
  logic [DATA_WIDTH-1:0] B;           // Added B
  logic [DATA_WIDTH-1:0] data_out;
  logic [ADDR_WIDTH-1:0] addr;
  logic rvalid;
  logic [1:0]            core_id_out;

  // Multiprocessor signals
  logic [1:0] core_id;
  logic [3:0] opcode;
  logic req;
  logic gnt;
  logic [31:0] burst_id;

  // Driver clocking block (TB drives DUT inputs)
  clocking drv_cb @(posedge clk);
    default input #1step output #1step;

    // TB -> DUT (outputs from TB POV)
    output reset_n;
    output read_en;
    output we;
    output addr;
    //output data_in;
    output A, B;

    output core_id;
    output opcode;
    output req;

    // DUT -> TB (inputs from TB POV)
    input  gnt;
    input  data_out;
    input  rvalid;
  endclocking

  // Monitor clocking block (TB observes activity)
  clocking mon_cb @(posedge clk);
    default input #1step;

    // Observe DUT inputs
    input reset_n;
    input read_en;
    input we;
    input addr;
    //input data_in;
    input A, B;

    input core_id;
    input opcode;
    input req;
    input core_id_out;

    // Observe DUT outputs
    input gnt;
    input data_out;
    input rvalid;
  endclocking

  // Modports
  modport drv (clocking drv_cb);
  modport mon (clocking mon_cb);

endinterface