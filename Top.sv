//Gabriel Montero

//Used the Final_top_module.sv as reference

module Top;
	logic nRead, nWrite;	//output from the execution engine
	logic src1onBus, src2onBus, opcodeonBus, destonBus; 	//output from execution engine, controls the ALU from calculating without data
	logic nReset, Clk;		//output from the testbench
	logic [255:0] InstrDataOut;		//instruction memory output
	logic [255:0] MemDataOut;		//main memory output
	logic [255:0] ExecDataOut;		//output from the execution engine. input to all other modules
	logic [255:0] DataMuxOut;		//output from the mux to provide data into execution unit from all other units
	logic [15:0] address;			//output from execution engine
	logic [255:0] MatAluDataOut;	//output from the matrix ALU
	logic [255:0] IntAluDataOut;	//output from the integer ALU
	
	InstructionMemory I1(Clk, InstrDataOut, address, nRead, nReset);
	
	MainMemory M1(Clk, ExecDataOut, MemDataOut, address, nRead, nWrite, nReset);
	
	DataMux D1(DataMuxOut, Clk, nRead, address, InstrDataOut, MemDataOut, ExecDataOut, MatAluDataOut, IntAluDataOut);

	ExecStateMachine E1(Clk, DataMuxOut, ExecDataOut, address, nRead, nWrite, nReset, src1onBus, src2onBus, opcodeonBus, destonBus);
	
	TB_Instruction TB1(Clk, nReset);

	MatrixALU M2(Clk, MatAluDataOut, ExecDataOut, address, nRead, nWrite, nReset, src1onBus, src2onBus, opcodeonBus, destonBus);

	IntegerALU I2(Clk, IntAluDataOut, ExecDataOut, address, nRead, nWrite, nReset, src1onBus, src2onBus, opcodeonBus, destonBus);

endmodule