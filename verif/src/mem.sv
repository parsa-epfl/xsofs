// See LICENSE.md for license details

module addr_gen
#(parameter A = 16)
(
    input  wire [  7:0] len,
    input  wire [  2:0] size,
    input  wire [  1:0] burst,

    input  wire [A-1:0] addr_cur,
    output wire [A-1:0] addr_nxt
);

    wire [  7:0] size_dec;

    for (genvar i = 0; i < 8; i++)
        assign size_dec[i] = (size == i[2:0]);

    wire [A-1:0] incr =  {A  {1'b1}};
    wire [A-1:0] wrap = {{A-8{1'b1}}, ~len};

    wire [A-1:0] incr_dec [7:0];
    wire [A-1:0] wrap_dec [7:0];

    assign incr_dec[0] = incr;
    assign wrap_dec[0] = wrap;

    for (genvar i = 1; i < 8; i++) begin
        assign incr_dec[i] = {incr[A-1-i:0], {i{1'b0}}};
        assign wrap_dec[i] = {wrap[A-1-i:0], {i{1'b0}}};
    end

    reg  [A-1:0] incr_msk;
    reg  [A-1:0] wrap_msk;

    always_comb begin
        incr_msk = {A{1'b0}};
        wrap_msk = {A{1'b0}};

        for (int i = 0; i < 8; i++) begin
            incr_msk |= {A{size_dec[i]}} & incr_dec[i];
            wrap_msk |= {A{size_dec[i]}} & wrap_dec[i];
        end
    end

    wire [A-1:0] incr_nxt = (incr_msk & addr_cur) + {{A-8{1'b0}}, size_dec};
    wire [A-1:0] wrap_nxt =  wrap_msk & addr_cur  |
                            ~wrap_msk & incr_nxt;

    assign addr_nxt = {A{burst == 2'd0}} & addr_cur |
                      {A{burst == 2'd1}} & incr_nxt |
                      {A{burst == 2'd2}} & wrap_nxt;

endmodule


module mem
#(parameter D = 32,
            A = 16,
            S = D / 8,
            I = 4,
            X = 4,
            F = "bin",
            G = "img")
(
    // ------------------------
    // interface

    input  wire         aclk,
    input  wire         arst,

    input  wire         arvalid,
    output wire         arready,
    input  wire [I-1:0] arid,
    input  wire [A-1:0] araddr,
    input  wire [  7:0] arlen,
    input  wire [  2:0] arsize,
    input  wire [  1:0] arburst,
    input  wire         arlock,
    input  wire [  3:0] arcache,
    input  wire [  2:0] arprot,

    output wire         rvalid,
    input  wire         rready,
    output wire [I-1:0] rid,
    output wire [D-1:0] rdata,
    output wire [  1:0] rresp,
    output wire         rlast,

    input  wire         awvalid,
    output wire         awready,
    input  wire [I-1:0] awid,
    input  wire [A-1:0] awaddr,
    input  wire [  7:0] awlen,
    input  wire [  2:0] awsize,
    input  wire [  1:0] awburst,
    input  wire         awlock,
    input  wire [  3:0] awcache,
    input  wire [  2:0] awprot,

    input  wire         wvalid,
    output wire         wready,
    input  wire [D-1:0] wdata,
    input  wire [S-1:0] wstrb,
    input  wire         wlast,

    output wire         bvalid,
    input  wire         bready,
    output wire [I-1:0] bid,
    output wire [  1:0] bresp
);

    // ------------------------
    // param

    parameter L      = $clog2(S);

    parameter S_IDLE = 2'd0,
              S_MEM  = 2'd1,
              S_RET  = 2'd2;


    // ------------------------
    // logic

    wire ar_hs = arvalid & arready;
    wire aw_hs = awvalid & awready;
    wire  r_hs =  rvalid &  rready;
    wire  w_hs =  wvalid &  wready;
    wire  b_hs =  bvalid &  bready;


    //
    // mem

    import "DPI-C" function void mem_init(input  string           bin,
                                          input  longint unsigned wid,
                                          input  longint unsigned cap);
    import "DPI-C" function void mem_load(input  string           img,
                                          input  longint unsigned addr);
    import "DPI-C" function void mem_rd  (input  longint unsigned addr,
                                          output bit [D-1:0]      data);
    import "DPI-C" function void mem_wr  (input  longint unsigned addr,
                                          input  bit [D-1:0]      data,
                                          input  bit [S-1:0]      strb);

    wire         mem_re;
    wire         mem_re_qual;
    wire [A-1:L] mem_raddr;
    reg  [D-1:0] mem_rdata;
    reg  [D-1:0] mem_rdata_d;

    wire         mem_we;
    wire [A-1:L] mem_waddr;
    wire [D-1:0] mem_wdata;
    wire [S-1:0] mem_wstrb;

    assign mem_re_qual = mem_re & ~mem_we;

    always_ff @(posedge aclk)
        if (mem_re_qual) begin
            mem_rd(mem_raddr,
                   mem_rdata_d);
            mem_rdata <= mem_rdata_d;
        end

    always_ff @(posedge aclk)
        if (mem_we)
            mem_wr(mem_waddr,
                   mem_wdata,
                   mem_wstrb);

    string bin;
    string img;

    initial begin
        if (!$value$plusargs($sformatf("%s=%%s", F), bin))
            bin = F;
        if (!$value$plusargs($sformatf("%s=%%s", G), img))
            img = "";

        mem_init(bin, S, 64'h1 << A);
        mem_load(img,    64'h2000000);
    end


    //
    // exclusive mon

    wire ldx_en = ar_hs & arlock;
    wire stx_en = aw_hs & awlock;

    wire ldx_succ;
    wire stx_succ;

    wire [X-1:0] ldx_hit;
    wire [X-1:0] stx_hit;
    wire [X-1:0] sty_hit;

    wire ldx_hit_any = |ldx_hit;
    wire stx_hit_any = |stx_hit;

    wire [X-1:0] mon_set;
    wire [X-1:0] mon_clr;
    reg  [X-1:0] mon_vld_q;
    reg  [X-1:0] mon_rpl_q;

    always_ff @(posedge aclk or posedge arst)
        if (arst)
            mon_vld_q <= {X{1'b0}};
        else
            mon_vld_q <= mon_vld_q & ~mon_clr | mon_set;

    always_ff @(posedge aclk or posedge arst)
        if (arst)
            mon_rpl_q <= {{X-1{1'b0}}, 1'b1};
        else if (ldx_en)
            mon_rpl_q <= {mon_rpl_q[X-2:0], mon_rpl_q[X-1]};

    reg  [I-1:0] mon_id_q    [X-1:0];
    reg  [A-1:0] mon_addr_q  [X-1:0];
    reg  [  7:0] mon_len_q   [X-1:0];
    reg  [  2:0] mon_size_q  [X-1:0];
    reg  [  1:0] mon_burst_q [X-1:0];
    reg  [  3:0] mon_cache_q [X-1:0];
    reg  [  2:0] mon_prot_q  [X-1:0];

    for (genvar i = 0; i < X; i++)
        always_ff @(posedge aclk)
            if (mon_set[i]) begin
                mon_id_q   [i] <= arid;
                mon_addr_q [i] <= araddr;
                mon_len_q  [i] <= arlen;
                mon_size_q [i] <= arsize;
                mon_burst_q[i] <= arburst;
                mon_cache_q[i] <= arcache;
                mon_prot_q [i] <= arprot;
            end

    for (genvar i = 0; i < X; i++) begin
        assign ldx_hit[i] = ldx_en & mon_vld_q[i] & (mon_id_q   [i] == arid   );
        assign stx_hit[i] = stx_en & mon_vld_q[i] & (mon_id_q   [i] == awid   ) &
                                                    (mon_addr_q [i] == awaddr ) &
                                                    (mon_len_q  [i] == awlen  ) &
                                                    (mon_size_q [i] == awsize ) &
                                                    (mon_burst_q[i] == awburst) &
                                                    (mon_cache_q[i] == awcache) &
                                                    (mon_prot_q [i] == awprot );
        // granularity: 128 byte
        assign sty_hit[i] = aw_hs  & mon_vld_q[i] & (mon_addr_q [i][A-1:7] == awaddr[A-1:7]);
    end

    assign mon_set  = ldx_hit_any ? ldx_hit : {X{ldx_en}} & mon_rpl_q;
    assign mon_clr  = sty_hit & {X{aw_hs & ~(awlock & ~stx_hit_any)}};

    assign ldx_succ = ldx_en;
    assign stx_succ = stx_hit_any;


    //
    // read

    reg  [  1:0] ar_fsm_q;
    reg  [  1:0] ar_fsm_nxt;

    wire reuse;

    always_comb begin
        ar_fsm_nxt = ar_fsm_q;

        case (ar_fsm_q)
        S_IDLE:
            if (ar_hs)
                ar_fsm_nxt = S_MEM;
        S_MEM:
            if (mem_re_qual)
                ar_fsm_nxt = S_RET;
        S_RET:
            if (r_hs)
                ar_fsm_nxt = rlast ? S_IDLE :
                             reuse ? S_RET  :
                                     S_MEM;
        default:
                ar_fsm_nxt = S_IDLE;
        endcase
    end

    always_ff @(posedge aclk or posedge arst)
        if (arst)
            ar_fsm_q <= S_IDLE;
        else
            ar_fsm_q <= ar_fsm_nxt;

    reg  [I-1:0] arid_q;
    reg  [A-1:0] araddr_q;
    reg  [  7:0] arlen0_q;
    reg  [  7:0] arlenv_q;
    reg  [  2:0] arsize_q;
    reg  [  1:0] arburst_q;
    reg          arresp_q;

    wire [A-1:0] araddr_nxt;
    wire [  7:0] arlenv_nxt = arlenv_q - 8'b1;

    addr_gen #(.A (A))
    u_ar (.len      (arlen0_q  ),
          .size     (arsize_q  ),
          .burst    (arburst_q ),
          .addr_cur (araddr_q  ),
          .addr_nxt (araddr_nxt));

    assign reuse = (araddr_q[A-1:L] == araddr_nxt[A-1:L]);

    always_ff @(posedge aclk)
        if (ar_hs) begin
            arid_q    <= arid;
            arlen0_q  <= arlen;
            arsize_q  <= arsize;
            arburst_q <= arburst;
            arresp_q  <= ldx_succ;
        end

    always_ff @(posedge aclk)
        if (ar_hs | r_hs) begin
            araddr_q  <= ar_hs ? araddr : araddr_nxt;
            arlenv_q  <= ar_hs ? arlen  : arlenv_nxt;
        end

    // output
    assign mem_re    = (ar_fsm_q == S_MEM);
    assign mem_raddr =  araddr_q[A-1:L];

    assign arready   = (ar_fsm_q == S_IDLE);

    assign rvalid    = (ar_fsm_q == S_RET);
    assign rid       =  arid_q;
    assign rdata     =  mem_rdata;
    assign rresp     = {1'b0, arresp_q};
    assign rlast     = (arlenv_q == 8'b0);


    //
    // write

    reg  [  1:0] aw_fsm_q;
    reg  [  1:0] aw_fsm_nxt;

    always_comb begin
        aw_fsm_nxt = aw_fsm_q;

        case (aw_fsm_q)
        S_IDLE:
            if (aw_hs)
                aw_fsm_nxt = S_MEM;
        S_MEM:
            if (w_hs & wlast)
                aw_fsm_nxt = S_RET;
        S_RET:
            if (b_hs)
                aw_fsm_nxt = S_IDLE;
        default:
                aw_fsm_nxt = S_IDLE;
        endcase
    end

    always_ff @(posedge aclk or posedge arst)
        if (arst)
            aw_fsm_q <= S_IDLE;
        else
            aw_fsm_q <= aw_fsm_nxt;

    reg  [I-1:0] awid_q;
    reg  [A-1:0] awaddr_q;
    reg  [  7:0] awlen0_q;
    reg  [  7:0] awlenv_q;
    reg  [  2:0] awsize_q;
    reg  [  1:0] awburst_q;
    reg          awresp_q;

    wire [A-1:0] awaddr_nxt;

    addr_gen #(.A (A))
    u_aw (.len      (awlen0_q  ),
          .size     (awsize_q  ),
          .burst    (awburst_q ),
          .addr_cur (awaddr_q  ),
          .addr_nxt (awaddr_nxt));

    always_ff @(posedge aclk)
        if (aw_hs) begin
            awid_q    <= awid;
            awlen0_q  <= awlen;
            awsize_q  <= awsize;
            awburst_q <= awburst;
            awresp_q  <= stx_succ;
        end

    always_ff @(posedge aclk)
        if (aw_hs | w_hs)
            awaddr_q  <= aw_hs ? awaddr : awaddr_nxt;

    // output
    assign mem_we    =  w_hs;
    assign mem_waddr =  awaddr_q[A-1:L];
    assign mem_wdata =  wdata;
    assign mem_wstrb =  wstrb;

    assign awready   = (aw_fsm_q == S_IDLE);

    assign wready    = (aw_fsm_q == S_MEM);

    assign bvalid    = (aw_fsm_q == S_RET);
    assign bid       =  awid_q;
    assign bresp     = {1'b0, awresp_q};

endmodule
