`ifndef GENERATOR_SV
`define GENERATOR_SV

class generator;

   mailbox #(transaction) gen2driv;
   event ended;

   int tx_count;

   function new(mailbox #(transaction) gen2driv);
      this.gen2driv = gen2driv;
      tx_count = 200;   // you can increase if you want
   endfunction


   task main();
      transaction tx;

     
      repeat (tx_count) begin
         tx = new();
         void'(tx.randomize());
         gen2driv.put(tx);
      end

     
      tx = new();
      void'(tx.randomize() with { core_id == 0; opcode == 4'b0010; });
      gen2driv.put(tx);

      
      tx = new();
      void'(tx.randomize() with { core_id == 0; opcode == 4'b0011; });
      gen2driv.put(tx);

      
      tx = new();
      void'(tx.randomize() with { core_id == 2; opcode == 4'b0110; });
      gen2driv.put(tx);

      
      tx = new();
      void'(tx.randomize() with { core_id == 2; opcode == 4'b1000; });
      gen2driv.put(tx);

    
      tx = new();
      void'(tx.randomize() with { core_id == 0; opcode == 4'b1011; });
      gen2driv.put(tx);


      -> ended;
   endtask

endclass

`endif


