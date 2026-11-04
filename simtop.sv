import cpu_tb_pkg::*;

module simtop;
  bit clk;
  instr_t instr;

  // driving the clock in simulation
  always begin
    #5 clk = ~clk;
  end

  // ensure that all instructions have been executed
  covergroup cg @(posedge clk);
    coverpoint instr {
      bins add = {ADD};
      bins sub = {SUB};
      bins addi = {ADDI};
    }
  endgroup

  CPUInstruction cpu_instr;
  CPUReferenceModel ref_model;
  cg cg_inst;
  initial begin : tester
    // reset and initialize
    instr = NOOP;
    cpu_instr = new();
    cg_inst = new();
    repeat(1000) begin
      @(negedge clk);
      if (!cpu_instr.randomize())
        $fatal("Instruction randomization failed");

      instr = cpu_instr.instr;

    end
    $display("Coverage = %0.2f %%", cg_inst.get_inst_coverage());
    $finish;
  end : tester

  always @(posedge clk) begin : scoreboard
    ref_model = new();
    if (instr != NOOP) begin
      // check reference model against DUT 
    end
  end : scoreboard

endmodule
