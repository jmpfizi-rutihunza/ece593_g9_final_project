//////////////////////////////////
//    ECE-593 Project           //
//    Multiprocessor System     //
//    Milestone 5 - UVM        //
/////////////////////////////////

class mp_coverage extends uvm_subscriber #(mp_transaction);

    // UVM factory registration
    `uvm_component_utils(mp_coverage)

    mp_transaction tr;

    covergroup op_cov with function sample(mp_transaction t);
        option.per_instance = 1;
        option.name         = "Multiprocessor_Coverage";

        CP_CORE: coverpoint t.core_id {
            bins core_0 = {0};
            bins core_1 = {1};
            bins core_2 = {2};
            bins core_3 = {3};
        }

        CP_OPCODE: coverpoint t.opcode {
            bins NOP     = {4'b0000};
            bins ADD     = {4'b0001};
            bins AND     = {4'b0010};
            bins SUB     = {4'b0011};
            bins MUL     = {4'b0100};
            bins LOAD    = {4'b0101};
            bins STORE   = {4'b0110};
            bins SHR     = {4'b0111};
            bins SHL     = {4'b1000};
            bins SPL_0   = {4'b1001};
            bins SPL_1   = {4'b1010};
            bins SPL_2   = {4'b1011};
            bins SPL_3   = {4'b1100};
            bins SPL_4   = {4'b1101};
            illegal_bins INVALID = {[4'b1110:4'b1111]};
        }

        CP_ADDR: coverpoint t.addr {
            bins low_mem  = {[0:511]};
            bins mid_mem  = {[512:1535]};
            bins high_mem = {[1536:2047]};
        }

        CP_OPERAND_A: coverpoint t.A {
            bins zero   = {8'h00};
            bins max    = {8'hFF};
            bins others = {[8'h01:8'hFE]};
        }

        CP_OPERAND_B: coverpoint t.B {
            bins zero   = {8'h00};
            bins max    = {8'hFF};
            bins others = {[8'h01:8'hFE]};
        }

        CROSS_CORE_OP: cross CP_CORE, CP_OPCODE;

        CROSS_MEM_REGION: cross CP_OPCODE, CP_ADDR {
            ignore_bins non_mem = CROSS_MEM_REGION with
                (!(CP_OPCODE inside {4'b0101, 4'b0110}));
        }
    endgroup

    function new(string name = "mp_coverage", uvm_component parent = null);
        super.new(name, parent);
        op_cov = new();
    endfunction

    virtual function void write(mp_transaction t);
        this.tr = t;
        op_cov.sample(t);
    endfunction

    // No report_phase — covergroup get_coverage() calls on UVM 1.1d
    // cause SIGSEGV during report_phase. Full coverage detail is
    // captured in the UCDB and reported by vcover in run.do.

endclass
