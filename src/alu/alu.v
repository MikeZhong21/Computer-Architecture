// instruction: 32-bit instruction
// regA/B: 32-bit data in registerA(addr=00000), registerB(addr=00001)
// result: 32-bit result of Alu execution
// flags: 3-bit alu flag
// flags[2] : zero flag
// flags[1] : negative flag
// flags[0] : overflow flag 
module alu(input[31:0] instruction, input[31:0] regA, input[31:0] regB, output signed[31:0] result, output[2:0] flags);
    reg[5:0] opcode, func;
    reg[4:0] rs, rt, rd, sa;
    reg signed[31:0] sign_regA, sign_regB, sign_regs, sign_regt;
    reg [15:0] immed;
    reg [31:0] temp, regs, regt, regd;
    reg[2:0] flag;
    reg signed[31:0] res;

    always @(instruction, regA, regB) begin
        opcode = instruction[31:26];
        func = instruction[5:0];
        rs = instruction[25:21];
        rt = instruction[20:16];
        rd = instruction[15:11];
        sa = instruction[10:6];
        immed = instruction[15:0];

        sign_regA = $signed(regA);
        sign_regB = $signed(regB);
        flag = 3'b000;
        res = 32'h00000000;

        if(rs[0])begin
            regs = regB;
            sign_regs = sign_regB;
        end
        else begin
            regs = regA;
            sign_regs = sign_regA;
        end

        if(rt[0])begin
            regt = regB;
            sign_regt = sign_regB;
        end
        else begin
            regt = regA;
            sign_regt = sign_regA;
        end

        case(opcode) 
            6'h00: begin
                case(func)
                    6'h20: begin
                        res = sign_regs + sign_regt;
                        if((regs[31]&&regt[31]&&!res[31])||(!regs[31]&&!regt[31]&&res[31]))
                            flag[0] = 1; 
                    end
                    6'h21: begin
                        res = regs + regt;
                    end
                    6'h24: begin 
                        res = regs & regt;
                    end
                    6'h27: begin
                        res = ~(regs | regt);
                    end    
                    6'h25: begin
                        res = regs | regt;
                    end
                    6'h00: begin //sll
                        temp = sa;
                        if(rt[0])
                            res = regB << temp;
                        if(!rt[0])
                            res = regA << temp;
                    end
                    6'h04: begin //sllv
                            res = regt << sign_regs;
                    end
                    6'h2A: begin //slt
                        if(sign_regs<sign_regt) begin 
                            res = sign_regs - sign_regt;
                            flag[1] = 1;
                        end
                        else begin
                            res = sign_regs - sign_regt;
                            flag[1] = 0;
                        end
                    end
                    6'h2B: begin //sltu
                        if(regs<regt) begin
                            res = regs - regt;
                            flag[1] = 1;
                        end
                        else begin
                            res = regs - regt;
                            flag[1] = 0;
                        end
                    end
                    6'h03: begin //sra
                        temp = sa;
                        if(rt[0])
                            res = sign_regB >>> temp;
                        if(!rt[0])
                            res = sign_regA >>> temp;
                    end
                    6'h07: begin //srav
                        res = sign_regt >>> sign_regs;
                    end
                    6'h02: begin //srl
                        temp = sa;
                        if(rt[0])
                            res = regB >> temp;
                        if(!rt[0])
                            res = regA >> temp;
                    end
                    6'h06: begin //srlv
                        res = regt >> sign_regs;
                    end
                    6'h22: begin //sub
                        res = sign_regs - sign_regt;
                        if((regs[31]&&!regt[31]&&!res[31])||(!regs[31]&&regt[31]&&res[31]))
                            flag[0] = 1;
                    end

                    6'h23: begin //subu
                        res = regs - regt;
                    end
                    6'h26: begin //xor
                        res = regs ^ regt;
                    end
                endcase
            end
            6'h08: begin //addi
                if(immed[15])
                    temp = {16'hFFFF, immed};
                else
                    temp = {16'h0000, immed};
                if(rs[0]) begin
                    res = sign_regB + $signed(temp);
                    if((sign_regB[31]&&temp[31]&&!res[31])||(!sign_regB[31]&&!temp[31]&&res[31]))
                        flag[0] = 1;
                end
                if(!rs[0]) begin
                    res = sign_regA + $signed(temp);
                    if((sign_regA[31]&&temp[31]&&!res[31])||(!sign_regA[31]&&!temp[31]&&res[31]))
                        flag[0] = 1;
                end
            end
            6'h09: begin //addiu
                if(immed[15])
                    temp = {16'hFFFF, immed};
                else
                    temp = {16'h0000, immed};
                if(rs[0])
                    res = regB + temp;
                if(!rs[0])
                    res = regA + temp;
            end
            6'h0C: begin //andi
                temp = {16'h0000, immed};
                if(rs[0])
                    res = regB & temp;
                if(!rs[0])
                    res = regA & temp;
            end
            6'h04: begin //beq
                if(regs-regt==0) begin
                    res = regs-regt;
                    flag[2] = 1; 
                end
                else begin
                    res = regs-regt; 
                    flag[2] = 0;
                end
            end
            6'h05: begin //bne
                if(regs-regt!=0) begin
                    res = regs-regt;
                    flag[2] = 0;
                end
                else begin 
                    res = regs-regt;
                    flag[2] = 1;
                end
            end
            6'h23: begin //lw
                if(immed[15])
                    temp = {16'hFFFF, immed};
                else
                    temp = {16'h0000, immed};
                if(rs[0])
                    res = regB + $signed(temp);
                if(!rs[0])
                    res = regA + $signed(temp);
            end
            6'h0D: begin //ori
                temp = {16'h0000, immed};
                if(rs[0]) 
                    res = regB | temp;
                if(!rs[0]) 
                    res = regA | temp;
            end
            6'h0A: begin //slti
                if(immed[15])
                    temp = {16'hFFFF, immed};
                else
                    temp = {16'h0000, immed};
                if(rs[0]) begin
                    if(sign_regB<$signed(temp)) begin
                        res = sign_regB - $signed(temp);
                        flag[1] = 1;
                    end
                    else begin
                        res = sign_regB - $signed(temp);
                        flag[1] = 0;
                    end
                end
                if(!rs[0]) begin
                    if(sign_regA<$signed(temp)) begin
                        res = sign_regA - $signed(temp);
                        flag[1] = 1;
                    end
                    else begin
                        res = sign_regA - $signed(temp);
                        flag[1] = 0;
                    end
                end
            end
            6'h0B: begin //sltiu
                if(immed[15])
                    temp = {16'hFFFF, immed};
                else
                    temp = {16'h0000, immed};
                if(rs[0]) begin
                    if(regB<temp) begin
                        res = regB - temp;
                        flag[1] = 1;
                    end
                    else begin
                        res = regB - temp;
                        flag[1] = 0;
                    end
                end
                if(!rs[0]) begin
                    if(regA<temp) begin
                        res = regA - temp;
                        flag[1] = 1;
                    end
                    else begin
                        res = regA - temp;
                        flag[1] = 0;
                    end
                end
            end
            6'h2B: begin //sw
                if(immed[15])
                    temp = {16'hFFFF, immed};
                else
                    temp = {16'h0000, immed};
                if(rs[0])
                    res = regB + $signed(temp);
                if(!rs[0])
                    res = regA + $signed(temp);
            end
            6'h0E: begin //xori
                temp = {16'h0000, immed};
                if(rs[0])
                    res = regB ^ temp;
                if(!rs[0])
                    res = regA ^ temp;
            end
        endcase
    end
    assign result = res;
    assign flags = flag;
endmodule
