class CPUInstruction;
  rand instr_t instr;
  rand bit [4:0] rs1;
  rand bit [4:0] rs2;
  rand bit [4:0] rd;
  rand bit [11:0] imm;
  rand bit [19:0] imm_u;

  constraint valid_registers {
    rd != 5'b0;
  }

  function void create_instr_file(input int num);
    int file = $fopen("tb_instructions.txt", "w")
    if (file == 0)
      $fatal("Could not create file");

    for (int i = 0; i < num; i++) begin
      bit [31:0] instruction;
      if (!randomize())
        $fatal("Randomization failed");

      instruction = encode_instr(); 

      if (i >= num - 1)
        $fwrite(file, "%h", instruction);
      else begin
        $fdisplay(file, "%h", instruction);
      end
      
    end
    $fclose(file);
  endfunction

  function bit [31:0] encode_instr();
    bit [31:0] instruction;
    typedef enum bit [1:0] {RTYPE, ITYPE, UTYPE, NO_OPERANDS} instr_type;
    instr_type instr_type_inst;

    instruction = 32'b0;
    instr_type_inst = NO_OPERANDS;

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
      AND: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0;
        instruction[14:12] = 3'b111;
        instr_type_inst = RTYPE;
      end
      OR: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0;
        instruction[14:12] = 3'b110;
        instr_type_inst = RTYPE;
      end
      XOR: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0;
        instruction[14:12] = 3'b100;
        instr_type_inst = RTYPE;
      end
      SLL: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0;
        instruction[14:12] = 3'b001;
        instr_type_inst = RTYPE;
      end
      SRA: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0100000;
        instruction[14:12] = 3'b101;
        instr_type_inst = RTYPE;
      end
      SRL: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0;
        instruction[14:12] = 3'b101;
        instr_type_inst = RTYPE;
      end
      SLT: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0;
        instruction[14:12] = 3'b010;
        instr_type_inst = RTYPE;
      end
      SLTU: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0;
        instruction[14:12] = 3'b011;
        instr_type_inst = RTYPE;
      end
      MUL: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0000001;
        instruction[14:12] = 3'b000;
        instr_type_inst = RTYPE;
      end
      MULH: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0000001;
        instruction[14:12] = 3'b001;
        instr_type_inst = RTYPE;
      end
      MULHU: begin
        instruction[6:0] = 7'b0110011;
        instruction[31:25] = 7'b0000001;
        instruction[14:12] = 3'b011;
        instr_type_inst = RTYPE;
      end
      ADDI: begin
        instruction[6:0] = 7'b0010011;
        instruction[14:12] = 3'b0;
        instr_type_inst = ITYPE;
      end
      ANDI: begin
        instruction[6:0] = 7'b0010011;
        instruction[14:12] = 3'b111;
        instr_type_inst = ITYPE;
      end
      ORI: begin
        instruction[6:0] = 7'b0010011;
        instruction[14:12] = 3'b110;
        instr_type_inst = ITYPE;
      end
      XORI: begin
        instruction[6:0] = 7'b0010011;
        instruction[14:12] = 3'b100;
        instr_type_inst = ITYPE;
      end
      SLLI: begin
        instruction[6:0] = 7'b0010011;
        instruction[31:25] = 7'b0;
        instruction[14:12] = 3'b001;
        instr_type_inst = ITYPE;
      end
      SRAI: begin
        instruction[6:0] = 7'b0010011;
        instruction[31:25] = 7'b0100000;
        instruction[14:12] = 3'b101;
        instr_type_inst = ITYPE;
      end
      SRLI: begin
        instruction[6:0] = 7'b0010011;
        instruction[31:25] = 7'b0;
        instruction[14:12] = 3'b101;
        instr_type_inst = ITYPE;
      end
      CSRRW: begin
        instruction[6:0] = 7'b1110011;
        instruction[14:12] = 3'b001;
        instr_type_inst = ITYPE;
      end
      LUI: begin
        instruction[6:0] = 7'b0110111;
        instr_type_inst = UTYPE;
      end
      NOOP: begin
        instruction = 32'h00000013;
        instr_type_inst = NO_OPERANDS;
      end
      default: begin
        instruction = 32'h00000013;
        instr_type_inst = NO_OPERANDS;
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
        if (instr == SLLI || instr == SRLI || instr == SRAI)
          instruction[24:20] = imm[4:0];
        else
          instruction[31:20] = imm;
      end
      UTYPE: begin
        instruction[11:7] = rd;
        instruction[31:12] = imm_u;
      end
    endcase

    return instruction;
  endfunction



endclass
