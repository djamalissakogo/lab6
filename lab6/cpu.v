`timescale 1ns / 1ps
`define COMMAND_SIZE 47 //Макс длин команды
`define OP_SIZE 5   //Кол-вл бит на операцию

`define PC_WIDTH 10 //Разрядность счётчика команд
`define PROGRAM_SIZE 1024 //Кол-во строк в памяти команд

`define DATA_SIZE 1024 //Кол-во строк в памяти данных
`define ADDR_SIZE 10 //Кол-во бит на адрес

`define NOP 0 
`define LOAD 1   
`define INCR 2
`define DECR 3
`define CHCKPOL 4
`define FINDSTRT 5
`define JMPF 6
`define JMP 7
`define CMPR 8
`define WRTRES 9

module cpu(
	input clk,
   input reset,
   output pc
);
wire clk;
reg[`PC_WIDTH-1 : 0] pc, newpc;

reg [`COMMAND_SIZE-1 : 0]   Program [0:`PROGRAM_SIZE - 1  ];
reg [31:0]                  Data    [0:`DATA_SIZE - 1];

reg [`COMMAND_SIZE-1 : 0] command_1, command_2, command_3;
wire [`OP_SIZE - 1 : 0] op_2 = command_2 [`COMMAND_SIZE - 1 -: `OP_SIZE];//Операция 2
wire [`OP_SIZE - 1 : 0] op_3 = command_3 [`COMMAND_SIZE - 1 -: `OP_SIZE];//Операция 3

wire [`ADDR_SIZE - 1 : 0] addr1 = command_2[`COMMAND_SIZE - 1 - `OP_SIZE                 		   -: `ADDR_SIZE];//Адрес1 (В массиве Data)
wire [`ADDR_SIZE - 1 : 0] addr2 = command_2[`COMMAND_SIZE - 1 - `OP_SIZE - `ADDR_SIZE    		   -: `ADDR_SIZE];//Адрес2
wire [`ADDR_SIZE - 1 : 0] addr3 = command_2[`COMMAND_SIZE - 1 - `OP_SIZE - `ADDR_SIZE - `ADDR_SIZE -: `ADDR_SIZE];//Адрес3

wire [`ADDR_SIZE - 1 : 0] new_pc_addr = command_3 [`COMMAND_SIZE - 1 - `OP_SIZE -: `PC_WIDTH];//Новый адрес


wire [`ADDR_SIZE - 1 : 0] addr_to_load = command_3 [`COMMAND_SIZE - 1 - `OP_SIZE  -: `ADDR_SIZE];//Адрес для загрузки данных в data(равен addr1
wire [31:0] literal = command_3 [`COMMAND_SIZE - 1 - `OP_SIZE - `ADDR_SIZE -: 32];//Значение переменной для загрузки в data

reg [31:0] Reg_A, newReg_A;
reg [31:0] Reg_B, newReg_B;
reg [31:0] Reg_C, newReg_C;

reg flag_f, new_flag_f;
reg flag_is_pol, new_flag_is_pol;

integer i;
initial 
begin
    pc = 0; newpc = 0;
    $readmemb("Program1.mem", Program);
    for(i = 0; i < `DATA_SIZE; i = i + 1)
        Data[i] = 32'b0;
    command_1 = 0;
    command_2 = 0;
    command_3 = 0;
    Reg_A = 0;
    newReg_A = 0;
    newReg_B = 0;
    newReg_C = 0;
    flag_f=0;
    flag_is_pol=1;
    new_flag_f=0;
    new_flag_is_pol=1;
end

//Блок управления счётчиком команд
always@(posedge clk)
    if(reset)
        pc <= 0;
    else
        pc <= newpc;



//Изменение регистров A,B,C, флагов
always @(posedge clk)
begin
    flag_f <= new_flag_f;
	flag_is_pol <= new_flag_is_pol; 
    if(reset) 
        begin
            Reg_A <= 0;
            Reg_B <= 0;
            Reg_C <= 0;
        end
    else 
        begin	
            Reg_A <= newReg_A;
            Reg_B <= newReg_B;
            Reg_C <= newReg_C;
			end
	end

always @*

begin
    case(op_2)
        `INCR, `DECR:
            begin
                newReg_A <= Data[addr1];
            end
        `CMPR,`FINDSTRT:
            begin
                newReg_A <= Data[addr1];
                newReg_B <= Data[addr2];
            end
        `CHCKPOL:
            begin
                newReg_A <= Data[addr1];
                newReg_B <= Data[addr2];
                newReg_C <= Data[addr3];
            end    
        default:
            begin
                newReg_A <= newReg_A;
                newReg_B <= newReg_B;
                newReg_C <= newReg_C;
            end 
    endcase
end
always @(posedge clk)
begin
    case(op_3)
		`INCR:
			Data[addr_to_load]<=Reg_A+1;
		`DECR:
			Data[addr_to_load]<=Reg_A-1;	
		`WRTRES:
			Data[addr_to_load]<=flag_is_pol;
        `LOAD:
            Data[addr_to_load] <= literal;
    endcase
end
always @*
begin 
    case(op_3)
        `FINDSTRT: 
            new_flag_f <= Reg_A[Reg_B]==1;
		`CMPR: 
            new_flag_f <= (Reg_A < Reg_B || Reg_A == Reg_B);
		`CHCKPOL: 
			if(Reg_A[Reg_B] != Reg_A[Reg_C])
				new_flag_is_pol <= 0;
    endcase
end
always@*
begin
    if(( op_3 == `JMPF && new_flag_f)||op_3 == `JMP)
        newpc <= new_pc_addr;
    else 
        newpc <= pc + 1;
end

always@(posedge clk)
begin
    command_1 <= Program[pc];
    command_2 <= command_1;
    command_3 <= command_2;
end
endmodule
