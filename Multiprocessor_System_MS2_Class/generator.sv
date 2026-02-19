`ifndef GENERATOR_SV
`define GENERATOR_SV

class generator;

   mailbox #(transaction) gen2driv;
   event ended;

   // tb_top.sv expects this name
   int tx_count;

   function new(mailbox #(transaction) gen2driv);
      this.gen2driv = gen2driv;
      tx_count = 200;   // you can increase if you want
   endfunction


   task main();
      transaction tx;

      // =========================
      // 1) RANDOM PHASE
      // =========================
      repeat (tx_count) begin
         tx = new();
         void'(tx.randomize());
         gen2driv.put(tx);
      end

      // =========================
      // 2) DIRECTED COVERAGE CLOSURE
      // Missing cross bins:
      // <cores[0], logical[11]>  opcode 1011
      // <cores[2], memory[8]>    opcode 1000
      // <cores[2], memory[6]>    opcode 0110
      // <cores[0], ALU[3]>       opcode 0011
      // <cores[0], ALU[2]>       opcode 0010
      // =========================

      // core0 + ALU[2]
      tx = new();
      void'(tx.randomize() with { core_id == 0; opcode == 4'b0010; });
      gen2driv.put(tx);

      // core0 + ALU[3]
      tx = new();
      void'(tx.randomize() with { core_id == 0; opcode == 4'b0011; });
      gen2driv.put(tx);

      // core2 + memory[6]
      tx = new();
      void'(tx.randomize() with { core_id == 2; opcode == 4'b0110; });
      gen2driv.put(tx);

      // core2 + memory[8]
      tx = new();
      void'(tx.randomize() with { core_id == 2; opcode == 4'b1000; });
      gen2driv.put(tx);

      // core0 + logical[11]
      tx = new();
      void'(tx.randomize() with { core_id == 0; opcode == 4'b1011; });
      gen2driv.put(tx);

      // =========================
      // 3) DONE
      // =========================
      -> ended;
   endtask

endclass

`endif

