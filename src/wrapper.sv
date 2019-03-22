`default_nettype none

`define RIGHT_BORDER 1120
`define LEFT_BORDER 160
`define TOP_BORDER 128
`define BOTTOM_BORDER 896

module wrapper(
	input logic clock,
	input logic pixelClock,
	input logic reset_n,
	
	//required for game play
	input logic [10:0] XDotPosition,
	input logic [10:0] YDotPosition,
	input logic [10:0] P2y,
	output logic [10:0] P1y,

	input logic [3:0] KEY,

	//required for game display
	output logic VGA_CLK,
	output logic [3:0] VGA_R,
	output logic [3:0] VGA_G,
	output logic [3:0] VGA_B,
	output logic VGA_HS,
	output logic VGA_VS);


	assign VGA_CLK = pixelClock;

	

	logic	[10:0] XPixelPosition;
	logic	[10:0] YPixelPosition; 
	logic	[7:0] redValue;
	logic	[7:0] greenValue;
	logic	[7:0] blueValue;
	logic	[10:0] P1x = 225;
	logic	[10:0] P2x = 1030;

	logic [31:0] clockCounter;
	logic gameClock;
	assign gameClock = clockCounter[20];
	always_ff @(posedge clock or negedge reset_n) begin
		if(~reset_n) begin
			clockCounter <= 0;
		end else begin
			clockCounter <= clockCounter+1;
		end
	end

	always_ff @(posedge gameClock or negedge reset_n) begin : proc_
		if(~reset_n) begin
			P1y <= 500;
		end
		else begin
			if(KEY[2]==1'b0 && KEY[3]==1'b0) P1y <= P1y;
			
			else if(KEY[2]==1'b0) begin
				if (P1y+125 >`BOTTOM_BORDER)
					P1y <= `BOTTOM_BORDER-125;
				else
					P1y <= P1y + 10;
			end
			
			else if (KEY[3] == 1'b0) begin
				if(P1y < `TOP_BORDER)
					P1y <= `TOP_BORDER;
				else
					P1y <= P1y - 10;
			end	
		end
	end

	VGAController vgactrl (pixelClock, redValue,  greenValue, blueValue, VGA_R, VGA_G, VGA_B, 
	VGA_VS, VGA_HS, XPixelPosition, YPixelPosition);
	
	//code to draw screen
	always_ff @(posedge pixelClock or negedge reset_n) begin : proc_draw
		if (~reset_n) begin
			redValue <= 8'hff; 
			blueValue <= 8'hff;
			greenValue <= 8'hff;
		end
		else if (XPixelPosition < `LEFT_BORDER) //set left green border
		begin
			redValue <= 8'h00; 
			blueValue <= 8'h00;
			greenValue <= 8'hff;
		end
		else if (XPixelPosition > `RIGHT_BORDER) // set right green border
		begin
			redValue <= 8'h00; 
			blueValue <= 8'h00;
			greenValue <= 8'hff;
		end
		else if (YPixelPosition < `TOP_BORDER) //set top magenta border
		begin
			redValue <= 8'hff; 
			blueValue <= 8'hff;
			greenValue <= 8'h00;
		end
		else if (YPixelPosition > `BOTTOM_BORDER) // set bottom magenta border
		begin
			redValue <= 8'hff; 
			blueValue <= 8'hff;
			greenValue <= 8'h00;
		end
		else if (XPixelPosition > P1x && XPixelPosition < P1x+25 && YPixelPosition > P1y && YPixelPosition < P1y+125) // draw player 1 paddle
		begin
			redValue <= 8'h00; 
			blueValue <= 8'hff;
			greenValue <= 8'hff;
		end
		else if (XPixelPosition > P2x && XPixelPosition < P2x+25 && YPixelPosition > P2y && YPixelPosition < P2y+125) // draw player 2 paddle
		begin
			redValue <= 8'h00; 
			blueValue <= 8'hff;
			greenValue <= 8'hff;
		end
		//draw ball using (x-a)^2 + (y-b)^2 = r^2 where (a,b) is the center of the circle and r = 15
		//a = XDotPosition, b = YDotPosition
		else if (((XPixelPosition-XDotPosition)**2 
						+ (YPixelPosition-YDotPosition)**2) < 15**2) 
		begin
			redValue <= 8'hff; 
			blueValue <= 8'h00;
			greenValue <= 8'h00;
		end
		else // default background is black
		begin
			redValue <= 8'h00; 
			blueValue <= 8'h00;
			greenValue <= 8'h00;
		end
	end



endmodule: wrapper