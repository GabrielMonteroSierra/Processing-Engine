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

parameter MMult = 8'h00;
parameter Madd = 8'h01;
parameter Msub = 8'h02;
parameter Mtranspose = 8'h03;
parameter MScale = 8'h04;
parameter MScaleImm  = 8'h05;

module MatrixALU(Clk, MatAluDataOut, ExecDataOut, address, nRead, nWrite, nReset, src1onBus, src2onBus, opcodeonBus, destonBus);
    input logic nRead, nWrite, nReset, Clk;
    input logic src1onBus, src2onBus, opcodeonBus, destonBus;   //For ALU, these are flags controlled by the ExeStMch, signify when the data has been sent to ALU
    input logic [255:0] ExecDataOut;
    input logic [15:0] address;

    logic [255:0] result;

    logic [7:0] opcode;
    logic [255:0] matrixA;      //SRC1
    logic [255:0] matrixB;      //SRC2

    output logic [255:0] MatAluDataOut;

    always @ (negedge opcodeonBus) begin        //Whenever opcodeonBus is low, the ExecStMch is sending data to the ALU
        if(address[15:12] == MatrixAluEn) begin
            opcode <= ExecDataOut;
            //$display("opcode: %h", opcode);
        end
    end

    always @ (negedge src1onBus) begin         //Whenever src1onBus is low, the ExecStMch is sending data to the ALU
        if(address[15:12] == MatrixAluEn) begin
            matrixA <= ExecDataOut;
        end
    end

    always @ (negedge src2onBus) begin          //Whenever src2onBus is low, the ExecStMch is sending data to the ALU
        if(address[15:12] == MatrixAluEn) begin
            matrixB <= ExecDataOut;
        end
    end

    always @ (negedge destonBus) begin          //Whenever src2onBus is low, the ExecStMch is sending data to the ALU
        if(address[15:12] == MatrixAluEn) begin
            result <= ExecDataOut;
        end
    end

    always @ (negedge nReset) begin
        MatAluDataOut = 0;
		result = 0;
        matrixA = 0;
        matrixB = 0;
    end

    always @ (posedge Clk) begin
        //$display("********** in matrix alu *************");
		if(address[15:12] == MatrixAluEn) begin
			if(!nWrite) begin

                /*
                    here is where we check opcode to see if its add, sub, mult, etc.
                */

                case(opcode)
                    /*
                        ---                   ---
                        | 00h | 01h | 02h | 03h |
                        | 10h | 11h | 12h | 13h |
                        | 20h | 21h | 22h | 23h |
                        | 30h | 31h | 32h | 33h |
                        ---                   ---

                        00h = [15:0]                    
                        01h = [31:16]                   
                        02h = [47:32]                   
                        03h = [63:48]                   
                        10h = [79:64]                   
                        11h = [95:80]                   
                        12h = [111:96]                  
                        13h = [127:112]                 
                        20h = [143:128]                 
                        21h = [159:144]                 
                        22h = [175:160]                 
                        23h = [191:176]                 
                        30h = [207:192]                 
                        31h = [223:208]                 
                        32h = [239:224]                 
                        33h = [255:240]                 
                    */  


                    MMult: begin
                        /* Dot Product of the matrices
                        --     --         --     --         --                                                     --
                        | 1 2 3 |         | A B C |         | (1*A)+(2*D)+(3*G) (1*B)+(2*E)+(3*F) (1*C)+(2*F)+(3*I) |
                        | 4 5 6 |    *    | D E F |    =    | (4*A)+(5*D)+(6*G) (4*B)+(5*E)+(6*F) (4*C)+(5*F)+(6*I) |
                        | 7 8 9 |         | G H I |         | (7*A)+(8*D)+(9*G) (7*B)+(8*E)+(9*F) (7*C)+(8*F)+(9*I) |
                        --     --         --     --         --                                                     --
                        */

                        //Row 1
                        result [15:0]    = matrixA [15:0] * matrixB [15:0]   +  matrixA [31:16] * matrixB [79:64]    +  matrixA [47:32] * matrixB [143:128]  +   matrixA [63:48] * matrixB [207:192];
                        result [31:16]   = matrixA [15:0] * matrixB [31:16]  +  matrixA [31:16] * matrixB [95:80]    +  matrixA [47:32] * matrixB [159:144]  +   matrixA [63:48] * matrixB [223:208];
                        result [47:32]   = matrixA [15:0] * matrixB [47:32]  +  matrixA [31:16] * matrixB [111:96]   +  matrixA [47:32] * matrixB [175:160]  +   matrixA [63:48] * matrixB [239:224];
                        result [63:48]   = matrixA [15:0] * matrixB [63:48]  +  matrixA [31:16] * matrixB [127:112]  +  matrixA [47:32] * matrixB [191:176]  +   matrixA [63:48] * matrixB [255:240];

                        //Row 2
                        result [79:64]   = matrixA [79:64] * matrixB [15:0]   +  matrixA [95:80] * matrixB [79:64]    +  matrixA [111:96] * matrixB [143:128]  +  matrixA [127:112] * matrixB [207:192];
                        result [95:80]   = matrixA [79:64] * matrixB [31:16]  +  matrixA [95:80] * matrixB [95:80]    +  matrixA [111:96] * matrixB [159:144]  +  matrixA [127:112] * matrixB [223:208];
                        result [111:96]  = matrixA [79:64] * matrixB [47:32]  +  matrixA [95:80] * matrixB [111:96]   +  matrixA [111:96] * matrixB [175:160]  +  matrixA [127:112] * matrixB [239:224];
                        result [127:112] = matrixA [79:64] * matrixB [63:48]  +  matrixA [95:80] * matrixB [127:112]  +  matrixA [111:96] * matrixB [191:176]  +  matrixA [127:112] * matrixB [255:240];
                        
                        //Row 3
                        result [143:128] = matrixA [143:128] * matrixB [15:0]   +  matrixA [159:144] * matrixB [79:64]    +  matrixA [175:160] * matrixB [143:128]  +  matrixA [191:176] * matrixB [207:192];
                        result [159:144] = matrixA [143:128] * matrixB [31:16]  +  matrixA [159:144] * matrixB [95:80]    +  matrixA [175:160] * matrixB [159:144]  +  matrixA [191:176] * matrixB [223:208];
                        result [175:160] = matrixA [143:128] * matrixB [47:32]  +  matrixA [159:144] * matrixB [111:96]   +  matrixA [175:160] * matrixB [175:160]  +  matrixA [191:176] * matrixB [239:224];
                        result [191:176] = matrixA [143:128] * matrixB [63:48]  +  matrixA [159:144] * matrixB [127:112]  +  matrixA [175:160] * matrixB [191:176]  +  matrixA [191:176] * matrixB [255:240];

                        //Row 4
                        result [207:192] = matrixA [207:192] * matrixB [15:0]   +  matrixA [223:208] * matrixB [79:64]    +  matrixA [239:224] * matrixB [143:128]  +  matrixA [255:240] * matrixB [207:192];
                        result [223:208] = matrixA [207:192] * matrixB [31:16]  +  matrixA [223:208] * matrixB [95:80]    +  matrixA [239:224] * matrixB [159:144]  +  matrixA [255:240] * matrixB [223:208];
                        result [239:224] = matrixA [207:192] * matrixB [47:32]  +  matrixA [223:208] * matrixB [111:96]   +  matrixA [239:224] * matrixB [175:160]  +  matrixA [255:240] * matrixB [239:224];
                        result [255:240] = matrixA [207:192] * matrixB [63:48]  +  matrixA [223:208] * matrixB [127:112]  +  matrixA [239:224] * matrixB [191:176]  +  matrixA [255:240] * matrixB [255:240];
                    end

                    Madd: begin
                        //Destination = SRC1 + SRC2

                        /*
                        --     --         --     --         --           --
                        | 1 2 3 |         | A B C |         | 1+A 2+B 3+C |
                        | 4 5 6 |    +    | D E F |    =    | 4+D 5+E 6+F | 
                        | 7 8 9 |         | G H I |         | 7+G 8+H 9+I |
                        --     --         --     --         --           --
                        */
                        
                        //Row 1
                        result [15:0]  = matrixA [15:0]  + matrixB [15:0];
                        result [31:16] = matrixA [31:16] + matrixB [31:16];
                        result [47:32] = matrixA [47:32] + matrixB [47:32];
                        result [63:48] = matrixA [63:48] + matrixB [63:48];

                        //Row 2
                        result [79:64]   = matrixA [79:64]   + matrixB [79:64];
                        result [95:80]   = matrixA [95:80]   + matrixB [95:80];
                        result [111:96]  = matrixA [111:96]  + matrixB [111:96];
                        result [127:112] = matrixA [127:112] + matrixB [127:112];

                        //Row 3
                        result [143:128] = matrixA [143:128] + matrixB [143:128];
                        result [159:144] = matrixA [159:144] + matrixB [159:144];
                        result [175:160] = matrixA [175:160] + matrixB [175:160];
                        result [191:176] = matrixA [191:176] + matrixB [191:176];

                        //Row 4
                        result [207:192] = matrixA [207:192] + matrixB [207:192];
                        result [223:208] = matrixA [223:208] + matrixB [223:208];
                        result [239:224] = matrixA [239:224] + matrixB [239:224];
                        result [255:240] = matrixA [255:240] + matrixB [255:240];
                        
                        /*
                        for(int i = 0; i < 240; i = i + 16) begin
                            result [i+15:i] = matrixA [i+15:i] + matrixB [i+15:i];          //Would not compile, range must be constants
                        end
                        */
                        
                    end
                     
                    Msub: begin
                        //Destination = SRC1 - SRC2

                        /*
                        --     --         --     --         --           --
                        | 1 2 3 |         | A B C |         | 1-A 2-B 3-C |
                        | 4 5 6 |    -    | D E F |    =    | 4-D 5-E 6-F | 
                        | 7 8 9 |         | G H I |         | 7-G 8-H 9-I |
                        --     --         --     --         --           --
                        */ 

                        //Row 1
                        result [15:0]     =   matrixA [15:0]    -  matrixB [15:0];
                        result [31:16]    =   matrixA [31:16]   -  matrixB [31:16];
                        result [47:32]    =   matrixA [47:32]   -  matrixB [47:32];
                        result [63:48]    =   matrixA [63:48]   -  matrixB [63:48];

                        //Row 2
                        result [79:64]    =  matrixA [79:64]    -  matrixB [79:64];
                        result [95:80]    =  matrixA [95:80]    -  matrixB [95:80];
                        result [111:96]   =  matrixA [111:96]   -  matrixB [111:96];
                        result [127:112]  =  matrixA [127:112]  -  matrixB [127:112];

                        //Row 3
                        result [143:128]  =  matrixA [143:128]  -  matrixB [143:128];
                        result [159:144]  =  matrixA [159:144]  -  matrixB [159:144];
                        result [175:160]  =  matrixA [175:160]  -  matrixB [175:160];
                        result [191:176]  =  matrixA [191:176]  -  matrixB [191:176];

                        //Row 4
                        result [207:192]  =  matrixA [207:192]  -  matrixB [207:192];
                        result [223:208]  =  matrixA [223:208]  -  matrixB [223:208];
                        result [239:224]  =  matrixA [239:224]  -  matrixB [239:224];
                        result [255:240]  =  matrixA [255:240]  -  matrixB [255:240];
                        
                        /*
                        for(int i = 0; i < 240; i = i + 16) begin
                            result [i+15:i] = matrixA [i+15:i] - matrixB [i+15:i];
                        end
                        */
                    end

                    Mtranspose: begin
                        /* Transposing the matrix
                        --     --             --     --
                        | 1 2 3 |             | 1 4 7 |
                        | 4 5 6 |     -->     | 2 5 8 |
                        | 7 8 9 |             | 3 6 9 |
                        --     --             --     --
                        */

                        //Row 1
                        result [15:0]    = matrixA [15:0];
                        result [31:16]   = matrixA [79:64];
                        result [47:32]   = matrixA [143:128];
                        result [63:48]   = matrixA [207:192];

                        //Row 2
                        result [79:64]   = matrixA [31:16];
                        result [95:80]   = matrixA [95:80];
                        result [111:96]  = matrixA [159:144];
                        result [127:112] = matrixA [223:208];

                        //Row 3
                        result [143:128] = matrixA [47:32];
                        result [159:144] = matrixA [111:96];
                        result [175:160] = matrixA [175:160];
                        result [191:176] = matrixA [239:224];

                        //Row 4
                        result [207:192] = matrixA [63:48];
                        result [223:208] = matrixA [127:112];
                        result [239:224] = matrixA [191:176];
                        result [255:240] = matrixA [255:240];
                    end

                    MScale: begin

                        
                    end
                     
                    MScaleImm: begin
                        
                    end

                endcase
            end

			if(!nRead) begin
				MatAluDataOut <= result;
			end
		end
	end
endmodule