//////////////////////////////////
//    ECE-593 Project           //
//    Multiprocessor System     //
//    Milestone 5 - UVM        //
/////////////////////////////////

class mp_monitor extends uvm_monitor;

    // UVM factory registration
    `uvm_component_utils(mp_monitor)

    // Virtual Interface
    virtual mp_intf vif;
    int core_id;

    // Analysis Port - sends observed transactions to scoreboard and coverage
    uvm_analysis_port #(mp_transaction) monitor_A_port;

    // Constructor
    function new(string name = "mp_monitor", uvm_component parent = null);
        super.new(name, parent);
        monitor_A_port = new("monitor_A_port", this);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual mp_intf)::get(this, "", "vif", vif))
            `uvm_fatal("[iMon]", "Virtual interface not found")

        if (!uvm_config_db#(int)::get(this, "", "core_id", core_id))
            `uvm_fatal("[iMon]", "Core ID not found")

        `uvm_info("[iMon]", $sformatf("Monitor built for Core %0d", core_id), UVM_MEDIUM)
    endfunction

    // Run Phase - observe DUT pins and capture transactions
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            mp_transaction observed_tx;

            // Wait for arbiter to grant bus access to this core
            @(posedge vif.clk iff (vif.gnt[core_id] === 1'b1));

            // Create transaction object via factory
            observed_tx = mp_transaction::type_id::create("observed_tx");

            // Sample input signals at point of grant
            observed_tx.core_id = core_id;
            observed_tx.opcode  = vif.opcode[core_id];
            observed_tx.addr    = vif.addr[core_id];
            observed_tx.we      = vif.we[core_id];
            observed_tx.A       = vif.A[core_id];
            observed_tx.B       = vif.B[core_id];
            observed_tx.gnt     = 1'b1;

            `uvm_info("[iMon]", $sformatf("Core %0d: Grant detected - Op=0x%0h Addr=0x%03h A=0x%02h B=0x%02h",
                core_id, observed_tx.opcode, observed_tx.addr,
                observed_tx.A, observed_tx.B), UVM_MEDIUM)

            // Wait for result output:
            // ALU, LOAD produce valid result on rvalid
            // STORE (0110) and NOP (0000) do not produce output data
            if (observed_tx.opcode != 4'b0110 && observed_tx.opcode != 4'b0000) begin
                @(posedge vif.clk iff (vif.rvalid[core_id] === 1'b1));
                observed_tx.data   = vif.data[core_id];
                observed_tx.rvalid = 1'b1;
            end else begin
                @(posedge vif.clk);
                observed_tx.data = observed_tx.A;  // STORE: data written = A
            end

            `uvm_info("[oMon]", $sformatf("Core %0d: Output captured - Op=0x%0h Data=0x%02h",
                core_id, observed_tx.opcode, observed_tx.data), UVM_MEDIUM)

            // Forward to scoreboard and coverage via analysis port
            monitor_A_port.write(observed_tx);
            @(posedge vif.clk);
        end
    endtask

endclass
