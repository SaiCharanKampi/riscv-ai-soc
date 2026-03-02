`timescale 1ns/1ps

module imm_gen_tb;

  logic [31:0] instr;
  logic [31:0] imm_out;

  // Instantiate DUT
  imm_gen dut (
    .instr(instr),
    .imm_out(imm_out)
  );

  initial begin
    $display("Starting Simulation...");

    // -------------------------
    // I-TYPE TEST
    // -------------------------
    instr = 32'h00508193;   // ADDI x3, x1, 5
    #10;
    $display("ADDI +5 -> imm_out = %0d", $signed(imm_out));

    instr = 32'hFFF08193;   // ADDI x3, x1, -1
    #10;
    $display("ADDI -1 -> imm_out = %0d", $signed(imm_out));

    // -------------------------
    // S-TYPE TEST
    // -------------------------
    instr = 32'h0030A423;   // SW x3, 8(x1)
    #10;
    $display("SW +8 -> imm_out = %0d", $signed(imm_out));

    instr = 32'hFE30AE23;   // SW x3, -4(x1)
    #10;
    $display("SW -4 -> imm_out = %0d", $signed(imm_out));

    // -------------------------
    // B-TYPE TEST
    // -------------------------
    instr = 32'h00208863;   // BEQ x1, x2, 16
    #10;
    $display("BEQ +16 -> imm_out = %0d", $signed(imm_out));

    instr = 32'hFE208EE3;   // BEQ x1, x2, -4
    #10;
    $display("BEQ -4 -> imm_out = %0d", $signed(imm_out));

    $display("Simulation Finished.");
    $finish;
  end

endmodule