//Gabriel Montero

//Worked with Jaylen, Treyvon, Stephen, Josh, myself

parameter MainMemEn = 0;
parameter RegisterEn = 1;
parameter InstrMemEn = 2;
parameter MatrixAluEn = 3;
parameter IntegerAluEn = 4;
parameter ExecuteEn = 5;

// instruction :: Opcode ::   dest  ::   src1  ::   src2      -Each section is 8 bits.
//  Stop 	   ::   FFh  ::    00   ::    00   ::    00
//  MMult 	   ::   00h  :: Reg/mem :: Reg/mem :: Reg/mem
//  Madd	   ::   01h  :: Reg/mem :: Reg/mem :: Reg/mem
//  Msub  	   ::   02h  :: Reg/mem :: Reg/mem :: Reg/mem
//  Mtranspose ::   03h  :: Reg/mem :: Reg/mem :: Reg/mem
//  MScale 	   ::   04h  :: Reg/mem :: Reg/mem :: Reg/mem
//  MScaleImm  ::   05h  :: Reg/mem :: Reg/mem :: Immediate
//  IntAdd 	   ::   10h  :: Reg/mem :: Reg/mem :: Reg/mem
//  IntSub 	   ::   11h  :: Reg/mem :: Reg/mem :: Reg/mem
//  IntMult    ::   12h  :: Reg/mem :: Reg/mem :: Reg/mem
//  IntDiv 	   ::   13h  :: Reg/mem :: Reg/mem :: Reg/mem


parameter Stop = 8'hFF;
parameter MMult = 8'h00;
parameter Madd = 8'h01;
parameter Msub = 8'h02;
parameter Mtranspose = 8'h03;
parameter MScale = 8'h04;
parameter MScaleImm  = 8'h05;
parameter IntAdd = 8'h10;
parameter IntSub = 8'h11;
parameter IntMult = 8'h12;
parameter IntDiv = 8'h13;


// add the matrix at location 0 to the matrix at location 1 and place result in location 2
parameter Instruct1 = 32'h 01_02_00_01;
//Add the number at memory location 8 to location 9 store in memory location 3
parameter Instruct2 = 32'h 03_03_02_01;

