typedef enum {
	Add,
	ShiftL,
	And,
	Not
} InstructionType deriving (Eq,FShow, Bits);

function Bit#(32) alu (InstructionType ins, Bit#(32) v1, Bit#(32) v2);
	return case (ins)
		Add : v1 + v2;
		ShiftL : v1 << v2;
		And : v1 & v2;
		Not : ~v1;
	endcase;
endfunction

