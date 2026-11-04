package cpu_tb_pkg;

  typedef enum bit [5:0] {
    ADD,
    SUB,
    AND,
    OR,
    XOR,
    SLL,
    SRA,
    SRL,
    SLT,
    SLTU,
    MUL,
    MULH,
    MULHU,
    CSRRW,
    ADDI,
    ANDI,
    ORI,
    XORI,
    SLLI,
    SRAI,
    SRLI,
    LUI,
    NOOP
  } instr_t;

  `include "cpu_ref_model.sv"
  `include "cpu_instruction.sv"
endpackage
