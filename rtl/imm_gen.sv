// rtl/core/imm_gen.sv
// RV32I immediate generator (I, S, B)
// - I-type: ADDI, LW  (imm in [31:20])
// - S-type: SW        (imm split in [31:25] and [11:7])
// - B-type: BEQ       (imm scattered + LSB = 0)

module imm_gen (
    input  logic [31:0] instr,
    output logic [31:0] imm_out
);

    logic [6:0] opcode;
    assign opcode = instr[6:0]; // instruction type selector

    // Opcode constants (RV32I)
    localparam logic [6:0] OPCODE_OP_IMM = 7'b0010011; // ADDI
    localparam logic [6:0] OPCODE_LOAD   = 7'b0000011; // LW
    localparam logic [6:0] OPCODE_STORE  = 7'b0100011; // SW
    localparam logic [6:0] OPCODE_BRANCH = 7'b1100011; // BEQ

    always_comb begin
        imm_out = 32'd0; // default

        unique case (opcode)

            // I-type immediate: instr[31:20] (12 bits)
            // Sign-extend: copy instr[31] into top 20 bits
            OPCODE_OP_IMM,
            OPCODE_LOAD: begin
                imm_out = {{20{instr[31]}}, instr[31:20]};
            end

            // S-type immediate: {instr[31:25], instr[11:7]} (12 bits)
            // Sign-extend using instr[31]
            OPCODE_STORE: begin
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            // B-type immediate (branch offset):
            // imm = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}
            // Total 13 bits including the forced 0 at LSB (<<1)
            // Sign-extend using instr[31] (imm[12])
            OPCODE_BRANCH: begin
                imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            default: begin
                imm_out = 32'd0;
            end

        endcase
    end

endmodule