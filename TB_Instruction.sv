//Gabriel Montero

module TB_Instruction(Clk, nReset);
	output logic Clk, nReset;
	
	initial begin
		Clk = 0;
		nReset = 1;
		
		#10 nReset = 0;
		#10 nReset = 1;
	end
	
	always #10 Clk = !Clk;
	
endmodule
