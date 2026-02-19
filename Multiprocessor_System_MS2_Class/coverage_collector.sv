`include "transaction.sv"

class coverage_collector;

   covergroup op_cov;

      cp_core : coverpoint tr.core_id {
         bins cores[] = {[0:3]};
      }

      cp_opcode : coverpoint tr.opcode {
         bins NOP     = {4'b0000};
         bins ALU[]   = {[4'b0001:4'b0011]};
         bins shift[] = {[4'b0100:4'b0101]};
         bins memory[]= {[4'b0110:4'b1001]};
         bins logical[]= {[4'b1010:4'b1100]};
         bins special = {4'b1101};
      }

      cp_addr : coverpoint tr.addr {
         bins low_mem  = {[0:100]};
         bins mid_mem  = {[101:1000]};
         bins high_mem = {[1001:2047]};
      }

      cross cp_core, cp_opcode;

   endgroup

   transaction tr;

   function new();
      op_cov = new();
   endfunction

   task sample(transaction t);
      tr = t;
      op_cov.sample();
   endtask

endclass
