// TESTBENCH

`timescale 1ns/1ps
module BasicComputer_tb();

reg clk;
wire [15:0] IR;
wire [15:0] TR;
wire [15:0] DR;
wire [15:0] AC;
wire [11:0] PC;
wire [11:0] AR;
wire [2:0] SC;

// instantiate device under test using named port mapping
BasicComputer dut (
    .IR(IR),
    .TR(TR),
    .DR(DR),
    .AC(AC),
    .PC(PC),
    .AR(AR),
    .clk(clk),
    .SC(SC)
);

always begin
    clk = 1; #10; clk = 0; #10;
    
end

endmodule