module ExecStateMachine(Clk, DataMuxOut, ExecDataOut, address, nRead, nWrite, nReset, src1onBus, src2onBus, opcodeonBus, destonBus);
	input Clk, nReset;
	input logic [255:0] DataMuxOut;
	
	output logic nRead, nWrite;
	output logic src1onBus, src2onBus, opcodeonBus, destonBus;		//For ALU, these are flags controlled by the ExeStMch, signify when the data has been sent to ALU
	output logic [15:0] address;
	output logic [255:0] ExecDataOut;
	
	logic [3:0] pc;
	logic [7:0] Opcode;
	logic [7:0] dest;
	logic [7:0] src1;
	logic [7:0] src2;
	
	logic [7:0][31:0] InstructReg;			//Opcode [31:24],	Dest [23:16],	Src1 [15:8],	Src2 [7:0]
	
	enum {read_instruct, read_instruct_Data, decode_inst, Src1_On_Bus, Src2_On_Bus, Bus_To_Src1, Bus_To_Src2, Dest_On_Bus, Bus_To_Dest, Execute, Finish_Move} Next_State, Current_State;
	
	always_ff @(posedge Clk or negedge nReset) begin
		if(!nReset) begin
			pc <= 0;

			opcodeonBus <= 1;				//If these are high, then data is not being sent to the ALU
			src1onBus <= 1;
			src2onBus <= 1;
			destonBus <= 1;
			
			Current_State <= read_instruct;
			nRead <= 0;
		end
		else begin
			case (Current_State)
				read_instruct: begin		//has instruction memory put the data on the bus
					nRead <= 0;
					nWrite <= 1;

					address[15:12] <= InstrMemEn;
					//$display("InstructEn");
					address[11:0] <= 0;
					
					Next_State <= read_instruct_Data;
				end
				read_instruct_Data: begin
					InstructReg <= DataMuxOut;
					address[15:12] = ExecuteEn;
					//$display("exEn");
					
					Next_State <= decode_inst;
				end
				decode_inst: begin			//decode instruction, set opcode, next state source1 data into AluEn
					nRead <= 1;
					nWrite <= 1;

					Opcode <= InstructReg[pc][31:24];
					dest <= InstructReg[pc][23:16];
					src1 <= InstructReg[pc][15:8];
					src2 <= InstructReg[pc][7:0];

					ExecDataOut <= Opcode;
					opcodeonBus <= 0;

					if(Opcode == Stop) begin			//If the opcode is 8'hFF, then the code stops
						$stop;
					end

					if(Opcode == 8'h00 || Opcode == 8'h01 || Opcode == 8'h02 || Opcode == 8'h03 || Opcode == 8'h04 || Opcode == 8'h05) begin
						address[15:12] <= MatrixAluEn;			//Enables the Matrix ALU, if the significant bit of the opcode is a 0
						//$display("matrixEn - decode");
					end											//8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05
					else begin
						address[15:12] <= IntegerAluEn;			//Enables the Integer ALU, if the significant bit of the opcode is a 1
						//$display("IntEn - decode");
					end									//8'h10, 8'h11, 8'h12, 8'h13

					Next_State <= Bus_To_Src1;
				end
				Bus_To_Src1: begin
					nRead <= 0;

					opcodeonBus <= 1;

					address[15:12] <= MainMemEn;		//Enables the main memory
					//$display("MemEn - bustosrc1");
					address[11:0] <= src1;
					
					Next_State <= Src1_On_Bus;
				end
				Src1_On_Bus: begin
					nRead <= 1;

					if(Opcode == 8'h00 || Opcode == 8'h01 || Opcode == 8'h02 || Opcode == 8'h03 || Opcode == 8'h04 || Opcode == 8'h05) begin
						address[15:12] <= MatrixAluEn;			//Enables the Matrix ALU, if the significant bit of the opcode is a 0
						//$display("matrixEn - src1onbus");
					end											//8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05
					else begin
						address[15:12] <= IntegerAluEn;			//Enables the Integer ALU, if the significant bit of the opcode is a 1
						//$display("IntEn - src1onbus");
					end									//8'h10, 8'h11, 8'h12, 8'h13

					ExecDataOut <= DataMuxOut;
					src1onBus <= 0;
					
					Next_State <= Bus_To_Src2;
				end
				Bus_To_Src2: begin
					nRead <= 0;

					src1onBus <= 1;

					address[15:12] <= MainMemEn;		//Enables the main memory
					//$display("MemEn - bustosrc2");
					address[11:0] <= src2;
					
					Next_State <= Src2_On_Bus;
				end
				Src2_On_Bus: begin
					nRead <= 1;

					if(Opcode == 8'h00 || Opcode == 8'h01 || Opcode == 8'h02 || Opcode == 8'h03 || Opcode == 8'h04 || Opcode == 8'h05) begin
						address[15:12] <= MatrixAluEn;			//Enables the Matrix ALU, if the significant bit of the opcode is a 0
						//$display("matrixEn - src2onbus");
					end											//8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05
					else begin
						address[15:12] <= IntegerAluEn;			//Enables the Integer ALU, if the significant bit of the opcode is a 1
						//$display("IntEn - src2onbus");
					end									//8'h10, 8'h11, 8'h12, 8'h13

					ExecDataOut <= DataMuxOut;
					src2onBus <= 0;
					
					Next_State <= Bus_To_Dest;
				end
				Bus_To_Dest: begin
					nRead <= 0;

					src2onBus <= 1;

					address[15:12] <= MainMemEn;		//Enables the main memory
					//$display("MemEn - bustodest");
					address[11:0] <= dest;
					
					Next_State <= Dest_On_Bus;
				end
				Dest_On_Bus: begin
					nRead <= 1;

					if(Opcode == 8'h00 || Opcode == 8'h01 || Opcode == 8'h02 || Opcode == 8'h03 || Opcode == 8'h04 || Opcode == 8'h05) begin
						address[15:12] <= MatrixAluEn;			//Enables the Matrix ALU, if the significant bit of the opcode is a 0
						//$display("matrixEn - destonbus");
					end											//8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05
					else begin
						address[15:12] <= IntegerAluEn;			//Enables the Integer ALU, if the significant bit of the opcode is a 1
						//$display("IntEn - destonbus");
					end									//8'h10, 8'h11, 8'h12, 8'h13

					ExecDataOut <= DataMuxOut;
					destonBus <= 0;
					
					Next_State <= Execute;
				end
				Execute: begin
					destonBus <= 1;

					nWrite <= 0;

					Next_State <= Finish_Move;
				end
				Finish_Move: begin
					//address[15:12] <= MainMemEn;
					nWrite <= 1;
					nRead <= 0;
					address <= 0;

					pc <= pc + 1;

					Next_State <= read_instruct;
				end
			endcase
			Current_State <= Next_State;
		end
	end
endmodule