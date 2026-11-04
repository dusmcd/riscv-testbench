class CPUReferenceModel;
  logic [31:0] registers[32];
  logic [12:0] pc;

  function new();
    foreach (registers[i])
      registers[i] = 32'b0;
      
    pc = 12'b0;
  endfunction

  function void execute_instruction(
    input instr_t instr,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [11:0] imm
    );

    case (instr) 
      ADD: add(rs1, rs2, rd);
      SUB: sub(rs1, rs2, rd);
      ADDI: addi(rs1, imm, rd);
    endcase

  endfunction

  function void decode_and_execute(input logic [31:0] instruction);
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [11:0] imm;
    instr_t instr;

    if (instruction[6:0] == 7'b0110011) begin
      // all R-types    
      rs1 = instruction[19:15];
      rs2 = instruction[24:20];
      rd = instruction[11:7];
      if (instruction[14:12] == 3'b0 && instruction[31:25] == 7'b0)
        instr = ADD;
      // add additional else ifs to decode other r-types
    end
    
    execute_instruction(instr, rs1, rs2, rd, imm);
  endfunction

  function void add(input logic[4:0] rs1, rs2, rd);
    registers[rd] = registers[rs1] + registers[rs2];
  endfunction

  function void sub(input logic[4:0] rs1, rs2, rd);
    registers[rd] = registers[rs1] - registers[rs2];
  endfunction

  function void addi(input logic[4:0] rs1, input logic [11:0] imm, input logic [4:0] rd);
    registers[rd] = registers[rs1] + {{20{imm[11]}}, imm};
  endfunction




endclass
