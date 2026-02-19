//////////////////////////////////////////////////
//	ECE-593 Project				//
//	Multiprocessor System			//
//	Milestone2 - class based verification	//
//	Prepared by Frezewd Debebe		//
//////////////////////////////////////////////////


module mp_dut #(
    	parameter AW = 11,    //address width
    	parameter DW = 8      //data width
)(
    	input  logic        clk,
    	input  logic        rst_n,
    
    	// Request signals
    	input  logic [1:0]  core_id,  // core 0, 1, 2, 3
    	input  logic [3:0]  opcode,   // ADD, SUB, LOAD, STORE, Special function
    	input  logic        req,      // Request valid
    	input  logic [AW-1:0] addr,   // Memory address
    	input  logic [DW-1:0] A,      // Operand A
    	input  logic [DW-1:0] B,      // Operand B
    	input  logic        we,       // Write Enable
    
    	output logic        gnt,      // Grant 
    
    	// Response signals
    	output logic        rvalid,     // Data is ready
    	output logic [DW-1:0] data_out, // Result (ALU or Memory)
    	output logic [1:0]  core_id_out // Tagging the result for the scoreboard
);

    	// Internal Memory
    	logic [DW-1:0] mem [0:(1<<AW)-1];

    	// Pipeline Registers 
    	logic [1:0]  p_core;
    	logic [3:0]  p_op;
    	logic [DW-1:0] p_res;
    	logic        p_valid;

    	// Arbiter 
    	assign gnt = req; 

   	 // ALU Logic & Memory Access
    	always_ff @(posedge clk or negedge rst_n) begin
        	if (!rst_n) begin
            		p_valid     <= 1'b0;
            		data_out    <= '0;
            		rvalid      <= 1'b0;
            		core_id_out <= '0;
            		// Clear memory on reset
            		for (int i=0; i<(1<<AW); i++) mem[i] <= '0;
        	end else begin
            		// Clear valid signal
           		 p_valid <= 1'b0;

            		if (req && gnt) begin
                		p_valid <= 1'b1;
               			p_core  <= core_id;
               			p_op    <= opcode;

                	case (opcode)
                    		4'b0001: p_res <= A + B;          // ALU ADD
                    		4'b0011: p_res <= A - B;          // ALU SUB
				4'b0100: p_res <= A * B;          // Multiply A and B
                    		4'b0101: p_res <= mem[addr];      // MEM LOAD
                    		4'b0110: begin                    // MEM STORE
                        		mem[addr] <= A; 
                        		p_res     <= A; 
                    			end
                    		4'b0010: p_res <= A & B;          // LOGIC AND
                    		4'b0111: p_res <= A >> 1;         // SHIFT RIGHT
				4'b1000: p_res <= A << 1;         // SHIFT LEFT
				4'b1001: p_res <= (A * B) - A;    // Special function
				4'b1010: p_res <= (A * 4 * B) - A;// Special function
				4'b1011: p_res <= (A * B) + A;    // Special function
				4'b1100: p_res <= (A * 3);        // Special function
				4'b1101: p_res <= (A * B) + B;    // Special function
                    		default: p_res <= '0;
                	endcase
            	end

            	// Pipeline Output (Results appear 1 cycle after request)
            	rvalid      <= p_valid;
            	data_out    <= p_res;
            	core_id_out <= p_core;
        	end
    	end

endmodule
