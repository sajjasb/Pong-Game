// Note: This code is written to support monitor display resolutions of 1280 x 1024 at 60 fps

// (DETAILS OF THE MODULES)
// VGAInterface.v is the top most level module and asserts the red/green/blue signals to draw to the computer screen
// VGAController.v is a submodule within the top module used to generate the vertical and horizontal synch signals as well as X and Y pixel positions
// VGAFrequency.v is a submodule within the top module used to generate a 108Mhz pixel clock frequency from a 50Mhz pixel clock frequency using the PLL

// (USER/CODER Notes) 
// Note: User should modify/write code in the VGAInterface.v file and not modify any code written in VGAController.v or VGAFrequency.v

module VGAInterface(

	//////////// CLOCK //////////
	CLOCK_50,

	//////////// LED //////////
	LEDR,

	//////////// KEY //////////
	KEY,

	//////////// SW //////////
	SW,

	//////////// SEG7 //////////
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,

	//////////// VGA //////////
	VGA_B,
	VGA_CLK,
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_VS 
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input		          		CLOCK_50;

//////////// LED //////////
output		    [9:0]		LEDR;

//////////// KEY //////////
input		     [3:0]		KEY;

//////////// SW //////////
input		    [9:0]		SW;

//////////// SEG7 //////////
output		     [6:0]		HEX0;
output		     [6:0]		HEX1;
output		     [6:0]		HEX2;
output		     [6:0]		HEX3;
output		     [6:0]		HEX4;
output		     [6:0]		HEX5;

//////////// VGA //////////
output		     [3:0]		VGA_B;
output		          		VGA_CLK;
output		     [3:0]		VGA_G;
output		          		VGA_HS;
output		     [3:0]		VGA_R;
output		          		VGA_VS;

//=======================================================
//  REG/WIRE declarations
//=======================================================
//reg	aresetPll = 0; // asynchrous reset for pll
wire 	pixelClock;
wire	[10:0] XPixelPosition;
wire	[10:0] YPixelPosition; 
reg	[7:0] redValue;
reg	[7:0] greenValue;
reg	[7:0] blueValue;

reg	[1:0] movement = 0;
parameter r = 15;

// slow clock counter variables
reg 	[31:0] slowClockCounter = 0;
wire 	slowClock;

// fast clock counter variables
reg 	[31:0] fastClockCounter = 0;
wire 	fastClock;

// variables for the dot 
reg	[10:0] XDotPosition = 500;
reg	[10:0] YDotPosition = 500; 

// variables for paddle 1 
reg	[10:0] P1x = 225;
reg	[10:0] P1y = 500;

// variables for paddle 2
reg	[10:0] P2x = 1030;
reg	[10:0] P2y = 500;

// variables for player scores
reg 	[3:0] P1Score = 0;
reg	[3:0] P2Score = 0;
reg 	flag =1'b0;

parameter RIGHT_BORDER = 1120;
parameter LEFT_BORDER = 160;
parameter TOP_BORDER = 128;
parameter BOTTOM_BORDER = 896;

//=======================================================
//  Structural coding
//=======================================================

// output assignments		
assign VGA_CLK = pixelClock;

// display the X or Y position of the dot on LEDS (Binary format)
// MSB is LEDR[10], LSB is LEDR[0]
assign LEDR[9:0] = SW[1] ? YDotPosition : XDotPosition; 

assign slowClock = slowClockCounter[20]; // take MSB from counter to use as a slow clock
assign fastClock = fastClockCounter[20]; // take Middle Bit from counter to use as a slow clock

always@ (posedge CLOCK_50) // generates a slow clock by selecting the MSB from a large counter
begin
	slowClockCounter <= slowClockCounter + 1;
	fastClockCounter <= fastClockCounter + 1;
end


always@(posedge fastClock) // process moves the y position of player1 paddle
begin
if (SW[0] == 1'b0) 
begin
	if (KEY[2] == 1'b0 && KEY[3] == 1'b0) 
		P1y <= P1y;
	else if (KEY[2] == 1'b0) begin
		if (P1y+125 >BOTTOM_BORDER)
			P1y <= 771;
		else
		P1y <= P1y + 10;
		end
	else if (KEY[3] == 1'b0) begin
		if(P1y < TOP_BORDER)
			P1y <= TOP_BORDER;
		else
		P1y <= P1y - 10;
		end
end
else if (SW[0] == 1'b1 || flag==1)
P1y <= 500;
//flag =1'b0;
end

always@(posedge fastClock) // process moves the y position of player2 paddle
begin
if (SW[0] == 1'b0) 
begin
	if (KEY[0] == 1'b0 && KEY[1] == 1'b0) 
		P2y <= P2y;
	else if (KEY[0] == 1'b0) begin
		if(P2y+125 > BOTTOM_BORDER)
			P2y <= 771;
		else
		P2y <= P2y + 10;
		end
	else if (KEY[1] == 1'b0) begin
		if(P2y < TOP_BORDER)
			P2y <= TOP_BORDER;
		else
		P2y <= P2y - 10;
		end
end
else if (SW[0] == 1'b1 || flag ==1)
	P2y <= 500;
end

always@(posedge slowClock) // Moves Ball
begin
if (SW[0] == 1'b0)
	begin
	case(movement)
		0:		begin //Ball moves in NE direction
				XDotPosition <= XDotPosition + 5;
				YDotPosition <= YDotPosition - 5;
				end
		1:		begin //Ball moves in SE direction
				XDotPosition <= XDotPosition + 5;
				YDotPosition <= YDotPosition + 5;
				end
		2:		begin //Ball moves in SW direction
				XDotPosition <= XDotPosition - 5;
				YDotPosition <= YDotPosition + 5;
				end
		3:		begin //Ball moves in NW direction
				XDotPosition <= XDotPosition - 5;
				YDotPosition <= YDotPosition - 5;
				end
	endcase
	
	if(YDotPosition - r <= TOP_BORDER && movement == 0) //bounce top wall from NE
		movement = 1;
	else if (YDotPosition - r <= TOP_BORDER && movement == 3)// bounce top wall from NW
		movement = 2;
	else if (YDotPosition + r >= BOTTOM_BORDER && movement == 1)	// bounce bottom wall from SE
		movement = 0;
	else if (YDotPosition + r >= BOTTOM_BORDER && movement == 2) // bounce bottom wall from Sw
		movement = 3;
	else if (XDotPosition -r <= P1x+25 && YDotPosition > P1y && YDotPosition < P1y+125 &&  movement == 2)//bounce left paddle from SW
		movement = 1;
	else if (XDotPosition -r<= P1x+25 && YDotPosition > P1y && YDotPosition < P1y+125 &&  movement == 3)//bounce left paddle from NW
		movement = 0;
	else if (XDotPosition + r >= P2x && YDotPosition > P2y && YDotPosition < P2y+125 &&  movement == 1)//bounce right paddle from SE 
		movement = 2;
	else if (XDotPosition + r >= P2x && YDotPosition > P2y && YDotPosition < P2y+125 &&  movement == 0)//bounce right paddle from NE
		movement = 3;
	else if (XDotPosition - r <= LEFT_BORDER) begin
		P2Score = P2Score + 1;
		//reset ball
		XDotPosition <= 640;
		YDotPosition <= 512;
		end
	else if (XDotPosition + r >= RIGHT_BORDER)begin
		P1Score = P1Score + 1;
		//reset ball
		XDotPosition <= 640;
		YDotPosition <= 512;
		end
		
		if(P1Score == 10 || P2Score ==10) begin
			P1Score<=0;
			P2Score<=0;
			flag <=1;
			end
end
else //reset ball and score
	begin
	XDotPosition <= 500;
	YDotPosition <= 500;
	P1Score <= 0;
	P2Score <= 0;
	end
	
end

assign pixelClock = CLOCK_50;
// VGA Controller Module used to generate the vertial and horizontal synch signals for the monitor and the X and Y Pixel position of the monitor display
VGAController VGAControl (CLOCK_50, redValue, greenValue, blueValue, VGA_R, VGA_G, VGA_B, VGA_VS, VGA_HS, XPixelPosition, YPixelPosition);



// COLOR ASSIGNMENT PROCESS (USER WRITES CODE HERE TO DRAW TO SCREEN)
always@ (posedge pixelClock)
begin
	
	begin
		if (XPixelPosition < LEFT_BORDER) //set left green border
		begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b11111111;
		end
		else if (XPixelPosition > RIGHT_BORDER) // set right green border
		begin
			redValue <= 8'h00; 
			blueValue <= 8'h00;
			greenValue <= 8'hff;
		end
		else if (YPixelPosition < TOP_BORDER) //set top magenta border
		begin
			redValue <= 8'hff; 
			blueValue <= 8'hff;
			greenValue <= 8'h00;
		end
		else if (YPixelPosition > BOTTOM_BORDER) // set bottom magenta border
		begin
			redValue <= 8'hff; 
			blueValue <= 8'hff;
			greenValue <= 8'b00000000;
		end
		else if (XPixelPosition > P1x && XPixelPosition < P1x+25 && YPixelPosition > P1y && YPixelPosition < P1y+125) // draw player 1 paddle
		begin
			redValue <= 8'h00; 
			blueValue <= 8'hff;
			greenValue <= 8'hff;
		end
		else if (XPixelPosition > P2x && XPixelPosition < P2x+25 && YPixelPosition > P2y && YPixelPosition < P2y+125) // draw player 2 paddle
		begin
			redValue <= 8'b00000000; 
			blueValue <= 8'hff;
			greenValue <= 8'hff;
		end
		//draw ball using (x-a)^2 + (y-b)^2 = r^2 where (a,b) is the center of the circle and r = 15
		//a = XDotPosition, b = YDotPosition
		else if (((XPixelPosition-XDotPosition)**2 
						+ (YPixelPosition-YDotPosition)**2) < 15**2) 
		begin
			redValue <= 8'hff; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
		end
		else // default background is black
		begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
		end
	end
end

ScoreDecoder p1(P1Score, HEX1, HEX0);
ScoreDecoder p2(P2Score, HEX5, HEX4);

endmodule


