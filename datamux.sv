//Gabriel Montero
//Worked with Jaylen Gilkey

parameter MainMemEn = 0;
parameter RegisterEn = 1;
parameter InstrMemEn = 2;
parameter MatrixAluEn = 3;
parameter IntegerAluEn = 4;
parameter ExecuteEn = 5;

module DataMux(DataMuxOut, Clk, nRead, address, InstrDataOut, MemDataOut, ExecDataOut, MatAluDataOut, IntAluDataOut);
	input logic nRead, Clk;
	input logic [15:0] address;
	input logic [255:0] MemDataOut;
	input logic [255:0] InstrDataOut;
	input logic [255:0] ExecDataOut;
	input logic [255:0] MatAluDataOut;
	input logic [255:0] IntAluDataOut;
	
	output logic [255:0] DataMuxOut;
	
	always @(posedge Clk) begin		//synchronous clock that will select between instruction and memory
		//$display("********** in datamux *************");
		if (!nRead) begin
			if(address[15:12] == MainMemEn) begin
				DataMuxOut = MemDataOut;
			end
			//if(address[15:12] == RegisterEn) begin	
			//	DataMuxOut = ;
			//end
			if(address[15:12] == InstrMemEn) begin	
				DataMuxOut = InstrDataOut;
			end
			if(address[15:12] == MatrixAluEn) begin	
				DataMuxOut = MatAluDataOut;
			end
			if(address[15:12] == IntegerAluEn) begin	
				DataMuxOut = IntAluDataOut;
			end
			if(address[15:12] == ExecuteEn) begin	
				DataMuxOut = ExecDataOut;
			end
		end
	end
endmodule