module up_counter_4bit (input wire clk, input wire T, input wire reset, output reg [3:0] count);
	always @(posedge clk) begin // Notice how reset is not part of the always sensitivity list. The counter is indeed synchronous.
		if (reset == 1'b1) 
		count <= 4'b0000;
		else if (T == 1'b1)
		count <= count + 4'd1;
	end
endmodule

module controller (input clk, reset, NB, SB, output reg TR, TY, TG, PR, PG);
	reg [2:0] currState;
	reg [2:0] nextState;
	reg counter_reset;
	reg counter_count;
	wire [3:0] count;
	up_counter_4bit counter(clk, counter_count, counter_reset, count);
	parameter stateA = 3'b000, stateB = 3'b001, stateC = 3'b010, stateD = 3'b011, stateE = 3'b100, stateF = 3'b101, stateG = 3'b110;
	// Managing the counter reset
	always @(posedge clk) begin
		if (counter_reset) counter_reset <= 1'b0;
	end
	// Managing the current state
	always @(posedge clk, posedge reset) begin		
		if (reset) begin
		currState <= stateA;
		counter_reset <= 1'b1;
		counter_count <= 1'b0;
		end else
		currState <= nextState;
	end
	// Managing the next state
	always @(currState, NB, SB, count) begin
		case (currState)
			stateA: begin
			if (!NB && !SB) nextState <= stateA;
			else if (NB || SB ) begin
				counter_reset <= 1'b1;
				counter_count <= 1'b1;
				nextState <= stateB;
			end
			end
			stateB: begin
				if (count == 4'b0001) begin
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
				if (NB == 1'b0 && SB == 1'b0) begin
					counter_reset <= 1'b1;
					counter_count <= 1'b0;
					nextState <= stateA;
				end
				else if (NB || SB) begin
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
				PG <= ~clk;
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

// Uncomment to use this
// module up_counter_4bit_tb();
// 	reg clk_tb, T_tb, reset_tb;
// 	wire [3:0] count_tb;
// 	always
// 	#1 clk_tb = ~ clk_tb;
// 	up_counter_4bit TB(clk_tb, T_tb, reset_tb, count_tb);
// 	initial begin
// 		$dumpfile("up_counter_4bit_dump.vcd");
// 		$dumpvars(1);
// 		clk_tb = 1'b0;
// 		T_tb = 1'b0;
// 		reset_tb = 1'b1;
// 		#2;
// 		reset_tb = 1'b0;
// 		T_tb = 1'b1;
// 		#50;
// 		T_tb = 1'b0;
// 		#25;
// 		$finish;
// 	end
// endmodule

module controller_tb();
	reg clk_tb, reset_tb, NB_tb, SB_tb;
	wire TR_tb, TY_tb, TG_tb, PR_tb, PG_tb;
	integer i;
	integer j;
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
		#8;
		for (i = 0; i < 10; i = i + 1) begin
			j = $urandom%2;
			if (j) begin
				NB_tb <= 1'b1;
				#4;
				NB_tb <= 1'b0;
				#16;
			end else begin
				SB_tb <= 1'b1;
				#4;
				SB_tb <= 1'b0;
				#16;
			end
		end
      $finish;
	end
endmodule