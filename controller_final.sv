module up_counter_4bit (input wire clk, input wire T, input wire reset, output reg [3:0] count);
	always @(posedge clk) begin
		if (reset) count <= 4'b0000;
		else if (T) count <= count + 4'd1;
	end
endmodule

module controller (input clk, reset, NB, SB, output reg TR, TY, TG, PR, PG);
	reg [2:0] currState;
	reg [2:0] nextState;
	reg counter_reset;
	reg counter_count;
	reg open_traf;
	wire [3:0] count;
	up_counter_4bit counter(clk, counter_count, counter_reset, count);

	parameter stateA = 3'b000, stateB = 3'b001, stateC = 3'b010, stateD = 3'b011, stateE = 3'b100, stateF = 3'b101, stateG = 3'b110;
	// Managing the open_traf signal (would allow the system to remember that the passage has been requested in the event it had during its operation)
	// Positive edge ensures that at the button press this occurs once (doesn't lock up the signal)
  	always @(posedge NB, posedge SB) open_traf <= 1'b1;

	// Managing the counter reset
	always @(posedge clk) if (counter_reset) counter_reset <= 1'b0;

	// Managing the current state
	always @(posedge clk, posedge reset) begin		
		if (reset) begin
		currState <= stateA;
		counter_reset <= 1'b1;
		counter_count <= 1'b0;
		open_traf <= 1'b0;
		end else currState <= nextState;
	end

	// Managing the next state
	always @(currState, open_traf, count) begin
		case (currState)
			stateA: begin
			if (!open_traf) nextState <= stateA;
			else begin
				counter_reset <= 1'b1;
				counter_count <= 1'b1;
              	nextState <= stateB;
			end
			end
			stateB: begin
              	if (!count) open_traf <= 1'b0; // Correctly handle traffic signal to reset to unpressed as soon as traffic cycle begins
				else if (count == 4'b0001) begin
					counter_reset <= 1'b1;
					counter_count <= 1'b1; // Assertion
					nextState <= stateC;
				end else nextState <= stateB;
			end
			stateC: begin
				if (count == 4'b0001) begin
				counter_reset <= 1'b1;
				counter_count <= 1'b1; // Assertion
				nextState <= stateD;
				end else nextState <= stateC;
			end
			stateD: begin
				if (count == 4'b0101) begin
				counter_reset <= 1'b1;
				counter_count <= 1'b1; // Assertion
				nextState <= stateE;
				end else nextState <= stateD;
			end
			stateE: begin
				if (count == 4'b0101) begin
				counter_reset <= 1'b1;
				counter_count <= 1'b1; // Assertion
				nextState <= stateF;
				end else nextState <= stateE;
			end
			stateF: begin
				if (count == 4'b0001) begin
				counter_reset <= 1'b1;
				counter_count <= 1'b1; // Assertion
				nextState <= stateG;
				end else nextState <= stateF;
			end
			stateG: begin
				if (count == 4'b1011) begin
				if (!open_traf) begin // Go directly to state A after 12 cycles
					counter_reset <= 1'b1;
					counter_count <= 1'b0;
					nextState <= stateA;
				end
				else begin // Skip state A, and restart traffic procedure
				counter_reset <= 1'b1;
				counter_count <= 1'b1;
				nextState <= stateB;
				end
				end else nextState <= stateG;
			end
		endcase
	end
	
	// Managing the output
	always @(currState, clk) begin
		case (currState)
			stateA: begin
				TR <= 1'b0;
				TY <= 1'b0;
				TG <= 1'b1;
				PR <= 1'b1;
				PG <= 1'b0;
			end
			stateB: begin
				TR <= 1'b0;
				TY <= 1'b1;
				TG <= 1'b0;
				PR <= 1'b1;
				PG <= 1'b0;
			end
			stateC: begin
				TR <= 1'b1;
				TY <= 1'b0;
				TG <= 1'b0;
				PR <= 1'b1;
				PG <= 1'b0;
			end
			stateD: begin
				TR <= 1'b1;
				TY <= 1'b0;
				TG <= 1'b0;
				PR <= 1'b0;
				PG <= 1'b1;
			end
			stateE: begin
				TR <= 1'b1;
				TY <= 1'b0;
				TG <= 1'b0;
				PR <= 1'b0;
				PG <= ~clk; // Could be clk, but this was nicer in my opinion.
			end
			stateF: begin
				TR <= 1'b1;
				TY <= 1'b0;
				TG <= 1'b0;
				PR <= 1'b1;
				PG <= 1'b0;
			end
			stateG: begin
				TR <= 1'b0;
				TY <= 1'b0;
				TG <= 1'b1;
				PR <= 1'b1;
				PG <= 1'b0;
			end
		endcase
	end
endmodule

module controller_tb2();
	reg clk_tb, reset_tb, NB_tb, SB_tb;
	wire TR_tb, TY_tb, TG_tb, PR_tb, PG_tb;
	always
	#2 clk_tb = ~ clk_tb;
  	controller TB(clk_tb, reset_tb, NB_tb, SB_tb, TR_tb, TY_tb, TG_tb, PR_tb, PG_tb);
	initial begin
		$dumpfile("controller_dump.vcd");
		$dumpvars(1);
		clk_tb = 1'b1;
		reset_tb = 1'b1;
     	NB_tb = 1'b0;
      	SB_tb = 1'b0;
		#4;
		reset_tb = 1'b0;
		NB_tb = 1'b1;
		#4;
		NB_tb = 1'b0;
		#40;
		SB_tb = 1'b1;
		#4;
		SB_tb = 1'b0;
		#100;
		NB_tb = 1'b1;
		#400;
      $finish;
	end
endmodule