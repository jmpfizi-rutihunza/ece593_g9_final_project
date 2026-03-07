//////////////////////////////////
//    ECE-593 Milestone 5
//    Bug Injection Testbench Top
//    QuestaSim 2025.2.1
//////////////////////////////////

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "interface.sv"
`include "sequence_item.sv"
`include "sequencer.sv"
`include "sequence.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "agent.sv"
`include "env.sv"
`include "test.sv"
`include "bug_tests.sv"

module tb_top;

    logic clk;
    logic rst_n;

    mp_intf intf(clk, rst_n);

    logic [1:0] selected_core;
    logic       dut_req;
    logic       dut_we;
    logic [1:0] dut_core_id;
    logic [3:0] dut_opcode;
    logic [10:0] dut_addr;
    logic [7:0] dut_A;
    logic [7:0] dut_B;

    // Round-Robin Arbiter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            selected_core <= 2'b00;
        end else begin
            if (intf.req[selected_core] == 1'b1)
                selected_core <= selected_core;
            else begin
                if (selected_core == 2'b11)
                    selected_core <= 2'b00;
                else
                    selected_core <= selected_core + 1'b1;
            end
        end
    end

    // MUX: select active core signals
    always_comb begin
        dut_core_id = selected_core;
        case(selected_core)
            2'b00: begin dut_req=intf.req[0]; dut_we=intf.we[0]; dut_opcode=intf.opcode[0]; dut_addr=intf.addr[0]; dut_A=intf.A[0]; dut_B=intf.B[0]; end
            2'b01: begin dut_req=intf.req[1]; dut_we=intf.we[1]; dut_opcode=intf.opcode[1]; dut_addr=intf.addr[1]; dut_A=intf.A[1]; dut_B=intf.B[1]; end
            2'b10: begin dut_req=intf.req[2]; dut_we=intf.we[2]; dut_opcode=intf.opcode[2]; dut_addr=intf.addr[2]; dut_A=intf.A[2]; dut_B=intf.B[2]; end
            2'b11: begin dut_req=intf.req[3]; dut_we=intf.we[3]; dut_opcode=intf.opcode[3]; dut_addr=intf.addr[3]; dut_A=intf.A[3]; dut_B=intf.B[3]; end
        endcase
    end

    logic dut_gnt;
    logic dut_rvalid;
    logic [7:0] dut_data_out;
    logic [1:0] dut_core_id_out;

    always_comb begin
        intf.gnt = 4'b0000;
        intf.gnt[selected_core] = dut_gnt;
    end

    always_comb begin
        intf.rvalid = 4'b0000;
        intf.data = '{default: '0};
        if (dut_rvalid) begin
            intf.rvalid[dut_core_id_out] = 1'b1;
            intf.data[dut_core_id_out]   = dut_data_out;
        end
    end

    mp_dut dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .core_id    (dut_core_id),
        .opcode     (dut_opcode),
        .req        (dut_req),
        .addr       (dut_addr),
        .A          (dut_A),
        .B          (dut_B),
        .we         (dut_we),
        .gnt        (dut_gnt),
        .rvalid     (dut_rvalid),
        .data_out   (dut_data_out),
        .core_id_out(dut_core_id_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end

    initial begin
        uvm_pkg::uvm_config_db#(virtual mp_intf)::set(null, "*", "vif", intf);
        run_test();
    end

endmodule
