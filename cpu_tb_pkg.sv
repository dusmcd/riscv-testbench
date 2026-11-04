package cpu_tb_pkg;

  typedef enum bit [5:0] {
    ADD,
    SUB,
    ADDI,
    NOOP
  } instr_t;

  `include "cpu_ref_model.sv"
  `include "cpu_instruction.sv"
endpackage
