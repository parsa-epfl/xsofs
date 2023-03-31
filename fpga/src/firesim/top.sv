module top(
`include "cl_ports.vh"
);

    //
    // clock & reset

    wire       clk_sh   =  clk_main_a0;
    wire       rst_sh_n =  rst_main_n;

    wire       clk_cl;
    reg  [1:0] rst_cl_q;
    wire       rst_cl_n =  rst_cl_q[1];
    wire       rst_cl   = ~rst_cl_n;

    always_ff @(posedge clk_cl or negedge rst_sh_n)
        if (~rst_sh_n)
            rst_cl_q <=  2'b0;
        else
            rst_cl_q <= {rst_cl_q[0], ~sh_cl_flr_assert};

    clk_wiz
    u_clk_wiz (.clk_in  (clk_sh  ),
               .clk_out (clk_cl  ),
               .rst_n   (rst_sh_n));

    // back to sh
    reg  [1:0] flr_q;

    always_ff @(posedge clk_sh or negedge rst_sh_n)
        if (~rst_sh_n)
            flr_q <=  2'b0;
        else
            flr_q <= {flr_q[0], rst_cl};

    // pulse
    assign cl_sh_flr_done = flr_q[0] & ~flr_q[1];


    //
    // instantiations

    wire         ocl_arvalid;
    wire         ocl_arready;
    wire [ 31:0] ocl_araddr;
    wire         ocl_rvalid;
    wire         ocl_rready;
    wire [ 31:0] ocl_rdata;
    wire [  1:0] ocl_rresp;
    wire         ocl_awvalid;
    wire         ocl_awready;
    wire [ 31:0] ocl_awaddr;
    wire         ocl_wvalid;
    wire         ocl_wready;
    wire [ 31:0] ocl_wdata;
    wire [  3:0] ocl_wstrb;
    wire         ocl_bvalid;
    wire         ocl_bready;
    wire [  1:0] ocl_bresp;

    wire         dma_arvalid;
    wire         dma_arready;
    wire [  3:0] dma_arid;
    wire [ 63:0] dma_araddr;
    wire [  7:0] dma_arlen;
    wire [  2:0] dma_arsize;
    wire         dma_rvalid;
    wire         dma_rready;
    wire [  3:0] dma_rid;
    wire [511:0] dma_rdata;
    wire [  1:0] dma_rresp;
    wire         dma_rlast;
    wire         dma_awvalid;
    wire         dma_awready;
    wire [  3:0] dma_awid;
    wire [ 63:0] dma_awaddr;
    wire [  7:0] dma_awlen;
    wire [  2:0] dma_awsize;
    wire         dma_wvalid;
    wire         dma_wready;
    wire [511:0] dma_wdata;
    wire [ 63:0] dma_wstrb;
    wire         dma_wlast;
    wire         dma_bvalid;
    wire         dma_bready;
    wire [  3:0] dma_bid;
    wire [  1:0] dma_bresp;

    wire         mem_arvalid;
    wire         mem_arready;
    wire [ 15:0] mem_arid;
    wire [ 33:0] mem_araddr;
    wire [  7:0] mem_arlen;
    wire [  2:0] mem_arsize;
    wire [  1:0] mem_arburst;
    wire         mem_rvalid;
    wire         mem_rready;
    wire [ 15:0] mem_rid;
    wire [511:0] mem_rdata;
    wire [  1:0] mem_rresp;
    wire         mem_rlast;
    wire         mem_awvalid;
    wire         mem_awready;
    wire [ 15:0] mem_awid;
    wire [ 33:0] mem_awaddr;
    wire [  7:0] mem_awlen;
    wire [  2:0] mem_awsize;
    wire [  1:0] mem_awburst;
    wire         mem_wvalid;
    wire         mem_wready;
    wire [511:0] mem_wdata;
    wire [ 63:0] mem_wstrb;
    wire         mem_wlast;
    wire         mem_bvalid;
    wire         mem_bready;
    wire [ 15:0] mem_bid;
    wire [  1:0] mem_bresp;

    axi_clk_ocl
    u_axi_clk_ocl (.s_axi_aclk               (clk_sh                ),
                   .s_axi_aresetn            (rst_sh_n              ),
                   .s_axi_awaddr             (sh_ocl_awaddr         ),
                   .s_axi_awprot             (3'b0                  ),
                   .s_axi_awvalid            (sh_ocl_awvalid        ),
                   .s_axi_awready            (ocl_sh_awready        ),
                   .s_axi_wdata              (sh_ocl_wdata          ),
                   .s_axi_wstrb              (sh_ocl_wstrb          ),
                   .s_axi_wvalid             (sh_ocl_wvalid         ),
                   .s_axi_wready             (ocl_sh_wready         ),
                   .s_axi_bresp              (ocl_sh_bresp          ),
                   .s_axi_bvalid             (ocl_sh_bvalid         ),
                   .s_axi_bready             (sh_ocl_bready         ),
                   .s_axi_araddr             (sh_ocl_araddr         ),
                   .s_axi_arprot             (3'b0                  ),
                   .s_axi_arvalid            (sh_ocl_arvalid        ),
                   .s_axi_arready            (ocl_sh_arready        ),
                   .s_axi_rdata              (ocl_sh_rdata          ),
                   .s_axi_rresp              (ocl_sh_rresp          ),
                   .s_axi_rvalid             (ocl_sh_rvalid         ),
                   .s_axi_rready             (sh_ocl_rready         ),
                   .m_axi_aclk               (clk_cl                ),
                   .m_axi_aresetn            (rst_cl_n              ),
                   .m_axi_awaddr             (ocl_awaddr            ),
                   .m_axi_awprot             (                      ),
                   .m_axi_awvalid            (ocl_awvalid           ),
                   .m_axi_awready            (ocl_awready           ),
                   .m_axi_wdata              (ocl_wdata             ),
                   .m_axi_wstrb              (ocl_wstrb             ),
                   .m_axi_wvalid             (ocl_wvalid            ),
                   .m_axi_wready             (ocl_wready            ),
                   .m_axi_bresp              (ocl_bresp             ),
                   .m_axi_bvalid             (ocl_bvalid            ),
                   .m_axi_bready             (ocl_bready            ),
                   .m_axi_araddr             (ocl_araddr            ),
                   .m_axi_arprot             (                      ),
                   .m_axi_arvalid            (ocl_arvalid           ),
                   .m_axi_arready            (ocl_arready           ),
                   .m_axi_rdata              (ocl_rdata             ),
                   .m_axi_rresp              (ocl_rresp             ),
                   .m_axi_rvalid             (ocl_rvalid            ),
                   .m_axi_rready             (ocl_rready            ));

    axi_clk_dma
    u_axi_clk_dma (.s_axi_aclk               (clk_sh                ),
                   .s_axi_aresetn            (rst_sh_n              ),
                   .s_axi_awid               (sh_cl_dma_pcis_awid   ),
                   .s_axi_awaddr             (sh_cl_dma_pcis_awaddr ),
                   .s_axi_awlen              (sh_cl_dma_pcis_awlen  ),
                   .s_axi_awsize             (sh_cl_dma_pcis_awsize ),
                   .s_axi_awburst            (2'b1                  ),
                   .s_axi_awlock             (1'b0                  ),
                   .s_axi_awcache            (4'b0                  ),
                   .s_axi_awprot             (3'b0                  ),
                   .s_axi_awregion           (4'b0                  ),
                   .s_axi_awqos              (4'b0                  ),
                   .s_axi_awvalid            (sh_cl_dma_pcis_awvalid),
                   .s_axi_awready            (cl_sh_dma_pcis_awready),
                   .s_axi_wdata              (sh_cl_dma_pcis_wdata  ),
                   .s_axi_wstrb              (sh_cl_dma_pcis_wstrb  ),
                   .s_axi_wlast              (sh_cl_dma_pcis_wlast  ),
                   .s_axi_wvalid             (sh_cl_dma_pcis_wvalid ),
                   .s_axi_wready             (cl_sh_dma_pcis_wready ),
                   .s_axi_bid                (cl_sh_dma_pcis_bid    ),
                   .s_axi_bresp              (cl_sh_dma_pcis_bresp  ),
                   .s_axi_bvalid             (cl_sh_dma_pcis_bvalid ),
                   .s_axi_bready             (sh_cl_dma_pcis_bready ),
                   .s_axi_arid               (sh_cl_dma_pcis_arid   ),
                   .s_axi_araddr             (sh_cl_dma_pcis_araddr ),
                   .s_axi_arlen              (sh_cl_dma_pcis_arlen  ),
                   .s_axi_arsize             (sh_cl_dma_pcis_arsize ),
                   .s_axi_arburst            (2'b1                  ),
                   .s_axi_arlock             (1'b0                  ),
                   .s_axi_arcache            (4'b0                  ),
                   .s_axi_arprot             (3'b0                  ),
                   .s_axi_arregion           (4'b0                  ),
                   .s_axi_arqos              (4'b0                  ),
                   .s_axi_arvalid            (sh_cl_dma_pcis_arvalid),
                   .s_axi_arready            (cl_sh_dma_pcis_arready),
                   .s_axi_rid                (cl_sh_dma_pcis_rid    ),
                   .s_axi_rdata              (cl_sh_dma_pcis_rdata  ),
                   .s_axi_rresp              (cl_sh_dma_pcis_rresp  ),
                   .s_axi_rlast              (cl_sh_dma_pcis_rlast  ),
                   .s_axi_rvalid             (cl_sh_dma_pcis_rvalid ),
                   .s_axi_rready             (sh_cl_dma_pcis_rready ),
                   .m_axi_aclk               (clk_cl                ),
                   .m_axi_aresetn            (rst_cl_n              ),
                   .m_axi_awid               (dma_awid              ),
                   .m_axi_awaddr             (dma_awaddr            ),
                   .m_axi_awlen              (dma_awlen             ),
                   .m_axi_awsize             (dma_awsize            ),
                   .m_axi_awburst            (                      ),
                   .m_axi_awlock             (                      ),
                   .m_axi_awcache            (                      ),
                   .m_axi_awprot             (                      ),
                   .m_axi_awregion           (                      ),
                   .m_axi_awqos              (                      ),
                   .m_axi_awvalid            (dma_awvalid           ),
                   .m_axi_awready            (dma_awready           ),
                   .m_axi_wdata              (dma_wdata             ),
                   .m_axi_wstrb              (dma_wstrb             ),
                   .m_axi_wlast              (dma_wlast             ),
                   .m_axi_wvalid             (dma_wvalid            ),
                   .m_axi_wready             (dma_wready            ),
                   .m_axi_bid                (dma_bid               ),
                   .m_axi_bresp              (dma_bresp             ),
                   .m_axi_bvalid             (dma_bvalid            ),
                   .m_axi_bready             (dma_bready            ),
                   .m_axi_arid               (dma_arid              ),
                   .m_axi_araddr             (dma_araddr            ),
                   .m_axi_arlen              (dma_arlen             ),
                   .m_axi_arsize             (dma_arsize            ),
                   .m_axi_arburst            (                      ),
                   .m_axi_arlock             (                      ),
                   .m_axi_arcache            (                      ),
                   .m_axi_arprot             (                      ),
                   .m_axi_arregion           (                      ),
                   .m_axi_arqos              (                      ),
                   .m_axi_arvalid            (dma_arvalid           ),
                   .m_axi_arready            (dma_arready           ),
                   .m_axi_rid                (dma_rid               ),
                   .m_axi_rdata              (dma_rdata             ),
                   .m_axi_rresp              (dma_rresp             ),
                   .m_axi_rlast              (dma_rlast             ),
                   .m_axi_rvalid             (dma_rvalid            ),
                   .m_axi_rready             (dma_rready            ));

    assign cl_sh_dma_rd_full = 1'b0;
    assign cl_sh_dma_wr_full = 1'b0;

    axi_clk_mem
    u_axi_clk_mem (.s_axi_aclk               (clk_cl                ),
                   .s_axi_aresetn            (rst_cl_n              ),
                   .s_axi_awid               (mem_awid              ),
                   .s_axi_awaddr             (mem_awaddr            ),
                   .s_axi_awlen              (mem_awlen             ),
                   .s_axi_awsize             (mem_awsize            ),
                   .s_axi_awburst            (mem_awburst           ),
                   .s_axi_awlock             (1'b0                  ),
                   .s_axi_awcache            (4'b0                  ),
                   .s_axi_awprot             (3'b0                  ),
                   .s_axi_awregion           (4'b0                  ),
                   .s_axi_awqos              (4'b0                  ),
                   .s_axi_awvalid            (mem_awvalid           ),
                   .s_axi_awready            (mem_awready           ),
                   .s_axi_wdata              (mem_wdata             ),
                   .s_axi_wstrb              (mem_wstrb             ),
                   .s_axi_wlast              (mem_wlast             ),
                   .s_axi_wvalid             (mem_wvalid            ),
                   .s_axi_wready             (mem_wready            ),
                   .s_axi_bid                (mem_bid               ),
                   .s_axi_bresp              (mem_bresp             ),
                   .s_axi_bvalid             (mem_bvalid            ),
                   .s_axi_bready             (mem_bready            ),
                   .s_axi_arid               (mem_arid              ),
                   .s_axi_araddr             (mem_araddr            ),
                   .s_axi_arlen              (mem_arlen             ),
                   .s_axi_arsize             (mem_arsize            ),
                   .s_axi_arburst            (mem_arburst           ),
                   .s_axi_arlock             (1'b0                  ),
                   .s_axi_arcache            (4'b0                  ),
                   .s_axi_arprot             (3'b0                  ),
                   .s_axi_arregion           (4'b0                  ),
                   .s_axi_arqos              (4'b0                  ),
                   .s_axi_arvalid            (mem_arvalid           ),
                   .s_axi_arready            (mem_arready           ),
                   .s_axi_rid                (mem_rid               ),
                   .s_axi_rdata              (mem_rdata             ),
                   .s_axi_rresp              (mem_rresp             ),
                   .s_axi_rlast              (mem_rlast             ),
                   .s_axi_rvalid             (mem_rvalid            ),
                   .s_axi_rready             (mem_rready            ),
                   .m_axi_aclk               (clk_sh                ),
                   .m_axi_aresetn            (rst_sh_n              ),
                   .m_axi_awid               (cl_sh_ddr_awid        ),
                   .m_axi_awaddr             (cl_sh_ddr_awaddr[33:0]),
                   .m_axi_awlen              (cl_sh_ddr_awlen       ),
                   .m_axi_awsize             (cl_sh_ddr_awsize      ),
                   .m_axi_awburst            (cl_sh_ddr_awburst     ),
                   .m_axi_awlock             (                      ),
                   .m_axi_awcache            (                      ),
                   .m_axi_awprot             (                      ),
                   .m_axi_awregion           (                      ),
                   .m_axi_awqos              (                      ),
                   .m_axi_awvalid            (cl_sh_ddr_awvalid     ),
                   .m_axi_awready            (sh_cl_ddr_awready     ),
                   .m_axi_wdata              (cl_sh_ddr_wdata       ),
                   .m_axi_wstrb              (cl_sh_ddr_wstrb       ),
                   .m_axi_wlast              (cl_sh_ddr_wlast       ),
                   .m_axi_wvalid             (cl_sh_ddr_wvalid      ),
                   .m_axi_wready             (sh_cl_ddr_wready      ),
                   .m_axi_bid                (sh_cl_ddr_bid         ),
                   .m_axi_bresp              (sh_cl_ddr_bresp       ),
                   .m_axi_bvalid             (sh_cl_ddr_bvalid      ),
                   .m_axi_bready             (cl_sh_ddr_bready      ),
                   .m_axi_arid               (cl_sh_ddr_arid        ),
                   .m_axi_araddr             (cl_sh_ddr_araddr[33:0]),
                   .m_axi_arlen              (cl_sh_ddr_arlen       ),
                   .m_axi_arsize             (cl_sh_ddr_arsize      ),
                   .m_axi_arburst            (cl_sh_ddr_arburst     ),
                   .m_axi_arlock             (                      ),
                   .m_axi_arcache            (                      ),
                   .m_axi_arprot             (                      ),
                   .m_axi_arregion           (                      ),
                   .m_axi_arqos              (                      ),
                   .m_axi_arvalid            (cl_sh_ddr_arvalid     ),
                   .m_axi_arready            (sh_cl_ddr_arready     ),
                   .m_axi_rid                (sh_cl_ddr_rid         ),
                   .m_axi_rdata              (sh_cl_ddr_rdata       ),
                   .m_axi_rresp              (sh_cl_ddr_rresp       ),
                   .m_axi_rlast              (sh_cl_ddr_rlast       ),
                   .m_axi_rvalid             (sh_cl_ddr_rvalid      ),
                   .m_axi_rready             (cl_sh_ddr_rready      ));

    assign cl_sh_ddr_araddr[63:34] = 30'b0;
    assign cl_sh_ddr_awaddr[63:34] = 30'b0;
    assign cl_sh_ddr_wid           = 16'b0;

    F1Shim
    u_dut         (.clock                    (clk_cl                ),
                   .reset                    (rst_cl                ),
                   .io_master_aw_ready       (ocl_awready           ),
                   .io_master_aw_valid       (ocl_awvalid           ),
                   .io_master_aw_bits_addr   (ocl_awaddr            ),
                   .io_master_aw_bits_len    (8'b0                  ),
                   .io_master_aw_bits_size   (3'h2                  ),
                   .io_master_aw_bits_burst  (2'b1                  ),
                   .io_master_aw_bits_lock   (1'b0                  ),
                   .io_master_aw_bits_cache  (4'b0                  ),
                   .io_master_aw_bits_prot   (3'b0                  ),
                   .io_master_aw_bits_qos    (4'b0                  ),
                   .io_master_aw_bits_region (4'b0                  ),
                   .io_master_aw_bits_user   (1'b0                  ),
                   .io_master_w_ready        (ocl_wready            ),
                   .io_master_w_valid        (ocl_wvalid            ),
                   .io_master_w_bits_data    (ocl_wdata             ),
                   .io_master_w_bits_last    (1'b1                  ),
                   .io_master_w_bits_strb    (ocl_wstrb             ),
                   .io_master_w_bits_user    (1'b0                  ),
                   .io_master_b_ready        (ocl_bready            ),
                   .io_master_b_valid        (ocl_bvalid            ),
                   .io_master_b_bits_resp    (ocl_bresp             ),
                   .io_master_b_bits_user    (                      ),
                   .io_master_ar_ready       (ocl_arready           ),
                   .io_master_ar_valid       (ocl_arvalid           ),
                   .io_master_ar_bits_addr   (ocl_araddr            ),
                   .io_master_ar_bits_len    (8'b0                  ),
                   .io_master_ar_bits_size   (3'h2                  ),
                   .io_master_ar_bits_burst  (2'b1                  ),
                   .io_master_ar_bits_lock   (1'b0                  ),
                   .io_master_ar_bits_cache  (4'b0                  ),
                   .io_master_ar_bits_prot   (3'b0                  ),
                   .io_master_ar_bits_qos    (4'b0                  ),
                   .io_master_ar_bits_region (4'b0                  ),
                   .io_master_ar_bits_user   (1'b0                  ),
                   .io_master_r_ready        (ocl_rready            ),
                   .io_master_r_valid        (ocl_rvalid            ),
                   .io_master_r_bits_resp    (ocl_rresp             ),
                   .io_master_r_bits_data    (ocl_rdata             ),
                   .io_master_r_bits_last    (                      ),
                   .io_master_r_bits_user    (                      ),
                   .io_dma_aw_ready          (dma_awready           ),
                   .io_dma_aw_valid          (dma_awvalid           ),
                   .io_dma_aw_bits_addr      (dma_awaddr            ),
                   .io_dma_aw_bits_len       (dma_awlen             ),
                   .io_dma_aw_bits_size      (dma_awsize            ),
                   .io_dma_aw_bits_burst     (2'b1                  ),
                   .io_dma_aw_bits_lock      (1'b0                  ),
                   .io_dma_aw_bits_cache     (4'b0                  ),
                   .io_dma_aw_bits_prot      (3'b0                  ),
                   .io_dma_aw_bits_qos       (4'b0                  ),
                   .io_dma_aw_bits_region    (4'b0                  ),
                   .io_dma_aw_bits_id        (dma_awid              ),
                   .io_dma_aw_bits_user      (1'b0                  ),
                   .io_dma_w_ready           (dma_wready            ),
                   .io_dma_w_valid           (dma_wvalid            ),
                   .io_dma_w_bits_data       (dma_wdata             ),
                   .io_dma_w_bits_last       (dma_wlast             ),
                   .io_dma_w_bits_id         (                      ),
                   .io_dma_w_bits_strb       (dma_wstrb             ),
                   .io_dma_w_bits_user       (1'b0                  ),
                   .io_dma_b_ready           (dma_bready            ),
                   .io_dma_b_valid           (dma_bvalid            ),
                   .io_dma_b_bits_resp       (dma_bresp             ),
                   .io_dma_b_bits_id         (dma_bid               ),
                   .io_dma_b_bits_user       (                      ),
                   .io_dma_ar_ready          (dma_arready           ),
                   .io_dma_ar_valid          (dma_arvalid           ),
                   .io_dma_ar_bits_addr      (dma_araddr            ),
                   .io_dma_ar_bits_len       (dma_arlen             ),
                   .io_dma_ar_bits_size      (dma_arsize            ),
                   .io_dma_ar_bits_burst     (2'b1                  ),
                   .io_dma_ar_bits_lock      (1'b0                  ),
                   .io_dma_ar_bits_cache     (4'b0                  ),
                   .io_dma_ar_bits_prot      (3'b0                  ),
                   .io_dma_ar_bits_qos       (4'b0                  ),
                   .io_dma_ar_bits_region    (4'b0                  ),
                   .io_dma_ar_bits_id        (dma_arid              ),
                   .io_dma_ar_bits_user      (1'b0                  ),
                   .io_dma_r_ready           (dma_rready            ),
                   .io_dma_r_valid           (dma_rvalid            ),
                   .io_dma_r_bits_resp       (dma_rresp             ),
                   .io_dma_r_bits_data       (dma_rdata             ),
                   .io_dma_r_bits_last       (dma_rlast             ),
                   .io_dma_r_bits_id         (dma_rid               ),
                   .io_dma_r_bits_user       (                      ),
                   .io_slave_3_aw_ready      (1'b1                  ),
                   .io_slave_3_aw_valid      (                      ),
                   .io_slave_3_aw_bits_id    (                      ),
                   .io_slave_3_aw_bits_addr  (                      ),
                   .io_slave_3_aw_bits_len   (                      ),
                   .io_slave_3_aw_bits_size  (                      ),
                   .io_slave_3_aw_bits_burst (                      ),
                   .io_slave_3_aw_bits_lock  (                      ),
                   .io_slave_3_aw_bits_cache (                      ),
                   .io_slave_3_aw_bits_prot  (                      ),
                   .io_slave_3_aw_bits_qos   (                      ),
                   .io_slave_3_w_ready       (1'b1                  ),
                   .io_slave_3_w_valid       (                      ),
                   .io_slave_3_w_bits_data   (                      ),
                   .io_slave_3_w_bits_strb   (                      ),
                   .io_slave_3_w_bits_last   (                      ),
                   .io_slave_3_b_ready       (                      ),
                   .io_slave_3_b_valid       (1'b0                  ),
                   .io_slave_3_b_bits_id     (                      ),
                   .io_slave_3_b_bits_resp   (                      ),
                   .io_slave_3_ar_ready      (1'b1                  ),
                   .io_slave_3_ar_valid      (                      ),
                   .io_slave_3_ar_bits_id    (                      ),
                   .io_slave_3_ar_bits_addr  (                      ),
                   .io_slave_3_ar_bits_len   (                      ),
                   .io_slave_3_ar_bits_size  (                      ),
                   .io_slave_3_ar_bits_burst (                      ),
                   .io_slave_3_ar_bits_lock  (                      ),
                   .io_slave_3_ar_bits_cache (                      ),
                   .io_slave_3_ar_bits_prot  (                      ),
                   .io_slave_3_ar_bits_qos   (                      ),
                   .io_slave_3_r_ready       (                      ),
                   .io_slave_3_r_valid       (1'b0                  ),
                   .io_slave_3_r_bits_id     (                      ),
                   .io_slave_3_r_bits_data   (                      ),
                   .io_slave_3_r_bits_resp   (                      ),
                   .io_slave_3_r_bits_last   (                      ),
                   .io_slave_2_aw_ready      (1'b1                  ),
                   .io_slave_2_aw_valid      (                      ),
                   .io_slave_2_aw_bits_id    (                      ),
                   .io_slave_2_aw_bits_addr  (                      ),
                   .io_slave_2_aw_bits_len   (                      ),
                   .io_slave_2_aw_bits_size  (                      ),
                   .io_slave_2_aw_bits_burst (                      ),
                   .io_slave_2_aw_bits_lock  (                      ),
                   .io_slave_2_aw_bits_cache (                      ),
                   .io_slave_2_aw_bits_prot  (                      ),
                   .io_slave_2_aw_bits_qos   (                      ),
                   .io_slave_2_w_ready       (1'b1                  ),
                   .io_slave_2_w_valid       (                      ),
                   .io_slave_2_w_bits_data   (                      ),
                   .io_slave_2_w_bits_strb   (                      ),
                   .io_slave_2_w_bits_last   (                      ),
                   .io_slave_2_b_ready       (                      ),
                   .io_slave_2_b_valid       (1'b0                  ),
                   .io_slave_2_b_bits_id     (                      ),
                   .io_slave_2_b_bits_resp   (                      ),
                   .io_slave_2_ar_ready      (1'b1                  ),
                   .io_slave_2_ar_valid      (                      ),
                   .io_slave_2_ar_bits_id    (                      ),
                   .io_slave_2_ar_bits_addr  (                      ),
                   .io_slave_2_ar_bits_len   (                      ),
                   .io_slave_2_ar_bits_size  (                      ),
                   .io_slave_2_ar_bits_burst (                      ),
                   .io_slave_2_ar_bits_lock  (                      ),
                   .io_slave_2_ar_bits_cache (                      ),
                   .io_slave_2_ar_bits_prot  (                      ),
                   .io_slave_2_ar_bits_qos   (                      ),
                   .io_slave_2_r_ready       (                      ),
                   .io_slave_2_r_valid       (1'b0                  ),
                   .io_slave_2_r_bits_id     (                      ),
                   .io_slave_2_r_bits_data   (                      ),
                   .io_slave_2_r_bits_resp   (                      ),
                   .io_slave_2_r_bits_last   (                      ),
                   .io_slave_1_aw_ready      (1'b1                  ),
                   .io_slave_1_aw_valid      (                      ),
                   .io_slave_1_aw_bits_id    (                      ),
                   .io_slave_1_aw_bits_addr  (                      ),
                   .io_slave_1_aw_bits_len   (                      ),
                   .io_slave_1_aw_bits_size  (                      ),
                   .io_slave_1_aw_bits_burst (                      ),
                   .io_slave_1_aw_bits_lock  (                      ),
                   .io_slave_1_aw_bits_cache (                      ),
                   .io_slave_1_aw_bits_prot  (                      ),
                   .io_slave_1_aw_bits_qos   (                      ),
                   .io_slave_1_w_ready       (1'b1                  ),
                   .io_slave_1_w_valid       (                      ),
                   .io_slave_1_w_bits_data   (                      ),
                   .io_slave_1_w_bits_strb   (                      ),
                   .io_slave_1_w_bits_last   (                      ),
                   .io_slave_1_b_ready       (                      ),
                   .io_slave_1_b_valid       (1'b0                  ),
                   .io_slave_1_b_bits_id     (                      ),
                   .io_slave_1_b_bits_resp   (                      ),
                   .io_slave_1_ar_ready      (1'b1                  ),
                   .io_slave_1_ar_valid      (                      ),
                   .io_slave_1_ar_bits_id    (                      ),
                   .io_slave_1_ar_bits_addr  (                      ),
                   .io_slave_1_ar_bits_len   (                      ),
                   .io_slave_1_ar_bits_size  (                      ),
                   .io_slave_1_ar_bits_burst (                      ),
                   .io_slave_1_ar_bits_lock  (                      ),
                   .io_slave_1_ar_bits_cache (                      ),
                   .io_slave_1_ar_bits_prot  (                      ),
                   .io_slave_1_ar_bits_qos   (                      ),
                   .io_slave_1_r_ready       (                      ),
                   .io_slave_1_r_valid       (1'b0                  ),
                   .io_slave_1_r_bits_id     (                      ),
                   .io_slave_1_r_bits_data   (                      ),
                   .io_slave_1_r_bits_resp   (                      ),
                   .io_slave_1_r_bits_last   (                      ),
                   .io_slave_0_aw_ready      (mem_awready           ),
                   .io_slave_0_aw_valid      (mem_awvalid           ),
                   .io_slave_0_aw_bits_id    (mem_awid              ),
                   .io_slave_0_aw_bits_addr  (mem_awaddr            ),
                   .io_slave_0_aw_bits_len   (mem_awlen             ),
                   .io_slave_0_aw_bits_size  (mem_awsize            ),
                   .io_slave_0_aw_bits_burst (mem_awburst           ),
                   .io_slave_0_aw_bits_lock  (                      ),
                   .io_slave_0_aw_bits_cache (                      ),
                   .io_slave_0_aw_bits_prot  (                      ),
                   .io_slave_0_aw_bits_qos   (                      ),
                   .io_slave_0_w_ready       (mem_wready            ),
                   .io_slave_0_w_valid       (mem_wvalid            ),
                   .io_slave_0_w_bits_data   (mem_wdata             ),
                   .io_slave_0_w_bits_strb   (mem_wstrb             ),
                   .io_slave_0_w_bits_last   (mem_wlast             ),
                   .io_slave_0_b_ready       (mem_bready            ),
                   .io_slave_0_b_valid       (mem_bvalid            ),
                   .io_slave_0_b_bits_id     (mem_bid               ),
                   .io_slave_0_b_bits_resp   (mem_bresp             ),
                   .io_slave_0_ar_ready      (mem_arready           ),
                   .io_slave_0_ar_valid      (mem_arvalid           ),
                   .io_slave_0_ar_bits_id    (mem_arid              ),
                   .io_slave_0_ar_bits_addr  (mem_araddr            ),
                   .io_slave_0_ar_bits_len   (mem_arlen             ),
                   .io_slave_0_ar_bits_size  (mem_arsize            ),
                   .io_slave_0_ar_bits_burst (mem_arburst           ),
                   .io_slave_0_ar_bits_lock  (                      ),
                   .io_slave_0_ar_bits_cache (                      ),
                   .io_slave_0_ar_bits_prot  (                      ),
                   .io_slave_0_ar_bits_qos   (                      ),
                   .io_slave_0_r_ready       (mem_rready            ),
                   .io_slave_0_r_valid       (mem_rvalid            ),
                   .io_slave_0_r_bits_id     (mem_rid               ),
                   .io_slave_0_r_bits_data   (mem_rdata             ),
                   .io_slave_0_r_bits_resp   (mem_rresp             ),
                   .io_slave_0_r_bits_last   (mem_rlast             ));

    cl_debug_bridge
    u_dbg         (.clk                      (clk_sh                ),
                   .S_BSCAN_drck             (drck                  ),
                   .S_BSCAN_shift            (shift                 ),
                   .S_BSCAN_tdi              (tdi                   ),
                   .S_BSCAN_update           (update                ),
                   .S_BSCAN_sel              (sel                   ),
                   .S_BSCAN_tdo              (tdo                   ),
                   .S_BSCAN_tms              (tms                   ),
                   .S_BSCAN_tck              (tck                   ),
                   .S_BSCAN_runtest          (runtest               ),
                   .S_BSCAN_reset            (reset                 ),
                   .S_BSCAN_capture          (capture               ),
                   .S_BSCAN_bscanid_en       (bscanid_en            ));


    //
    // tie-offs

    wire rst_main_n_sync = rst_main_n;

`include "unused_apppf_irq_template.inc"
`include "unused_cl_sda_template.inc"
`include "unused_ddr_a_b_d_template.inc"
`include "unused_pcim_template.inc"
`include "unused_sh_bar1_template.inc"

    assign cl_sh_status0     = 32'b0;
    assign cl_sh_status1     = 32'b0;
    assign cl_sh_id0         = 32'hf0001d0f;
    assign cl_sh_id1         = 32'h1d51fedd;
    assign cl_sh_status_vled = 16'b0;

endmodule
