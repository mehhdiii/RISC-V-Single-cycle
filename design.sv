// Code your design here
`include "Program_Counter.sv"
`include "adder.sv"
`include "MUX.sv"
`include "Instruction_Memory.sv"
`include "instruction_parser.sv"
`include "Control_Unit.sv"
`include "registerFile.sv"
`include "imm_data_extractor.sv"
`include "ALU_Control.sv"
`include "Data_Memory.sv"
`include "ALU_64.sv"



module top (
	input clk, 
  	input reset
);
  
  //PC --------------------

  wire [63:0] PC_out;
  
  //initialize PC_in: 
  wire [63:0] PC_in;
  
  
  Program_Counter PC_RISC(.clk(clk), .reset(reset), .PC_in(PC_in), //add mux output at PC_in
                          .PC_out(PC_out));
  
  wire [63:0] PC_incrementer_out; 
  
  //PC incrementer: -----------------
  
  adder AddPC1(.a(PC_out), .b(64'd4), .out(PC_incrementer_out));
  
  //PC incrementer: -----------------
  
  
  //PC jumper code implemented later in the file
  
  
  //PC --------------------
  
  
  
  
  
  
  
  
  //instruction memory: ------------------
  wire [31:0] ins_mem_to_ins_parser; 
  
  Instruction_Memory ins_mem(.inst_address( PC_out ), .instruction(ins_mem_to_ins_parser) );
  
  
  //instruction memory: ------------------
  
  
  
  
  
  
  
  
  //Instruction parsing -----------------------
  wire [6:0] opcode; 
  wire [4:0] rs1; 
  wire [4:0] rs2; 
  wire [4:0] rd; 
  wire [2:0] funct3; 
  wire [6:0] funct7; 
  
  instruction_parser ins_parser(
    .inst(ins_mem_to_ins_parser), 
    .opcode(opcode), 
    .rd(rd), 
    .funct3(funct3), 
    .rs1(rs1), 
    .rs2(rs2), 
    .funct7(funct7)
  );
  
  //Instruction parsing -----------------------
  
  
  
  
  //Control Unit: -----------------------------
  
  wire Branch; 
  wire MemRead; 
  wire MemtoReg; 
  wire [1:0] ALUOp; 
  wire MemWrite; 
  wire ALUSrc; 
  wire RegWrite; 
  
  Control_Unit control_unit(
    .Opcode(opcode), 
    .Branch(Branch), 
    .MemRead(MemRead), 
    .MemtoReg(MemtoReg), 
    .ALUOp(ALUOp), 
    .MemWrite(MemWrite), 
    .ALUSrc(ALUSrc), 
    .RegWrite(RegWrite)
);
  
  
  //Control Unit: -----------------------------
  
  
  
  
  
  
  //Registers: ---------------------
  wire [63:0] ReadData1; 
  wire [63:0] ReadData2; 
  registerFile reg_file(
    .rs1(rs1), 
    .rs2(rs2), 
    .rd(rd), 
    .WriteData(), 
    .RegWrite(RegWrite), 
    .clk(clk), 
    .reset(reset), 
    .ReadData1(ReadData1), 
    .ReadData2(ReadData2) 
  );
  //Registers ----------------------
  
  
  
  
  
  
  //Immediate Data Extractor: --------------
  wire [63:0] imm_data; 
  imm_data_extractor imm_data_ext(
    .inst(ins_mem_to_ins_parser), 
    .imm_data(imm_data)
  ); 
  
  //Immediate Data Extractor: --------------
  
  
  
  
  

  
  
  
  
  
  //Reg2ALU: ------------------
  //Mux: 
  wire [63:0] reg2alu_data_out; 
  MUX reg2alu_mux(
    .a(ReadData2), 
    .b(imm_data), 
    .sel(ALUSrc), //missing??
    .data_out(reg2alu_data_out)
  );
  //Reg2ALU: ------------------
  
  
  
  //ALU control: --------------
  wire [3:0] Funct; 
  wire [1:0] ALUOperation; 
  wire [3:0] Operation; 
  ALU_Control alu_control(
    .Funct(Funct), 
    .ALUOp(ALUOperation), 
    .Operation(Operation)
	); 
  //ALU control: --------------
  
  
  
  
  
  //ALU: ----------------------
  wire alu_zero;
  wire [63:0] Result; 
  ALU_64 alu(.a(ReadData1), 
         .b(reg2alu_data_out), 
         .ALUOp(Operation), 
         .Result(Result), 
         .zero(alu_zero)
        
        );
  
  //ALU: ----------------------
  
  
  
  
  
  
  //PC: ------------------------------------
  
  //immediate_data PC jumper: ------ 
  wire [63:0] imm_data_adder_out; 
  
  adder AddPC2(.a(PC_out), .b(imm_data<<1), .out(imm_data_adder_out)); 
  
  //immediate_data PC jumper: ------ 
  
  
  //selector between regular PC and imm_data Jump:
  MUX muxPC(.a(PC_incrementer_out), .b(imm_data_adder_out), .sel(Branch & alu_zero), .data_out(PC_in)); 
  
  //PC -------------------------------------
  
  
  
  
  
  //Data Memory: --------------
  wire [63:0] Read_Data;
  Data_Memory data_memory(
    .clk(clk), 
    .Mem_Addr(Result), 
    .Write_Data(ReadData2), 
    .MemWrite(MemWrite), //From Control_unit
    .MemRead(MemRead), //From Control_unit
    .Read_Data(Read_Data) 
	);
  //Data Memory: --------------
  

  
  //mem2reg: ------------------
  
  //Mux: 
  wire [63:0] mem2reg_data_out; 
  MUX mem2reg_mux(
    .a(Read_Data), 
    .b(Result), 
    .sel(MemtoReg), //Control unit
    .data_out(mem2reg_data_out)
  );
  
  //mem2reg: ------------------
  
  
  
  
  
  
  
endmodule 
