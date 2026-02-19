`ifndef DRIVER_SV
`define DRIVER_SV

class driver;

   mailbox #(transaction) gen2driv;
   virtual intf vif;
   generator gen_h;

   function new(mailbox #(transaction) gen2driv,
                virtual intf vif,
                generator gen_h);
      this.gen2driv = gen2driv;
      this.vif      = vif;
      this.gen_h    = gen_h;
   endfunction

   task reset();
      vif.req <= 0;
      vif.we  <= 0;
      @(posedge vif.clk);
   endtask

   task main();
      transaction tx;
      forever begin
         gen2driv.get(tx);

         vif.core_id <= tx.core_id;
         vif.opcode  <= tx.opcode;
         vif.addr    <= tx.addr;
         vif.A       <= tx.A;
         vif.B       <= tx.B;

         vif.req <= 1;
         vif.we  <= tx.we;

         @(posedge vif.clk);
         vif.req <= 0;
      end
   endtask

endclass

`endif

