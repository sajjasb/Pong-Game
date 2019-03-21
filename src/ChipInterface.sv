`default_nettype none


module ChipInterface (
	input logic CLOCK_50,
	input logic [3:0] KEY,
	input logic [9:0] SW,

	output logic [9:0] LEDR,
	output logic [3:0] VGA_B,
	output   logic 		VGA_CLK,
	output logic [3:0] VGA_G,
	output   logic		VGA_HS,
	output logic [3:0] VGA_R,
	output    logic		VGA_VS);

	logic [10:0] XDotPosition;
	logic [10:0] YDotPosition;
	logic [10:0] P1y;
	logic [10:0] P2y;
	assign P2y = 500;
	assign XDotPosition = 500;
	assign YDotPosition = 500;

	assign LEDR = SW[1]? P1y : XDotPosition;
	
	logic [3:0] VGA_G_1, VGA_B_1, VGA_R_1;
	logic [3:0] KEY_1;
	logic VGA_CLK_1;
	logic VGA_HS_1, VGA_VS_1;
	
	logic [3:0] VGA_G_2, VGA_B_2, VGA_R_2;
	logic [3:0] KEY_2;
	logic VGA_CLK_2;
	logic VGA_HS_2, VGA_VS_2;
	
	assign VGA_G = SW[9] ? VGA_G_1 : VGA_G_2;
	assign VGA_R = SW[9] ? VGA_R_1 : VGA_R_2;
	assign VGA_B = SW[9] ? VGA_B_1 : VGA_B_2;
	assign VGA_HS = SW[9] ? VGA_HS_1 : VGA_HS_2;
	assign VGA_VS = SW[9] ? VGA_VS_1 : VGA_VS_2;
	assign VGA_CLK = SW[9] ? VGA_CLK_1 : VGA_CLK_2;
	
	
	
	wrapper n0 (.clock(CLOCK_50), .reset_n(SW[0]), .XDotPosition,
		.YDotPosition, .P2y, .P1y, .KEY, .VGA_CLK(VGA_CLK_1), 
		.VGA_G(VGA_G_1), .VGA_B(VGA_B_1), .VGA_R(VGA_R_1), .VGA_HS(VGA_HS_1), .VGA_VS(VGA_VS_1));
		
	logic [10:0] P1y_2;
	wrapper n1 (.clock(CLOCK_50), .reset_n(SW[0]), .XDotPosition,
		.YDotPosition, .P2y(P1y), .P1y(P1y_2), .KEY, .VGA_CLK(VGA_CLK_2), 
		.VGA_G(VGA_G_2), .VGA_B(VGA_B_2), .VGA_R(VGA_R_2), .VGA_HS(VGA_HS_2), .VGA_VS(VGA_VS_2));
		


endmodule: ChipInterface