//Gabriel Montero
//Worked with Jaylen Gilkey

//http://www.cs.columbia.edu/~sedwards/classes/2015/4840/memory.pdf

parameter MainMemEn = 0;
parameter RegisterEn = 1;
parameter InstrMemEn = 2;
parameter MatrixAluEn = 3;
parameter IntegerAluEn = 4;
parameter ExecuteEn = 5;


module MainMemory(Clk, ExecDataOut, MemDataOut, address, nRead, nWrite, nReset);
	input logic nRead, nWrite, nReset, Clk;
	input logic [15:0] address;
	input logic [255:0] ExecDataOut;
	
	output logic [255:0] MemDataOut;
	
	logic [3:0][255:0] MainMemory;		//4 256-bits Main Memory storage
	
	always_ff @(posedge Clk or negedge nReset) begin
		//$display("********** in main memory *************");
		if(!nReset)	begin
			MemDataOut = 0;
			MainMemory = 0;
		end
		if(address[15:12] == MainMemEn) begin
			if(!nWrite) begin
				MainMemory[address[11:0]] <= ExecDataOut;
			end
			if(!nRead) begin
				MemDataOut <= MainMemory[address[11:0]];
			end
		end
	end
endmodule