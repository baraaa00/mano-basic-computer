`timescale 1ns / 1ps

module BasicComputer(IR,TR,DR,AC,PC,AR,clk,SC);

input clk;

output reg [15:0] AC;
output reg [15:0] IR;
output reg [15:0] DR;
output reg [15:0] TR;
output reg [11:0] PC;
output reg [11:0] AR;

reg [11:0] OUTR;
reg [11:0] INPR;

reg [15:0] MEM [4095:0];

reg I;
reg E;
reg S;
reg FGO;
reg FGI;
reg IEN;
output reg [2:0] SC;
// initialize memory with random words
initial
begin
SC <= 0;
IR <= 0;
TR <= 0;
DR <= 0;
AC <= 0;
PC <= 0;
AR <= 0;
OUTR <= 0;
INPR <= 0;
I<=0;
E<=0;
S <= 1;
FGO <=0;
FGI <=0;
IEN <=0;

$readmemh("mem_data.txt", MEM);

end

always @(posedge clk)
begin
	//start fetch
	if (SC == 0) begin	
		AR <= PC;
		SC <= SC + 1; end
	
	else if (SC == 1) begin
		IR <= MEM[AR[11:0]]; 
		PC <= PC + 1;		
		SC <= SC + 1; end
	
	else if (SC == 2) begin
		AR <= IR[11:0];
		I <= IR[15];
		SC <= SC +1; end
	//end fetch
	
	else begin
		if (IR[14:12] == 3'b111) begin
			if(I == 0) begin //Register-reference instructions
				
				if(AR[11] == 1) begin //CLA
					AC <= 0;
					SC <= 0; end
					
				else if(AR[10] == 1) begin //CLE
					E <= 0;
					SC <= 0; end
					
				else if(AR[9] == 1) begin //CMA
					AC <= ~AC;
					SC <= 0; end
					
				else if(AR[8] == 1) begin //CME
					E <= ~E;
					SC <= 0; end
					
				else if(AR[7] == 1) begin //CIR
					AC <= (AC >> 1); 
					AC[15] <= E;
					E <= AC[0];
					SC <= 0; end
					
				else if(AR[6] == 1) begin //CIL
					AC <= (AC << 1);
					AC[0] <= E;
					E <= AC[15];
					SC <= 0; end
					
				else if(AR[5] == 1) begin //INC
					AC <= AC + 1;
					SC <= 0; end
					
				else if(AR[4] == 1) begin //SPA
					if ( AC [15] == 0)
						PC <= PC +1;
					SC <= 0;
					end
				else if(AR[3] == 1) begin //SNA
					if ( AC [15] == 1)
						PC <= PC +1;
					SC <= 0;
					end
				else if(AR[2] == 1) begin //SZA
					if ( AC == 0)
						PC <= PC +1;
					SC <= 0;
					end
				else if(AR[1] == 1) begin //SZE
					if ( E == 0)
						PC <= PC +1;
					SC <= 0;
					end
				else begin // HLT
					S <= 0;
					SC <= 0; end
			end
            else if (I==1) begin //I/O instructions
                if (AR[11] == 1) begin //INP
                        AC[7:0]<=INPR;
                        FGI <= 0;
                        SC <= 0;
                    end
                else if (AR[10] == 1) begin //OUT
                        OUTR <= AC[7:0];
                        FGO <= 0;
                        SC <= 0;
                    end
                else if (AR[9]==1) begin //SKI
                    if (FGI == 1) begin
                        PC <= PC + 1;
                    end
                    SC <= 0;
                end
                else if (AR[8]==1) begin //SKO
                    if (FGO == 1) begin
                        PC <= PC + 1;
                    end
                    SC <= 0;
                end
                else if (AR[7] == 1) begin //ION
                        IEN <= 1;
                        SC <= 0;
                    end
                else if (AR[6] == 1) begin //IOF
                        IEN <= 0;
                        SC <= 0;
                    end
            end 
		end 		
		else begin //not D7 // Memory reference instructions
				if (SC == 3) begin
                    if(I == 1) AR <= MEM[AR[11:0]]; //Indirect
					SC <= SC + 1; end
				else begin //direct
					if(IR[14:12] == 3'b000) begin //AND
						if(SC == 4) begin
							DR <= MEM[AR[11:0]]; 
							SC <= SC + 1; end
						else begin
							AC <= (AC & DR);
							SC <= 0; end
					end
					else if(IR[14:12] == 3'b001) begin //ADD 
						if(SC == 4) begin
							DR <= MEM[AR[11:0]]; 
							SC <= SC + 1; end
						else begin
							{E,AC} <= AC + DR;
							SC <= 0; end
					end
					else if(IR[14:12] == 3'b010) begin //LDA
						if(SC == 4) begin
							DR <= MEM[AR[11:0]]; 
							SC <= SC + 1; end
						else begin
							AC <= DR;
							SC <= 0; end
					end		
					else if(IR[14:12] == 3'b011) begin//STA
						MEM[AR[11:0]] <= AC ; 
						SC <= 0;
					end
					else if(IR[14:12] == 3'b100) begin //BUN
						PC <= AR;
						SC <= 0;
					end
					else if(IR[14:12] == 3'b101) begin //BSA
						if (SC == 4) begin
							MEM[AR[11:0]] <= PC; 
							AR <= AR + 1; end
						else begin
							PC <= AR;
							SC <= 0; end
					end		
					else if(IR[14:12] == 3'b110) begin //ISZ
						if (SC == 4) begin
							DR <= MEM[AR[11:0]]; 
							SC <= SC +1; end
						else if(SC ==5) begin
							DR <= DR +1;
							SC <= SC +1; end
						else begin
							MEM[AR[11:0]] <= DR; 
								if(DR == 0)
									PC <= PC +1;
							SC <= SC +1; end
				    end
			end
		end 		
	end 
end
endmodule
