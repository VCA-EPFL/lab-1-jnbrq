import Vector::*;

typedef struct {
 Bool valid;
 Bit#(31) data;
 Bit#(4) index;
} ResultArbiter deriving (Eq, FShow);

function ResultArbiter arbitrate(Vector#(16, Bit#(1)) ready, Vector#(16, Bit#(31)) data);
	// let's make this one a priority arbiter
	Bit#(4) chosenIdx[16];
	Bit#(1) isChosen[16];

	// we choose the first one if ready
	isChosen[0] = ready[0];
	chosenIdx[0] = 0;

	for (Integer idx = 1; idx < 16; idx = idx + 1) begin
		isChosen[idx] = ready[idx] | isChosen[idx - 1];
		
		if (isChosen[idx - 1] == 1)
			chosenIdx[idx] = chosenIdx[idx - 1];
		else
			chosenIdx[idx] = fromInteger(idx);
	end

	return ResultArbiter{valid: isChosen[15] == 1, data : data[chosenIdx[15]], index: chosenIdx[15]};
endfunction

// NOTE: Atomicity of the rules, if a method calls multiple methods, it is executed when all methods
// are in fact executable.
