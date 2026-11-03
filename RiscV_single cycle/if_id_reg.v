module if_id_reg(
				input wire clk,
				input wire [31:0] instr,
				input wire [31:0] pc,
				input wire [31:0] pc_plus4,
				output reg [31:0] pc_reg,
				output reg [31:0] pc_plus4_reg,				 
				output reg [31:0] instr_reg );

always @(posedge clk) begin 
		instr_reg <= instr;
		pc_reg <= pc;
		pc_plus4_reg <= pc_plus4;
end

endmodule