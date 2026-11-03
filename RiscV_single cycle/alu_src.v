module alu_src(
	input wire [31:0] r_rs1,
	input wire [31:0] r_rs2,
	input wire [31:0] imm,
	input wire [31:0] pc,
	input wire alu_src1,
	input wire alu_src2,
	output wire [31:0] alu_ip1,
	output wire [31:0] alu_ip2);

assign alu_ip1 = (alu_src1 == 1'b0) ? r_rs1 : pc;
assign alu_ip2 = (alu_src2 == 1'b0) ? r_rs2 : imm;

endmodule