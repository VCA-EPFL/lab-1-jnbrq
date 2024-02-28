import Vector::*;

typedef Bit#(16) Word;

function Vector#(16, Word) naiveShfl(Vector#(16, Word) in, Bit#(4) shftAmnt);
    Vector#(16, Word) resultVector = in; 
    for (Integer i = 0; i < 16; i = i + 1) begin
        Bit#(4) idx = fromInteger(i);
        resultVector[i] = in[shftAmnt+idx];
    end
    return resultVector;
endfunction


function Vector#(16, Word) barrelLeft(Vector#(16, Word) in, Bit#(4) shftAmnt);
    Vector#(16, Word) intermediate[5];
    intermediate[0] = in;

    for (Integer i = 0; i < 4; i = i + 1) begin
        // Vector vs array?

        if (shftAmnt[3 - i] == 0) begin
            intermediate[i + 1] = intermediate[i];
        end
        else begin
            intermediate[i + 1] = naiveShfl(intermediate[i], (8 >> i));
        end
    end

    return intermediate[4];
endfunction
