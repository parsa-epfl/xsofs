// See LICENSE.md for license details

module tb(
`ifdef VERILATOR
    input  wire clock,
    input  wire reset,

    output wire dump_o
`endif
);

    //
    // clock & reset

`ifdef AWS
    wire clock;
    wire reset;
`else
`ifndef VERILATOR
    reg  clock = 1'b1;
    reg  reset = 1'b1;

    initial begin
        #20
        reset = 1'b0;
    end

    initial begin
        forever
            #0.5 clock = ~clock;
    end
`endif
`endif

    reg [63:0] cnt_q;

    always_ff @(posedge clock or posedge reset)
        if (reset)
            cnt_q <= 64'b0;
        else
            cnt_q <= cnt_q + 64'b1;

    longint init;
    longint stop;
    longint dump;

`ifdef CHK
    import "DPI-C" function void init_db(input int    en);
    import "DPI-C" function void save_db(input string fn);
`endif

    initial begin
        if (!$value$plusargs("init=%d", init))
            init = 4;
        if (!$value$plusargs("stop=%d", stop))
            stop = 0;
        if (!$value$plusargs("dump=%d", dump))
            dump = 0;

`ifdef CHK
        init_db(1);
`endif
    end

    wire init_en = ~reset & |init & (cnt_q >= init);
    wire stop_en = ~reset & |stop & (cnt_q >= stop);
    wire dump_en = ~reset & |dump & (cnt_q >= dump) | &dump;

    always_ff @(posedge clock)
        if (stop_en)
            $finish();

`ifdef CHK
    final begin
        save_db("dump.db");
    end
`endif


    //
    // instantiation

`ifdef AWS
    reg [31:0] sv_host_memory[*];
    reg        use_c_host_memory = 1'b0;

`include "sh_dpi_tasks.svh"

    // compatibility
    card card();

    assign clock = card.fpga.CL.clk_cl;
    assign reset = card.fpga.CL.rst_cl;

    aws
    u_aws (.clock (clock),
           .reset (reset));
`else
    dut
    u_dut (.clock (clock),
           .reset (reset));
`endif


    //
    // waveform dumping

`ifndef VERILATOR
    initial begin
        @(posedge dump_en);

`ifdef DUMPFSDB
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars("+all");

        forever begin
            repeat (100000)
                @(posedge clock);

            $fsdbDumpflush();
        end
`endif

`ifdef DUMPSHM
        $shm_open("dump.shm");
        $shm_probe("AS");
`endif
    end
`endif

`ifdef VERILATOR
    assign dump_o = dump_en;
`endif

endmodule


`ifdef CHK
module diff_mon();

`define TOP  XSTop

    //
    // difftest

    import "DPI-C" function int diff_init(input string  lib,
                                          input string  rom,
                                          input string  bin,
                                          input string  img,
                                          input string  ctl);
    import "DPI-C" function int diff_step(input longint tim);

    int diff_ret = 0;

    initial begin
        string lib;
        string rom;
        string bin;
        string img;
        string cmd;

        $value$plusargs("lib=%s", lib);
        $value$plusargs("rom=%s", rom);
        $value$plusargs("bin=%s", bin);
        $value$plusargs("img=%s", img);
        $value$plusargs("cmd=%d", cmd);

        diff_ret = diff_init(lib, rom, bin, img, cmd);
    end

    // this clock can be gated, e.g. due to firesim
    // the top-level free-running clock can lead to instructions/exceptions
    // being performed/checked multiple times
    always_ff @(posedge `TOP.io_clock)
        if (~`TOP.io_reset & (diff_ret == 1)) begin
            int ret = diff_step($time());

            if (ret) begin
                $display("diff: %0d @%0d", ret, $time());
                $finish();
            end
        end

endmodule


module core_mon #(parameter H = 0) (
    input wire clock,
    input wire reset
);

`define CSR exuBlocks.fuBlock.exeUnits_3.csr
`define ROB ctrlBlock.rob
`define WFI 32'h10500073

    // works only when CommitWidth == 2
    wire [ 1:0] grad_vec   = {`ROB.difftest_1_io_valid,
                              `ROB.difftest_io_valid | (`ROB.difftest_io_instr == `WFI)};
    wire        grad_vld   =  |grad_vec;
    wire        grad_inv   = ~|grad_vec;

    wire [63:0] expt_cause =  `CSR.difftest_io_cause;
    wire        expt_vld   =  |expt_cause;

    reg  [31:0] hang;
    reg  [31:0] grad;

    initial begin
        if (!$value$plusargs("hang=%d", hang))
            hang = 5000;
        if (!$value$plusargs("grad=%d", grad))
            grad = 32'd16;

        grad = (32'b1 << grad) - 32'b1;
    end

    reg  [31:0] hang_cnt_q;
    reg  [31:0] grad_cnt_q;
    wire [31:0] grad_cnt = grad & grad_cnt_q;

    always_ff @(posedge clock or posedge reset)
        if (reset)
            hang_cnt_q <=  32'b0;
        else
            hang_cnt_q <= (hang_cnt_q + 32'b1) & {32{grad_inv}};

    always_ff @(posedge clock or posedge reset)
        if (reset)
            grad_cnt_q <=  32'b0;
        else if (grad_vld)
            grad_cnt_q <=  grad_cnt_q + {30'b0, &grad_vec, ^grad_vec};

    always_ff @(posedge clock) begin
        if (~reset & grad_inv & (hang_cnt_q >= hang))
            $fatal  ("<%0d:%0d:hang:%0x:%0x>",   $time(),
                      H,
                     `ROB.difftest_io_pc,
                     `ROB.difftest_io_instr);

        if (~reset & grad_vec[0] & (grad_cnt == 32'b0))
            $display("<%0d:%0d:grad:%0x:%0x>", $time(),
                      H,
                     `ROB.difftest_io_pc,
                     `ROB.difftest_io_instr);

        if (~reset & grad_vec[1] & (grad_cnt == grad))
            $display("<%0d:%0d:grad:%0x:%0x>", $time(),
                      H,
                     `ROB.difftest_1_io_pc,
                     `ROB.difftest_1_io_instr);

        if (~reset & expt_vld & ~((expt_cause == 64'h8) |
                                  (expt_cause == 64'h9) |
                                  (expt_cause == 64'h1)))
            $display("<%0d:%0d:expt:%0x:%0x:%0x>", $time(),
                      H,
                      expt_cause,
                     `CSR.difftest_io_exceptionPC,
                     `CSR.difftest_io_exceptionInst);
    end

endmodule


bind `TOP diff_mon
u_diff_mon();

bind XSCore   core_mon #(.H (0))
u_core_mon(.clock (XSCore  .clock),
           .reset (XSCore  .reset));

bind XSCore_1 core_mon #(.H (1))
u_core_mon(.clock (XSCore_1.clock),
           .reset (XSCore_1.reset));
`endif


`ifndef VERILATOR
module TOP();

    tb tb();

endmodule
`endif


`ifndef AWS
module glbl();
endmodule
`endif
