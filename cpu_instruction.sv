class CPUInstruction;
  rand instr_t instr;
  rand bit [4:0] rs1;
  rand bit [4:0] rs2;
  rand bit [4:0] rd;
  rand bit [11:0] imm;

  constraint valid_registers {
    rd != 5'b0;
  }

  function bit [31:0] encode_instr();
    bit [31:0] instruction;
    typedef enum bit [2:0] {RTYPE, ITYPE} instr_type;
    instr_type instr_type_inst;

    case (instr)
      ADD: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0;
        instruction[14:12] = 3'b0;
        instr_type_inst = RTYPE;
      end
      SUB: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0100000;
        instruction[14:12] = 3'b0;
        instr_type_inst = RTYPE;
      end
      ADDI: begin
        instruction[6:0] = 7'b0010011;
        instruction[14:12] = 3'b0;
        instruction[31:20] = imm;
        instr_type_inst = ITYPE;
      end

    endcase

    case (instr_type_inst)
      RTYPE: begin
        instruction[19:15] = rs1;
        instruction[24:20] = rs2;
        instruction[11:7] = rd;
      end
      ITYPE: begin
        instruction[19:15] = rs1;
        instruction[11:7] = rd;
      end
    endcase

    return instruction;
  endfunction



endclass
