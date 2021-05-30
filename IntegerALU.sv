//Gabriel Montero

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

parameter IntAdd = 8'h10;
parameter IntSub = 8'h11;
parameter IntMult = 8'h12;
parameter IntDiv = 8'h13;

module IntegerALU(Clk, IntAluDataOut, ExecDataOut, address, nRead, nWrite, nReset, src1onBus, src2onBus, opcodeonBus, destonBus);
    input logic nRead, nWrite, nReset, Clk;
    input logic src1onBus, src2onBus, opcodeonBus, destonBus;   //For ALU, these are flags controlled by the ExeStMch, signify when the data has been sent to ALU
    input logic [255:0] ExecDataOut;
    input logic [15:0] address;

    logic [255:0] result;

    logic [7:0] opcode;
    logic [255:0] dataA;      //SRC1
    logic [255:0] dataB;      //SRC2

    output logic [255:0] IntAluDataOut;

    always @ (negedge opcodeonBus) begin        //Whenever opcodeonBus is low, the ExecStMch is sending data to the ALU
        if(address[15:12] == IntegerAluEn) begin
            opcode <= ExecDataOut;
            //$display("opcode: %h", opcode);
        end
    end

    always @ (negedge src1onBus) begin         //Whenever src1onBus is low, the ExecStMch is sending data to the ALU
        if(address[15:12] == IntegerAluEn) begin
            dataA <= ExecDataOut;
            $display("dataA");
        end
    end

    always @ (negedge src2onBus) begin          //Whenever src2onBus is low, the ExecStMch is sending data to the ALU
        if(address[15:12] == IntegerAluEn) begin
            dataB <= ExecDataOut;
            $display("dataB");
        end
    end

    always @ (negedge destonBus) begin          //Whenever src2onBus is low, the ExecStMch is sending data to the ALU
        if(address[15:12] == IntegerAluEn) begin
            result <= ExecDataOut;
        end
    end

    always @ (negedge nReset) begin
        IntAluDataOut = 0;
		result = 0;
        dataA = 0;
        dataB = 0;
    end

    always @ (posedge Clk) begin
        //$display("********** in integer alu *************");
		if(address[15:12] == IntegerAluEn) begin
			if(!nWrite) begin
                $display("in interget alu after adress 15:12");
                case(opcode)
                    IntAdd: begin
                        result <= dataA + dataB;
                    end

                    IntSub: begin
                        result <= dataA - dataB;
                    end

                    IntMult: begin
                        result <= dataA * dataB;
                    end

                    IntDiv: begin
                        result <= dataA / dataB;
                    end
                endcase
            end
            if(!nRead) begin
                $display("in integer alu after !nread");
				IntAluDataOut <= result;
			end
        end
    end
endmodule