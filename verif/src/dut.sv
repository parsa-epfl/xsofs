// See LICENSE.md for license details

module dut(
    input wire clock,
    input wire reset
);

    parameter STDOUT = 32'h80000001;
    parameter STDERR = 32'h80000002;

    wire         awready;
    wire         awvalid;
    wire [ 13:0] awid;
    wire [ 35:0] awaddr;
    wire [  7:0] awlen;
    wire [  2:0] awsize;
    wire [  1:0] awburst;
    wire         awlock;
    wire [  3:0] awcache;
    wire [  2:0] awprot;
    wire [  3:0] awqos;
    wire         wready;
    wire         wvalid;
    wire [255:0] wdata;
    wire [ 31:0] wstrb;
    wire         wlast;
    wire         bready;
    wire         bvalid;
    wire [ 13:0] bid;
    wire [  1:0] bresp;
    wire         arready;
    wire         arvalid;
    wire [ 13:0] arid;
    wire [ 35:0] araddr;
    wire [  7:0] arlen;
    wire [  2:0] arsize;
    wire [  1:0] arburst;
    wire         arlock;
    wire [  3:0] arcache;
    wire [  2:0] arprot;
    wire [  3:0] arqos;
    wire         rready;
    wire         rvalid;
    wire [ 13:0] rid;
    wire [255:0] rdata;
    wire [  1:0] rresp;
    wire         rlast;
    wire         jtag_tck;
    wire         jtag_tms;
    wire         jtag_tdi;
    wire         jtag_tdo_en;
    wire         jtag_tdo_dat;
    wire         uart_tx_vld;
    wire [  7:0] uart_tx_chr;
    wire         uart_rx_vld;
    wire [  7:0] uart_rx_chr;

    Dut
    u_dut (.clock               (clock       ),
           .reset               (reset       ),
           .mem_0_aw_ready      (awready     ),
           .mem_0_aw_valid      (awvalid     ),
           .mem_0_aw_bits_id    (awid        ),
           .mem_0_aw_bits_addr  (awaddr      ),
           .mem_0_aw_bits_len   (awlen       ),
           .mem_0_aw_bits_size  (awsize      ),
           .mem_0_aw_bits_burst (awburst     ),
           .mem_0_aw_bits_lock  (awlock      ),
           .mem_0_aw_bits_cache (awcache     ),
           .mem_0_aw_bits_prot  (awprot      ),
           .mem_0_aw_bits_qos   (awqos       ),
           .mem_0_w_ready       (wready      ),
           .mem_0_w_valid       (wvalid      ),
           .mem_0_w_bits_data   (wdata       ),
           .mem_0_w_bits_strb   (wstrb       ),
           .mem_0_w_bits_last   (wlast       ),
           .mem_0_b_ready       (bready      ),
           .mem_0_b_valid       (bvalid      ),
           .mem_0_b_bits_id     (bid         ),
           .mem_0_b_bits_resp   (bresp       ),
           .mem_0_ar_ready      (arready     ),
           .mem_0_ar_valid      (arvalid     ),
           .mem_0_ar_bits_id    (arid        ),
           .mem_0_ar_bits_addr  (araddr      ),
           .mem_0_ar_bits_len   (arlen       ),
           .mem_0_ar_bits_size  (arsize      ),
           .mem_0_ar_bits_burst (arburst     ),
           .mem_0_ar_bits_lock  (arlock      ),
           .mem_0_ar_bits_cache (arcache     ),
           .mem_0_ar_bits_prot  (arprot      ),
           .mem_0_ar_bits_qos   (arqos       ),
           .mem_0_r_ready       (rready      ),
           .mem_0_r_valid       (rvalid      ),
           .mem_0_r_bits_id     (rid         ),
           .mem_0_r_bits_data   (rdata       ),
           .mem_0_r_bits_resp   (rresp       ),
           .mem_0_r_bits_last   (rlast       ),
           .uart_out_valid      (uart_tx_vld ),
           .uart_out_ch         (uart_tx_chr ),
           .uart_in_valid       (uart_rx_vld ),
           .uart_in_ch          (uart_rx_chr ),
           .jtag_TCK            (jtag_tck    ),
           .jtag_TMS            (jtag_tms    ),
           .jtag_TDI            (jtag_tdi    ),
           .jtag_TDO_driven     (jtag_tdo_en ),
           .jtag_TDO_data       (jtag_tdo_dat));

    wire [35:0] araddr_sub = {araddr[35:31] - 5'b1, araddr[30:0]};
    wire [35:0] awaddr_sub = {awaddr[35:31] - 5'b1, awaddr[30:0]};

    mem  #(.A                   ( 36         ),
           .D                   (256         ),
           .S                   ( 32         ),
           .I                   ( 14         ),
           .F                   ("bin"       ),
           .G                   ("img"       ))
    u_mem (.aclk                (clock       ),
           .arst                (reset       ),
           .awready             (awready     ),
           .awvalid             (awvalid     ),
           .awid                (awid        ),
           .awaddr              (awaddr_sub  ),
           .awlen               (awlen       ),
           .awsize              (awsize      ),
           .awburst             (awburst     ),
           .awlock              (awlock      ),
           .awcache             (awcache     ),
           .awprot              (awprot      ),
           .wready              (wready      ),
           .wvalid              (wvalid      ),
           .wdata               (wdata       ),
           .wstrb               (wstrb       ),
           .wlast               (wlast       ),
           .bready              (bready      ),
           .bvalid              (bvalid      ),
           .bid                 (bid         ),
           .bresp               (bresp       ),
           .arready             (arready     ),
           .arvalid             (arvalid     ),
           .arid                (arid        ),
           .araddr              (araddr_sub  ),
           .arlen               (arlen       ),
           .arsize              (arsize      ),
           .arburst             (arburst     ),
           .arlock              (arlock      ),
           .arcache             (arcache     ),
           .arprot              (arprot      ),
           .rready              (rready      ),
           .rvalid              (rvalid      ),
           .rid                 (rid         ),
           .rdata               (rdata       ),
           .rresp               (rresp       ),
           .rlast               (rlast       ));

    reg  [ 1:0] rst_q;

    always_ff @(posedge clock or posedge reset)
        if (reset)
            rst_q <=  2'h0;
        else
            rst_q <= {rst_q[0], 1'b1};

    reg         jtag;
    wire [31:0] jtag_exit;

    initial begin
        jtag = $test$plusargs("jtag");
    end

    SimJTAG #(.TICK_DELAY (0))
    u_sim (.clock               (clock       ),
           .reset               (reset       ),
           .enable              (jtag        ),
           .init_done           (rst_q[1]    ),
           .jtag_TCK            (jtag_tck    ),
           .jtag_TMS            (jtag_tms    ),
           .jtag_TDI            (jtag_tdi    ),
           .jtag_TRSTn          (            ),
           .jtag_TDO_data       (jtag_tdo_dat),
           .jtag_TDO_driven     (jtag_tdo_en ),
           .exit                (jtag_exit   ));

    always_ff @(posedge clock or posedge reset)
        if (~reset & |jtag_exit) begin
            $display("jtag: %0d %0d", $time(), jtag_exit);
            $finish();
        end


    //
    // uart

    always_ff @(posedge clock)
        if (~reset & uart_tx_vld) begin
            $fwrite(STDOUT,           "%c",            uart_tx_chr);
            $fwrite(STDERR, "uart: %0d %c\n", $time(), uart_tx_chr);
        end

endmodule
