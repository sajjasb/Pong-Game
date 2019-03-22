`default_nettype none

`define RIGHT_BORDER 1120
`define LEFT_BORDER 160
`define TOP_BORDER 128
`define BOTTOM_BORDER 896

module gameServer (
	input logic clock, reset_n,

	input logic [10:0] n1P1_y,
	output logic [10:0] n1P2_y,

	input logic [10:0] n2P1_y,
	output logic [10:0] n2P2_y,
	
	input logic [10:0] n3P1_y,
	output logic [10:0] n3P2_y,
	
	input logic [10:0] n4P1_y,
	output logic [10:0] n4P2_y,

	output logic [10:0] game1Ball_x,
	output logic [10:0] game1Ball_y,

	output logic [10:0] game2Ball_x,
	output logic [10:0] game2Ball_y
	
	//add signals to communicate with sender and transmitter modules

	);

	//for now assume n1 and n2 are playing a game
	//cannot do direct assign as both players are player 1 on their machine
	assign n1P2_y = n2P1_y; 
	assign n2P2_y = n1P1_y; 

	//for now maintain only 1 balls position
	logic [2:0] movement;
	logic flag;
	
	always_ff @(posedge clock or negedge reset_n) begin
		logic [10:0] P1x = 225;
		logic [10:0] P2x = 1030;
		logic [10:0] r = 15;
		
		
		if(~reset_n) begin
			game1Ball_x <= 500;
			game1Ball_y <= 500;
			movement <= 0;
		end
		else begin
			case(movement)
				0:	begin //Ball moves in NE direction
					game1Ball_x <= game1Ball_x + 5;
					game1Ball_y <= game1Ball_y - 5;
				end
				1:	begin //Ball moves in SE direction
					game1Ball_x <= game1Ball_x + 5;
					game1Ball_y <= game1Ball_y + 5;
					end
				2:	begin //Ball moves in SW direction
					game1Ball_x <= game1Ball_x - 5;
					game1Ball_y <= game1Ball_y + 5;
				end
				3:	begin //Ball moves in NW direction
					game1Ball_x <= game1Ball_x - 5;
					game1Ball_y <= game1Ball_y - 5;
				end
			endcase
			
			if(game1Ball_y - r <= `TOP_BORDER && movement == 0) //bounce top wall from NE
				movement <= 1;
			else if (game1Ball_y - r <= `TOP_BORDER && movement == 3)// bounce top wall from NW
				movement <= 2;
			else if (game1Ball_y + r >= `BOTTOM_BORDER && movement == 1)	// bounce bottom wall from SE
				movement <= 0;
			else if (game1Ball_y + r >= `BOTTOM_BORDER && movement == 2) // bounce bottom wall from Sw
				movement <= 3;
			else if (game1Ball_x -r <= P1x+25 && game1Ball_y > n1P1_y && game1Ball_y < n1P1_y+125 &&  movement == 2)//bounce left paddle from SW
				movement <= 1;
			else if (game1Ball_x -r<= P1x+25 && game1Ball_y > n1P1_y && game1Ball_y < n1P1_y+125 &&  movement == 3)//bounce left paddle from NW
				movement <= 0;
			else if (game1Ball_x + r >= P2x && game1Ball_y > n2P1_y && game1Ball_y < n2P1_y+125 &&  movement == 1)//bounce right paddle from SE 
				movement <= 2;
			else if (game1Ball_x + r >= P2x && game1Ball_y > n2P1_y && game1Ball_y < n2P1_y+125 &&  movement == 0)//bounce right paddle from NE
				movement <= 3;
			else if (game1Ball_x - r <= `LEFT_BORDER) begin
				game1Ball_x <= 500;
				game1Ball_y <= 500;
			end
			else if (game1Ball_x + r >= `RIGHT_BORDER)begin
				game1Ball_x <= 500;
				game1Ball_y <= 500;
			end
		end
	end


	
endmodule: gameServer