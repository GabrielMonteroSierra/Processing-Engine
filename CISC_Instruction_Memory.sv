// Instruction memory. 
// holds the instructions that the processor will execute.
//
// the address lines are generic and each module must handle thier own decode. 
// The address bus is large enough that each module can contain a local address decode. This will save on multiple enmables. 
// for now have ech module dedicated to an address line. A more generic solution would be to decode the upper bits and have a specific range. Use all bits in decode.
// bits 15:12 are used to memory map each peripheral
// 0 = main memory 
// 1 = integer memory
// 2 = instruction memory
// 3 = ALU
// 4 = execution engine registers
// bit 10-0 are for adressing inside each unit.
// nWrite = 0 means databus is being written into the part on the falling edge of write
// nRead = 0 means it is expected to drive the databus while this signal is low and the address is correct until the nRead goes high independent of addressd bus.


// Each and EVERY memory address location is 128 bits.

/// cannot be an enum because we need a specific address to be decoded.
// This is the memory locations for the system.
/////////////////////////////////////////////
parameter MainMemEn = 0;
parameter RegisterEn = 1;
parameter InstrMemEn = 2;
parameter AluEn = 3;
parameter ExecuteEn = 4;

// instruction: OPcode :: dest :: src1 :: src2   Each section is 8 bits. 
//Stop::FFh::00::00::00
//MMult::00h::Reg/mem::Reg/mem::Reg/mem
//Madd::01h::Reg/mem::Reg/mem::Reg/mem
//Msub::02h::Reg/mem::Reg/mem::Reg/mem
//Mtranspose::03h::Reg/mem::Reg/mem::Reg/mem
//MScale::04h::Reg/mem::Reg/mem::Reg/mem
//MScaleImm::05h:Reg/mem::Reg/mem::Immediate
//IntAdd::10h::Reg/mem::Reg/mem::Reg/mem
//IntSub::11h::Reg/mem::Reg/mem::Reg/mem
//IntMult::12h::Reg/mem::Reg/mem::Reg/mem
//IntDiv::13h::Reg/mem::Reg/mem::Reg/mem

//////////////////////////////
//Moved stop to third instruction for this example
/////////////////////////////////////////////////
// add the matrix at location 0 to the matrix at location 1 and place result in location 2
parameter Instruct1 = 32'h 01_02_00_01;
//Add the number at memory location 8 to location 9 store in memory location 3
parameter Instruct2 = 32'h 03_03_02_01;
//Subtract the first matrix from the result in step 1 and store the result somewhere else in memory. 
parameter Instruct10 = 32'h 02_03_03_00;
//Transpose the result from step 1 store in memory
parameter Instruct4 = 32'h 03_04_01_ff;
//Scale the result in step 3 by the result from step 2 store in a matrix register
parameter Instruct5 = 32'h 04_05_03_80;
//Multiply the result from step 4 by the result in step 3, store in memory. 
parameter Instruct6 = 32'h 00_06_04_03;
//Multiply memory location 0 to location 1. Store it in memory location 0A
parameter Instruct7 = 32'h 12_0A_00_01;
//Subtract Memory 01 from memory location 0A and store it in a register
parameter Instruct8 = 32'h 11_0A_01_81;
//Divide Memory location 0A by the register in step 8 and store it in location B
parameter Instruct9 = 32'h 13_0B_0A_81;
//STOP
parameter Instruct3 = 32'h ff_ff_ff_ff;

module InstructionMemory(Clk,Dataout, address, nRead, nReset);
// NOTE the lack of datain and write. This is because this is a ROM model

input logic nRead, nReset, Clk;
input logic [15:0] address;

output logic [255:0] Dataout; // 4 - 32 it instructions at one time.

  logic [31:0]InstructMemory[3]; // this is the physical memory

// This memory is designed to be driven into a data multiplexor. 

  always_ff @(negedge Clk or negedge nReset)
begin
  if (~nReset)
    Dataout = 0;
  if(address[15:12] == InstrMemEn) // talking to Instruction IntstrMemEn
		begin
			if(~nRead)begin
				Dataout <= InstructMemory[address[7:0]]; // data will reamin on dataout until it is changed.
			end
		end
end // from negedge nRead	

always @(negedge nReset)
begin
//	set in the default instructions 
//
	InstructMemory[0] = Instruct1;  	
	InstructMemory[1] = Instruct2;  	
	InstructMemory[2] = Instruct3;  	
end 

endmodule

