// CLK: input clock signal
`timescale 1ns/1ps

module CPU
(
    //input
      input CLK
);

reg[31:0] reg_file[31:0];
reg[31:0] PC, PCF, PCJump;
reg[31:0] PCPlus4F, PCPlus4D;
reg[31:0] InstrD;
wire[31:0] RD, RD_Data;

reg[4:0] A1, A2, A3;
reg[31:0] WD3;
reg[31:0] RD1, RD2;
reg[31:0] SignExtend;
reg WE3;

reg[5:0] Op;
reg[5:0] Funct;
reg[4:0] RsD, RtD, RdD, SA;
reg RegWriteD, MemtoRegD, MemWriteD, BranchD;
reg[5:0] ALUControlD;
reg ALUSrcD, RegDstD, PCSrcD, PCBranchD;

reg[31:0] SrcAE, SrcBE, WriteDataE;
reg[31:0] SignImmD, SignImmE;
reg[4:0] RsE, RtE, RdE, WriteRegE;
reg RegWriteE, MemtoRegE, MemWriteE;
reg[5:0] ALUControlE;
reg ALUSrcE;
reg RegDstE;

reg RegWriteM;
reg MemtoRegM;
reg MemWriteM;
reg[31:0] ALUOutE, ALUOutM;
reg[31:0] WriteDataM;
reg[4:0] WriteRegM;

reg[4:0] WriteRegW;
reg RegWriteW, MemtoRegW;
reg[31:0] ALUOutW, ReadDataW, ResultW;
reg JumpD, JalD, JD;
reg stallF, stallD;
reg [2:0] flag;
reg Enable, Disable, CLR, BranchCLRF, BranchCLRD, BranchCLRE, BranchCLRM, JCLRF, JCLRD, JCLRE, JCLRM;

initial begin
  Enable = 1;
  Disable = 0;
  CLR = 0;
  PC = 32'h00000000;
  PCSrcD = 0;
  PCBranchD = 0;
  PCPlus4F = 0;
  reg_file[0] = 0;
  PCF = 0; 
  PCJump = 0;
  target = 0;
  PCPlus4D = 0;
  RD_InstrD = 0;
  InstrD= 0;
  A1 = 0;
  A2 = 0;
  A3 = 0;
  WD3 = 0;
  WE3 = 0;
  RD1 = 0; 
  RD2 = 0;
  SA = 0;
  SignExtend = 0;
  Op = 0;
  Funct = 0;
  RsD = 0; 
  RtD = 0; 
  RdD = 0;
  RegWriteD = 0; 
  MemtoRegD = 0; 
  MemWriteD = 0; 
  BranchD = 0;
  ALUControlD = 0;
  ALUSrcD = 0; 
  RegDstD = 0;
  EqualD = 0;
  SrcAE = 0; 
  SrcBE = 0;
  SignImmD = 0;
  SignImmE = 0;
  SignImmShftD = 0;
  RsE = 0; 
  RtE = 0; 
  RdE = 0;
  RegWriteE = 0; 
  MemtoRegE = 0; 
  MemWriteE = 0; 
  WriteDataE = 0; 
  WriteRegE = 0;
  ALUControlE = 0;
  ALUSrcE = 0;
  RegDstE = 0;

  RegWriteM = 0;
  MemtoRegM = 0;
  MemWriteM = 0;
  ALUOutE = 0; 
  ALUOutM = 0;
  WriteDataM = 0;
  WriteRegM = 0;

  RegWriteW = 0;  
  WriteRegW = 0; 
  MemtoRegW = 0;
  ALUOutW = 0; 
  ReadDataW = 0; 
  ResultW = 0;
  JumpD = 0; 
  JalD = 0; 
  JD = 0;
  stallF = 0; 
  stallD = 0;
  flag = 0;
  BranchCLRF = 0; 
  BranchCLRD = 0; 
  BranchCLRE = 0; 
  BranchCLRM = 0; 
  JCLRF = 0; 
  JCLRD = 0; 
  JCLRE = 0; 
  JCLRM = 0;

end


always @(PCSrcD, PCPlus4F, PCBranchD, PCJump, JD) begin
  if(PCSrcD)
    PC = PCBranchD;
  else if(JD)
    PC = PCJump;
  else
    PC = PCPlus4F; 
  //$display("%b", PC);
end

/*
always @(PCPlus4F) begin
  if(PCSrcD)
    PC = PCBranchD;
  else if(JD)
    PC = PCJump;
  else
    PC = PCPlus4F; 
  $display("%b", PC);
end
*/
InstructionRAM ins_ram(
  .CLOCK(CLK), 
  .RESET(Disable), 
  .ENABLE(Enable), 
  .FETCH_ADDRESS(PCF), 
  .DATA(RD));

always @(posedge CLK) begin
  if(!stallF) begin
    PCF <= PC;
  end
  //$display("%b", PCF);
end

always @(PCF) begin
  PCPlus4F = PCF + 1;
end

reg [31:0] RD_InstrD;
always @(RD) begin
  RD_InstrD = RD;
  //$display("%b", RD);
end

reg [25:0] target;
always @(posedge CLK) begin
  if(!stallD) begin
    InstrD <= RD_InstrD;
    PCPlus4D <= PCPlus4F;
    Op <= InstrD[31:26];
    Funct <= InstrD[5:0];
    A1 <= InstrD[25:21];
    A2 <= InstrD[20:16];
    A3 <= WriteRegW;
    WD3 <= ResultW;
    RsD <= InstrD[25:21];
    RtD <= InstrD[20:16];
    RdD <= InstrD[15:11];
    SignExtend <= InstrD[15:0];
    target <= InstrD[25:0];
    SA <= InstrD[10:6];
  end
  if(BranchCLRD || JCLRD) begin
    InstrD <= CLR;
    PCPlus4D <= CLR;
    Op <= CLR;
    Funct <= CLR;
    A1 <= CLR;
    A2 <= CLR;
    A3 <= CLR;
    WD3 <= CLR;
    RsD <= CLR;
    RtD <= CLR;
    RdD <= CLR;
    SignExtend <= CLR;  
    target <= CLR;
    SA <= CLR;
  end
  //$display("%b", InstrD);
end

always @(Op, Funct,InstrD) begin 
  //$display("%b %b", Op, Funct);
  case(Op)
    6'h00: begin
      RegWriteD = 1;
      MemtoRegD = 0;
      MemWriteD = 0;
      BranchD = 0;
      ALUSrcD = 0;
      RegDstD = 1;
      JumpD = 0;
      JalD = 0;
      case(Funct)
        6'h20: begin //add
          ALUControlD = 6'b000010;
        end
        6'h21: begin //addu
          ALUControlD = 6'b100010;
        end
        6'h24: begin //and
          ALUControlD = 6'b000000;
        end
        6'h08: begin //jr
          ALUControlD = 6'b000011;
        end
        6'h27: begin //nor 
          ALUControlD = 6'b000100;
        end
        6'h25: begin //or 
          ALUControlD = 6'b000101;
        end
        6'h00, 6'h04: begin //sll sllv
          ALUControlD = 6'b000110;
        end
        6'h2A: begin //slt
          ALUControlD = 6'b001000;
        end
        6'h03, 6'h07: begin //sra srav
          ALUControlD = 6'b001001;
        end
        6'h02, 6'h06: begin //srl srlv
          ALUControlD = 6'b001011;
        end
        6'h22: begin //sub
          ALUControlD = 6'b001101;
        end
        6'h23: begin //subu
          ALUControlD = 6'b001110;
        end
        6'h26: begin //xor
          ALUControlD = 6'b001111;
        end
      endcase
    end
    6'h08: begin //addi
      RegWriteD = 1;
      MemtoRegD = 0;
      MemWriteD = 0;
      BranchD = 0;
      ALUControlD = 6'b000010;
      ALUSrcD = 1;
      RegDstD = 0;
      JumpD = 0;
      JalD = 0;
    end
     6'h09: begin //addiu
      RegWriteD = 1;
      MemtoRegD = 0;
      MemWriteD = 0;
      BranchD = 0;
      ALUControlD = 6'b100010;
      ALUSrcD = 1;
      RegDstD = 0;
      JumpD = 0;
      JalD = 0;
    end
    6'h0C: begin //andi
      RegWriteD = 1;
      MemtoRegD = 0;
      MemWriteD = 0;
      BranchD = 0;
      ALUControlD = 6'b000000;
      ALUSrcD = 1;
      RegDstD = 0;
      JumpD = 0;
      JalD = 0;
    end
    6'h04: begin //beq
      RegWriteD = 0;
      //MemtoRegD don't care
      MemWriteD = 0;
      BranchD = 1;
      ALUControlD = 6'b001101;
      ALUSrcD = 0;
      RegDstD = 0;
      JumpD = 0;
      JalD = 0;
    end
    6'h05: begin //bne
      RegWriteD = 0;
      //MemtoRegD don't care
      MemWriteD = 0;
      BranchD = 1;
      ALUControlD = 6'b011110;
      ALUSrcD = 0;
      RegDstD = 0;
      JumpD = 0;
      JalD = 0;
    end
    6'h23: begin //lw
      RegWriteD = 1;
      MemtoRegD = 1;
      MemWriteD = 0;
      BranchD = 0;
      ALUControlD = 6'b000010;
      ALUSrcD = 1;
      RegDstD = 0;
      JumpD = 0;
      JalD = 0;
    end
    6'h0D: begin //ori
      RegWriteD = 1;
      MemtoRegD = 0;
      MemWriteD = 0;
      BranchD = 0;
      ALUControlD = 6'b000101;
      ALUSrcD = 1;
      RegDstD = 0;
      JumpD = 0;
      JalD = 0;
    end
    6'h2B: begin //sw
      RegWriteD = 0;
      //MemtoRegD don't care
      MemWriteD = 1;
      BranchD = 0;
      ALUControlD = 6'b000010;
      ALUSrcD = 1;
      RegDstD = 0;
      JumpD = 0;
      JalD = 0;
    end
    6'h0E: begin //xori
      RegWriteD = 1;
      MemtoRegD = 0;
      MemWriteD = 0;
      BranchD = 0;
      ALUControlD = 6'b001111;
      ALUSrcD = 1;
      RegDstD = 0;
      JumpD = 0;
      JalD = 0;
    end
    6'h02: begin //j
      RegWriteD = 0;
      MemtoRegD = 0;
      MemWriteD = 0;
      BranchD = 0;
      ALUControlD = 6'b111110;
      ALUSrcD = 0;
      RegDstD = 0;
      JumpD = 1;
      JalD = 0;
    end
    6'h03: begin //jal
      RegWriteD = 1;
      MemtoRegD = 0;
      MemWriteD = 0;
      BranchD = 0;
      ALUControlD = 6'b111110;
      ALUSrcD = 0;
      RegDstD = 0;
      JumpD = 0;
      JalD = 1;
    end
    default: begin
      RegWriteD = 0;
      MemtoRegD = 0;
      MemWriteD = 0;
      BranchD = 0;
      ALUControlD = 6'b111111;
      ALUSrcD = 0;
      RegDstD = 0;
      JumpD = 0;
      JalD = 0;
    end

  endcase
end

reg[4:0] regAddr1, regAddr2, regAddr3;
always @(A1, A2, A3, WD3, WE3) begin
  //RD1 shift if Func
  regAddr1 = A1;
  regAddr2 = A2;
  regAddr3 = A3;
  //$display("%b %b", A1, A2);

  if(RegWriteW) begin
    reg_file[regAddr3] = WD3;
    //$display("%b %b", regAddr3, WD3);
  end
  RD1 = reg_file[regAddr1];
  RD2 = reg_file[regAddr2];
  if(Op==6'b000000 && (Funct==6'b000000||Funct==6'b000011||Funct==6'b000010)) begin
      RD1 = SA;
      //$display("%b", RD1);
  end
  //$display("%b %b", regAddr1, regAddr2);
  //$display("%b", RD1);
end

reg EqualD;
always @(RD1, RD2) begin
  if(ALUControlD == 6'b001101) begin //beq
    if(RD1==RD2)
      EqualD = 1;
    else
      EqualD = 0;
  end
  if(ALUControlD == 6'b011110) begin  //bne
    if(RD1!=RD2)
      EqualD = 0;
    else
      EqualD = 1;
  end
  //$display("%b", EqualD);
end

always @(BranchD, EqualD) begin
  PCSrcD = BranchD & EqualD;
  BranchCLRF = PCSrcD ? 1 : 0;
  BranchCLRD = PCSrcD ? 1 : 0;
end

reg signed[31:0] SignImmShftD;
always @(SignExtend) begin
  if(Op == 6'b001100 || Op == 6'b001101 || Op == 6'b001110) begin
    SignImmD = {16'h0000, SignExtend[15:0]};
  end
  else begin
    if(SignExtend[15])
      SignImmD = {16'hFFFF, SignExtend[15:0]};
    else
      SignImmD = {16'h0000, SignExtend[15:0]};
    SignImmShftD = $signed(SignImmD) << 2;
  end
end

always @(PCPlus4D, SignImmShftD) begin
  PCBranchD = SignImmShftD + PCPlus4D;
end

always @(ALUControlD, JumpD, JalD) begin
  if(ALUControlD==6'b000011) begin  //jr
    JCLRD = 1;
    JCLRF = 1;
    JD = 1;
    PCJump = RD1;
  end
  if(JumpD) begin
    JCLRD = 1;
    JCLRF = 1;
    JD = 1;
    PCJump = {PCPlus4D[31:28], target, 2'b00};
  end
  if(JalD) begin
    JCLRD = 1;
    JCLRF = 1;
    JD = 1;
    PCJump = {PCPlus4D[31:28], target, 2'b00};
    reg_file[31] = PCPlus4D;
  end
  else begin
    JCLRD = 0;
    JCLRF = 0;
    JD = 0;
  end
end

always @(posedge CLK) begin
  //$display("%b %b %b", RsD, RtD, RdD);
  //$display("%b", ALUControlD); 
  RsE <= RsD;
  RtE <= RtD;
  RdE <= RdD;
  RegWriteE <= RegWriteD;
  MemtoRegE <= MemtoRegD;
  MemWriteE <= MemWriteD;
  ALUControlE <= ALUControlD;
  ALUSrcE <= ALUSrcD;
  RegDstE <= RegDstD;
  SrcAE <= RD1;
  SignImmE <= SignImmD;
  WriteDataE <= RD2;
  //$display("%b", SignImmE);
end 

always @(ALUSrcE, WriteDataE, SignImmE) begin
  if(ALUSrcE) begin
    SrcBE = SignImmE;
  end
  else begin
    SrcBE = WriteDataE;
  end
  //$display("%b", SrcBE);
end

always @(RegDstE, RtE, RdE) begin  //if next clock cycle, all wires are the same, create a wire 1 to 0
  if(RegDstE)
    WriteRegE = RdE;
  else
    WriteRegE = RtE;
end  

always @(ALUControlE, SrcAE, SrcBE) begin
  //$display("%b %b", SrcAE, SrcBE);
  flag = 3'b000;
  case(ALUControlE)
    6'b000010: begin
      ALUOutE = $signed(SrcAE) + $signed(SrcBE);
      if((SrcAE[31]&&SrcBE[31]&&!ALUOutE[31])||(!SrcAE[31]&&!SrcBE[31]&&ALUOutE[31]))
        flag = 3'b001;
    end
    6'b100010: begin
      ALUOutE = SrcAE + SrcBE;
      flag = 3'b000;
    end
    6'b000000: begin
      ALUOutE = SrcAE & SrcBE;
      flag = 3'b000;
    end
    6'b000011: begin  //JR
      ALUOutE = SrcAE;
      flag = 3'b000;
    end
    6'b000100: begin  //nor
      ALUOutE = ~(SrcAE|SrcBE);
      flag = 3'b000;
    end
    6'b000101: begin //or
      ALUOutE = SrcAE|SrcBE;
      flag = 3'b000;
    end 
    6'b000110: begin  //sll sllv
      ALUOutE = SrcBE << SrcAE;
      flag = 3'b000;
    end
    6'b001000: begin  //slt
      if($signed(SrcAE) < $signed(SrcBE)) begin
        ALUOutE = 1;
        flag[1] = 1;
      end
      else begin
        ALUOutE = 0;
        flag[1] = 0;
      end
    end
    6'b001001: begin //sra srav
      ALUOutE = $signed(SrcBE) >>> ($signed(SrcAE));
      flag = 3'b000;
    end
    6'b001011: begin  //srl srlv
      ALUOutE = SrcBE >> SrcAE;
      flag = 3'b000;
    end
    6'b001101: begin  //sub beq
      ALUOutE = $signed(SrcAE) - $signed(SrcBE);
      if((SrcAE[31]&&!SrcBE[31]&&!ALUOutE[31])||(!SrcAE[31]&&SrcBE[31]&&ALUOutE[31]))
        flag[0] = 1;
      else 
        flag[0] = 0;
    end
    6'b001110: begin  //subu
      ALUOutE = SrcAE - SrcBE;
      flag = 3'b000;
    end
    6'b001111: begin  //xor
      ALUOutE = SrcAE ^ SrcBE;
      flag = 3'b000;
    end
    
  endcase
  //$display("%b", ALUOutE);
end

always @(posedge CLK) begin
  RegWriteM  <=  RegWriteE;
  MemtoRegM  <=  MemtoRegE;
  MemWriteM  <=  MemWriteE;
  WriteRegM  <=  WriteRegE;
  WriteDataM <=  WriteDataE;
  ALUOutM    <=  ALUOutE;
end

MainMemory data_ram(
    .CLOCK(CLK), 
    .RESET(Disable),  
    .ENABLE(Enable), 
    .FETCH_ADDRESS(ALUOutM),  
    .EDIT_SERIAL({MemWriteM, ALUOutM[31:0]>>2, WriteDataM[31:0]}),  
    .DATA(RD_Data));

always @(posedge CLK) begin
  RegWriteW <= RegWriteM;
  MemtoRegW <= MemtoRegM;
  ALUOutW <= ALUOutM;
  ReadDataW <= RD_Data;
  WriteRegW <= WriteRegM;
  //$display("%b", RegWriteW);
end

always @(MemtoRegW, ReadDataW, ALUOutW) begin
  if(MemtoRegW) begin
    ResultW = ReadDataW;
  end
  else if(!MemtoRegW) begin
    ResultW = ALUOutW;
  end
  //$display("%b", ResultW);
end

endmodule