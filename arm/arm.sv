module arm(
   input logic clk, reset,
	 input logic [31:0] Instruction, ReadData,
	 output logic [31:0] WriteData, AddressData, PC
);
  logic [31:0] ResultW;
  logic [31:0] ALUOutM;
  logic [31:0] ReadDataM;
  logic [31:0] InstMem; //Dato q sale da la memoria
  logic [31:0] pc_4;
  logic [31:0] R15;
  logic [3:0] flags;
  logic MemToRegM, MemToRegW, PCSrcW;
  logic BranchE, WA3E_W,WA3E_D, RegWriteW;


  fetch stageFetch(
        .clock(clk),
        .mux1pin0(pc_4),
        .PC(PC),
        .ctrlMux1(PCSrcW),
        .ctrlMux2(BranchE),
        .mux1pin1(ResultW),
        .mux2pin1(WA3E_W),
        .instPipeIn(Instruction),
        .instPipeOut(InstMem),
        .pcPlus4(pc_4)
        );
  decode stageDeco(
        .Clk(clk),
        //.Rst(hazard)
        .Instruction(InstMem),
        .ResultW(ResultW),
        .PCPlus8D(pc_4),
        .WA3W(WA3E_W),
        .flagsEin(flags), //Flags que vienen de la condition unit
        .RegWriteW(RegWriteM),
        .WA3E(WA3E_D)
  );
  execute stageExe(
        .Clk(clk),
        .flagsE(flags),
        .WA3E(WA3E_D)
  );
  memory stageMem(
        .clock(clk),
        .MemToRegOut(MemToRegW),
        .ALUResultMOut(ALUOutM),
        .ReadDataW(ReadDataM),
        .PCSrcOut(PCSrcW),
        .WA3Wout(WA3E_W),
        .RegWriteW(RegWriteW)
  );
// Write back stage
  mux2x1 #(32) ResultWMux (
        .a(ReadDataM),
        .b(ALUOutM),
        .ctrl(MemToRegW),
        .y(ResultW)
  );

endmodule
