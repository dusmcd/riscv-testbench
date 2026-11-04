class CPUReferenceModel;
  logic [31:0] registers[32];
  logic [12:0] pc;

  function new();
    foreach (registers[i])
      registers[i] = 32'b0;

    pc = 12'b0;
  endfunction

  function automatic void execute_instruction(
    input instr_t instr,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [11:0] imm,
    input logic [19:0] imm_u,
    output instr_t instr_out,
    output logic [31:0] write_data
    );

    case (instr)
      ADD: add(rs1, rs2, rd);
      SUB: sub(rs1, rs2, rd);
      AND: and_op(rs1, rs2, rd);
      OR: or_op(rs1, rs2, rd);
      XOR: xor_op(rs1, rs2, rd);
      SLL: sll(rs1, rs2, rd);
      SRA: sra(rs1, rs2, rd);
      SRL: srl(rs1, rs2, rd);
      SLT: slt(rs1, rs2, rd);
      SLTU: sltu(rs1, rs2, rd);
      MUL: mul(rs1, rs2, rd);
      MULH: mulh(rs1, rs2, rd);
      MULHU: mulhu(rs1, rs2, rd);
      CSRRW: csrrw(rs1, rd, imm);
      ADDI: addi(rs1, imm, rd);
      ANDI: andi(rs1, imm, rd);
      ORI: ori(rs1, imm, rd);
      XORI: xori(rs1, imm, rd);
      SLLI: slli(rs1, imm, rd);
      SRAI: srai(rs1, imm, rd);
      SRLI: srli(rs1, imm, rd);
      LUI: lui(imm_u, rd);
      NOOP: ;
    endcase

    registers[0] = 32'b0;
    instr_out = instr;
    write_data = registers[rd];
  endfunction

  function automatic void decode_and_execute(
    input logic [31:0] instruction,
    output instr_t instr_out,
    output logic [31:0] write_data
  );
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [11:0] imm;
    logic [19:0] imm_u;
    instr_t instr;

    rs1 = instruction[19:15];
    rs2 = instruction[24:20];
    rd = instruction[11:7];
    imm = instruction[31:20];
    imm_u = instruction[31:12];
    instr = NOOP;

    case (instruction[6:0])
      7'b0110011: begin
        // R-type integer and multiply instructions.
        case ({instruction[31:25], instruction[14:12]})
          {7'b0000000, 3'b000}: instr = ADD;
          {7'b0100000, 3'b000}: instr = SUB;
          {7'b0000000, 3'b111}: instr = AND;
          {7'b0000000, 3'b110}: instr = OR;
          {7'b0000000, 3'b100}: instr = XOR;
          {7'b0000000, 3'b001}: instr = SLL;
          {7'b0100000, 3'b101}: instr = SRA;
          {7'b0000000, 3'b101}: instr = SRL;
          {7'b0000000, 3'b010}: instr = SLT;
          {7'b0000000, 3'b011}: instr = SLTU;
          {7'b0000001, 3'b000}: instr = MUL;
          {7'b0000001, 3'b001}: instr = MULH;
          {7'b0000001, 3'b011}: instr = MULHU;
          default: instr = NOOP;
        endcase
      end
      7'b0010011: begin
        // I-type integer instructions.
        case (instruction[14:12])
          3'b000: instr = ADDI;
          3'b111: instr = ANDI;
          3'b110: instr = ORI;
          3'b100: instr = XORI;
          3'b001: begin
            if (instruction[31:25] == 7'b0000000)
              instr = SLLI;
          end
          3'b101: begin
            if (instruction[31:25] == 7'b0100000)
              instr = SRAI;
            else if (instruction[31:25] == 7'b0000000)
              instr = SRLI;
          end
          default: instr = NOOP;
        endcase
      end
      7'b1110011: begin
        // Register form of CSR read/write.
        if (instruction[14:12] == 3'b001)
          instr = CSRRW;
      end
      7'b0110111: begin
        // U-type load upper immediate.
        instr = LUI;
      end
      default: instr = NOOP;
    endcase

    execute_instruction(instr, rs1, rs2, rd, imm, imm_u, instr_out, write_data);
  endfunction

  function automatic void add(input logic[4:0] rs1, rs2, rd);
    registers[rd] = registers[rs1] + registers[rs2];
  endfunction

  function automatic void sub(input logic[4:0] rs1, rs2, rd);
    registers[rd] = registers[rs1] - registers[rs2];
  endfunction

  function automatic void and_op(input logic[4:0] rs1, rs2, rd);
    registers[rd] = registers[rs1] & registers[rs2];
  endfunction

  function automatic void or_op(input logic[4:0] rs1, rs2, rd);
    registers[rd] = registers[rs1] | registers[rs2];
  endfunction

  function automatic void xor_op(input logic[4:0] rs1, rs2, rd);
    registers[rd] = registers[rs1] ^ registers[rs2];
  endfunction

  function automatic void sll(input logic[4:0] rs1, rs2, rd);
    registers[rd] = registers[rs1] << registers[rs2][4:0];
  endfunction

  function automatic void sra(input logic[4:0] rs1, rs2, rd);
    registers[rd] = $signed(registers[rs1]) >>> registers[rs2][4:0];
  endfunction

  function automatic void srl(input logic[4:0] rs1, rs2, rd);
    registers[rd] = registers[rs1] >> registers[rs2][4:0];
  endfunction

  function automatic void slt(input logic[4:0] rs1, rs2, rd);
    registers[rd] = ($signed(registers[rs1]) < $signed(registers[rs2]));
  endfunction

  function automatic void sltu(input logic[4:0] rs1, rs2, rd);
    registers[rd] = (registers[rs1] < registers[rs2]);
  endfunction

  function automatic void mul(input logic[4:0] rs1, rs2, rd);
    registers[rd] = registers[rs1] * registers[rs2];
  endfunction

  function automatic void mulh(input logic[4:0] rs1, rs2, rd);
    logic signed [63:0] product;
    logic signed [63:0] lhs;
    logic signed [63:0] rhs;
    lhs = $signed(registers[rs1]);
    rhs = $signed(registers[rs2]);
    product = lhs * rhs;
    registers[rd] = product[63:32];
  endfunction

  function automatic void mulhu(input logic[4:0] rs1, rs2, rd);
    logic [63:0] product;
    logic [63:0] lhs;
    logic [63:0] rhs;
    lhs = registers[rs1];
    rhs = registers[rs2];
    product = lhs * rhs;
    registers[rd] = product[63:32];
  endfunction

  function automatic void csrrw(input logic[4:0] rs1, rd, input logic[11:0] csr);
    /*
      this will not use CSR state, but will serve as a general purpose I/O
    */
  endfunction

  function automatic void addi(input logic[4:0] rs1, input logic [11:0] imm, input logic [4:0] rd);
    registers[rd] = registers[rs1] + {{20{imm[11]}}, imm};
  endfunction

  function automatic void andi(input logic[4:0] rs1, input logic [11:0] imm, input logic [4:0] rd);
    registers[rd] = registers[rs1] & {{20{imm[11]}}, imm};
  endfunction

  function automatic void ori(input logic[4:0] rs1, input logic [11:0] imm, input logic [4:0] rd);
    registers[rd] = registers[rs1] | {{20{imm[11]}}, imm};
  endfunction

  function automatic void xori(input logic[4:0] rs1, input logic [11:0] imm, input logic [4:0] rd);
    registers[rd] = registers[rs1] ^ {{20{imm[11]}}, imm};
  endfunction

  function automatic void slli(input logic[4:0] rs1, input logic [11:0] imm, input logic [4:0] rd);
    registers[rd] = registers[rs1] << imm[4:0];
  endfunction

  function automatic void srai(input logic[4:0] rs1, input logic [11:0] imm, input logic [4:0] rd);
    registers[rd] = $signed(registers[rs1]) >>> imm[4:0];
  endfunction

  function automatic void srli(input logic[4:0] rs1, input logic [11:0] imm, input logic [4:0] rd);
    registers[rd] = registers[rs1] >> imm[4:0];
  endfunction

  function automatic void lui(input logic [19:0] imm_u, input logic [4:0] rd);
    registers[rd] = {imm_u, 12'b0};
  endfunction



endclass
