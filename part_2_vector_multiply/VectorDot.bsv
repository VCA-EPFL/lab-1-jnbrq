import Vector::*;
import BRAM::*;

// Time spent on VectorDot: ____

// Please annotate the bugs you find.

interface VD;
    method Action start(Bit#(8) dim_in, Bit#(2) i);
    method ActionValue#(Bit#(32)) response();
endinterface

(* synthesize *)
module mkVectorDot (VD);
    BRAM_Configure cfg1 = defaultValue;
    cfg1.loadFormat = tagged Hex "v1.hex";
    BRAM1Port#(Bit#(8), Bit#(32)) a <- mkBRAM1Server(cfg1);
    BRAM_Configure cfg2 = defaultValue;
    cfg2.loadFormat = tagged Hex "v2.hex";
    BRAM1Port#(Bit#(8), Bit#(32)) b <- mkBRAM1Server(cfg2);

    Reg#(Bit#(32)) output_res <- mkReg(unpack(0));

    Reg#(Bit#(8)) dim <- mkReg(0);

    Reg#(Bool) ready_start <- mkReg(False);
    Reg#(Bit#(8)) pos_a <- mkReg(unpack(0));
    Reg#(Bit#(8)) pos_b <- mkReg(unpack(0));
    Reg#(Bit#(8)) pos_out <- mkReg(unpack(0));
    Reg#(Bool) done_all <- mkReg(False);
    Reg#(Bool) done_a <- mkReg(False);
    Reg#(Bool) done_b <- mkReg(False);
    Reg#(Bool) req_a_ready <- mkReg(False);
    Reg#(Bool) req_b_ready <- mkReg(False);

    Reg#(Bit#(2)) i <- mkReg(0);


    rule process_a (ready_start && !done_a && !req_a_ready);
        $display("process_a: pos_a = %d", pos_a);

        a.portA.request.put(BRAMRequest{write: False, // False for read
                            responseOnWrite: False,
                            address: zeroExtend(pos_a),
                            datain: ?});

        if (pos_a < dim*zeroExtend(i + 1)) // BUG 1
            pos_a <= pos_a + 1;
        else done_a <= True;

        req_a_ready <= True;

    endrule

    rule process_b (ready_start && !done_b && !req_b_ready);
        $display("process_b: pos_b = %d", pos_b);

        b.portA.request.put(BRAMRequest{write: False, // False for read
                responseOnWrite: False,
                address: zeroExtend(pos_b),
                datain: ?});

        if (pos_b < dim*zeroExtend(i + 1)) // BUG 2
            pos_b <= pos_b + 1;
        else done_b <= True;
    
        req_b_ready <= True;
    endrule

    // Fixed compiler warning: ready_start
    rule mult_inputs (ready_start && req_a_ready && req_b_ready && !done_all);
        let out_a <- a.portA.response.get();
        let out_b <- b.portA.response.get();

        output_res <= output_res + out_a*out_b; // BUG 3
        pos_out <= pos_out + 1;
        
        if (pos_out == dim-1) begin
            done_all <= True;

            // BUG 4
            ready_start <= False;
        end


        req_a_ready <= False;
        req_b_ready <= False;
    endrule



    method Action start(Bit#(8) dim_in, Bit#(2) i_in) if (!ready_start);
        ready_start <= True;
        dim <= dim_in;
        done_all <= False;
        pos_a <= dim_in*zeroExtend(i_in); // BUG 6
        pos_b <= dim_in*zeroExtend(i_in); // BUG 7
        done_a <= False;
        done_b <= False;
        pos_out <= 0;
        i <= i_in;
        output_res <= 0; // BUG 5
    endmethod

    method ActionValue#(Bit#(32)) response() if (done_all);
        return output_res;
    endmethod

endmodule
