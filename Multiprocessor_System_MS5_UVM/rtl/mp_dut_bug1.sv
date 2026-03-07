// ============================================================
// ECE-593 Milestone 5 — Bug Injection Scenario #1
// BUG: ADD (0001) performs A-B instead of A+B
// QuestaSim 2025.2.1 compatible
// ============================================================

module mp_dut #(
    parameter AW = 11,
    parameter DW = 8
)(
    input  logic        clk,
    input  logic        rst_n,

    input  logic [1:0]  core_id,
    input  logic [3:0]  opcode,
    input  logic        req,
    input  logic [AW-1:0] addr,
    input  logic [DW-1:0] A,
    input  logic [DW-1:0] B,
    input  logic        we,

    output logic        gnt,
    output logic        rvalid,
    output logic [DW-1:0] data_out,
    output logic [1:0]  core_id_out
);

    logic [DW-1:0] mem [0:(1<<AW)-1];
    logic [1:0]  p_core;
    logic [3:0]  p_op;
    logic [DW-1:0] p_res;
    logic        p_valid;

    assign gnt = req;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_valid     <= 1'b0;
            data_out    <= '0;
            rvalid      <= 1'b0;
            core_id_out <= '0;
            for (int i = 0; i < (1<<AW); i++) mem[i] <= '0;
        end else begin
            p_valid <= 1'b0;
            if (req && gnt) begin
                p_valid <= 1'b1;
                p_core  <= core_id;
                p_op    <= opcode;
                case (opcode)
                    4'b0001: p_res <= A - B;          // BUG! Should be A + B
                    4'b0011: p_res <= A - B;
                    4'b0100: p_res <= A * B;
                    4'b0101: p_res <= mem[addr];
                    4'b0110: begin
                        mem[addr] <= A;
                        p_res     <= A;
                    end
                    4'b0010: p_res <= A & B;
                    4'b0111: p_res <= A >> 1;
                    4'b1000: p_res <= A << 1;
                    4'b1001: p_res <= (A * B) - A;
                    4'b1010: p_res <= (A * 4 * B) - A;
                    4'b1011: p_res <= (A * B) + A;
                    4'b1100: p_res <= (A * 3);
                    4'b1101: p_res <= (A * B) + B;
                    default: p_res <= '0;
                endcase
            end
            rvalid      <= p_valid;
            data_out    <= p_res;
            core_id_out <= p_core;
        end
    end

endmodule
