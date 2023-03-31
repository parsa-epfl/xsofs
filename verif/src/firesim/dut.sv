module dut(
    input wire clock,
    input wire reset
);

    wire         ctrl_aw_ready;
    wire         ctrl_aw_valid;
    wire [ 63:0] ctrl_aw_bits_addr;
    wire [  7:0] ctrl_aw_bits_len;
    wire [  7:0] ctrl_aw_bits_size;
//  wire [  1:0] ctrl_aw_bits_burst;
//  wire         ctrl_aw_bits_lock;
//  wire [  3:0] ctrl_aw_bits_cache;
//  wire [  2:0] ctrl_aw_bits_prot;
//  wire [  3:0] ctrl_aw_bits_qos;
//  wire [  3:0] ctrl_aw_bits_region;
    wire [ 31:0] ctrl_aw_bits_id;
//  wire         ctrl_aw_bits_user;
    wire         ctrl_w_ready;
    wire         ctrl_w_valid;
    wire [511:0] ctrl_w_bits_data;
    wire         ctrl_w_bits_last;
    wire [ 31:0] ctrl_w_bits_id;
    wire [ 63:0] ctrl_w_bits_strb;
//  wire         ctrl_w_bits_user;
    wire         ctrl_b_ready;
    wire         ctrl_b_valid;
//  wire [  1:0] ctrl_b_bits_resp;
    wire [ 31:0] ctrl_b_bits_id;
//  wire         ctrl_b_bits_user;
    wire         ctrl_ar_ready;
    wire         ctrl_ar_valid;
    wire [ 63:0] ctrl_ar_bits_addr;
    wire [  7:0] ctrl_ar_bits_len;
    wire [  7:0] ctrl_ar_bits_size;
//  wire [  1:0] ctrl_ar_bits_burst;
//  wire         ctrl_ar_bits_lock;
//  wire [  3:0] ctrl_ar_bits_cache;
//  wire [  2:0] ctrl_ar_bits_prot;
//  wire [  3:0] ctrl_ar_bits_qos;
//  wire [  3:0] ctrl_ar_bits_region;
    wire [ 31:0] ctrl_ar_bits_id;
//  wire         ctrl_ar_bits_user;
    wire         ctrl_r_ready;
    wire         ctrl_r_valid;
//  wire [  1:0] ctrl_r_bits_resp;
    wire [511:0] ctrl_r_bits_data;
    wire         ctrl_r_bits_last;
    wire [ 31:0] ctrl_r_bits_id;
//  wire         ctrl_r_bits_user;
    wire         mem_0_aw_ready;
    wire         mem_0_aw_valid;
    wire [ 31:0] mem_0_aw_bits_id;
    wire [ 63:0] mem_0_aw_bits_addr;
    wire [  7:0] mem_0_aw_bits_len;
    wire [  7:0] mem_0_aw_bits_size;
//  wire [  1:0] mem_0_aw_bits_burst;
//  wire         mem_0_aw_bits_lock;
//  wire [  3:0] mem_0_aw_bits_cache;
//  wire [  2:0] mem_0_aw_bits_prot;
//  wire [  3:0] mem_0_aw_bits_qos;
    wire         mem_0_w_ready;
    wire         mem_0_w_valid;
    wire [511:0] mem_0_w_bits_data;
    wire [ 63:0] mem_0_w_bits_strb;
    wire         mem_0_w_bits_last;
    wire         mem_0_b_ready;
    wire         mem_0_b_valid;
    wire [ 31:0] mem_0_b_bits_id;
//  wire [  1:0] mem_0_b_bits_resp;
    wire         mem_0_ar_ready;
    wire         mem_0_ar_valid;
    wire [ 31:0] mem_0_ar_bits_id;
    wire [ 63:0] mem_0_ar_bits_addr;
    wire [  7:0] mem_0_ar_bits_len;
    wire [  7:0] mem_0_ar_bits_size;
//  wire [  1:0] mem_0_ar_bits_burst;
//  wire         mem_0_ar_bits_lock;
//  wire [  3:0] mem_0_ar_bits_cache;
//  wire [  2:0] mem_0_ar_bits_prot;
//  wire [  3:0] mem_0_ar_bits_qos;
    wire         mem_0_r_ready;
    wire         mem_0_r_valid;
    wire [ 31:0] mem_0_r_bits_id;
    wire [511:0] mem_0_r_bits_data;
//  wire [  1:0] mem_0_r_bits_resp;
    wire         mem_0_r_bits_last;
    wire         mem_1_aw_ready;
    wire         mem_1_aw_valid;
    wire [ 31:0] mem_1_aw_bits_id;
    wire [ 63:0] mem_1_aw_bits_addr;
    wire [  7:0] mem_1_aw_bits_len;
    wire [  7:0] mem_1_aw_bits_size;
//  wire [  1:0] mem_1_aw_bits_burst;
//  wire         mem_1_aw_bits_lock;
//  wire [  3:0] mem_1_aw_bits_cache;
//  wire [  2:0] mem_1_aw_bits_prot;
//  wire [  3:0] mem_1_aw_bits_qos;
    wire         mem_1_w_ready;
    wire         mem_1_w_valid;
    wire [511:0] mem_1_w_bits_data;
    wire [ 63:0] mem_1_w_bits_strb;
    wire         mem_1_w_bits_last;
    wire         mem_1_b_ready;
    wire         mem_1_b_valid;
    wire [ 31:0] mem_1_b_bits_id;
//  wire [  1:0] mem_1_b_bits_resp;
    wire         mem_1_ar_ready;
    wire         mem_1_ar_valid;
    wire [ 31:0] mem_1_ar_bits_id;
    wire [ 63:0] mem_1_ar_bits_addr;
    wire [  7:0] mem_1_ar_bits_len;
    wire [  7:0] mem_1_ar_bits_size;
//  wire [  1:0] mem_1_ar_bits_burst;
//  wire         mem_1_ar_bits_lock;
//  wire [  3:0] mem_1_ar_bits_cache;
//  wire [  2:0] mem_1_ar_bits_prot;
//  wire [  3:0] mem_1_ar_bits_qos;
    wire         mem_1_r_ready;
    wire         mem_1_r_valid;
    wire [ 31:0] mem_1_r_bits_id;
    wire [511:0] mem_1_r_bits_data;
//  wire [  1:0] mem_1_r_bits_resp;
    wire         mem_1_r_bits_last;
    wire         mem_2_aw_ready;
    wire         mem_2_aw_valid;
    wire [ 31:0] mem_2_aw_bits_id;
    wire [ 63:0] mem_2_aw_bits_addr;
    wire [  7:0] mem_2_aw_bits_len;
    wire [  7:0] mem_2_aw_bits_size;
//  wire [  1:0] mem_2_aw_bits_burst;
//  wire         mem_2_aw_bits_lock;
//  wire [  3:0] mem_2_aw_bits_cache;
//  wire [  2:0] mem_2_aw_bits_prot;
//  wire [  3:0] mem_2_aw_bits_qos;
    wire         mem_2_w_ready;
    wire         mem_2_w_valid;
    wire [511:0] mem_2_w_bits_data;
    wire [ 63:0] mem_2_w_bits_strb;
    wire         mem_2_w_bits_last;
    wire         mem_2_b_ready;
    wire         mem_2_b_valid;
    wire [ 31:0] mem_2_b_bits_id;
//  wire [  1:0] mem_2_b_bits_resp;
    wire         mem_2_ar_ready;
    wire         mem_2_ar_valid;
    wire [ 31:0] mem_2_ar_bits_id;
    wire [ 63:0] mem_2_ar_bits_addr;
    wire [  7:0] mem_2_ar_bits_len;
    wire [  7:0] mem_2_ar_bits_size;
//  wire [  1:0] mem_2_ar_bits_burst;
//  wire         mem_2_ar_bits_lock;
//  wire [  3:0] mem_2_ar_bits_cache;
//  wire [  2:0] mem_2_ar_bits_prot;
//  wire [  3:0] mem_2_ar_bits_qos;
    wire         mem_2_r_ready;
    wire         mem_2_r_valid;
    wire [ 31:0] mem_2_r_bits_id;
    wire [511:0] mem_2_r_bits_data;
//  wire [  1:0] mem_2_r_bits_resp;
    wire         mem_2_r_bits_last;
    wire         mem_3_aw_ready;
    wire         mem_3_aw_valid;
    wire [ 31:0] mem_3_aw_bits_id;
    wire [ 63:0] mem_3_aw_bits_addr;
    wire [  7:0] mem_3_aw_bits_len;
    wire [  7:0] mem_3_aw_bits_size;
//  wire [  1:0] mem_3_aw_bits_burst;
//  wire         mem_3_aw_bits_lock;
//  wire [  3:0] mem_3_aw_bits_cache;
//  wire [  2:0] mem_3_aw_bits_prot;
//  wire [  3:0] mem_3_aw_bits_qos;
    wire         mem_3_w_ready;
    wire         mem_3_w_valid;
    wire [511:0] mem_3_w_bits_data;
    wire [ 63:0] mem_3_w_bits_strb;
    wire         mem_3_w_bits_last;
    wire         mem_3_b_ready;
    wire         mem_3_b_valid;
    wire [ 31:0] mem_3_b_bits_id;
//  wire [  1:0] mem_3_b_bits_resp;
    wire         mem_3_ar_ready;
    wire         mem_3_ar_valid;
    wire [ 31:0] mem_3_ar_bits_id;
    wire [ 63:0] mem_3_ar_bits_addr;
    wire [  7:0] mem_3_ar_bits_len;
    wire [  7:0] mem_3_ar_bits_size;
//  wire [  1:0] mem_3_ar_bits_burst;
//  wire         mem_3_ar_bits_lock;
//  wire [  3:0] mem_3_ar_bits_cache;
//  wire [  2:0] mem_3_ar_bits_prot;
//  wire [  3:0] mem_3_ar_bits_qos;
    wire         mem_3_r_ready;
    wire         mem_3_r_valid;
    wire [ 31:0] mem_3_r_bits_id;
    wire [511:0] mem_3_r_bits_data;
//  wire [  1:0] mem_3_r_bits_resp;
    wire         mem_3_r_bits_last;
    wire         dma_aw_ready;
    wire         dma_aw_valid;
    wire [ 31:0] dma_aw_bits_id;
    wire [ 63:0] dma_aw_bits_addr;
    wire [  7:0] dma_aw_bits_len;
    wire [  7:0] dma_aw_bits_size;
//  wire [  1:0] dma_aw_bits_burst;
//  wire         dma_aw_bits_lock;
//  wire [  3:0] dma_aw_bits_cache;
//  wire [  2:0] dma_aw_bits_prot;
//  wire [  3:0] dma_aw_bits_qos;
    wire         dma_w_ready;
    wire         dma_w_valid;
    wire [511:0] dma_w_bits_data;
    wire [ 63:0] dma_w_bits_strb;
    wire         dma_w_bits_last;
    wire         dma_b_ready;
    wire         dma_b_valid;
    wire [ 31:0] dma_b_bits_id;
//  wire [  1:0] dma_b_bits_resp;
    wire         dma_ar_ready;
    wire         dma_ar_valid;
    wire [ 31:0] dma_ar_bits_id;
    wire [ 63:0] dma_ar_bits_addr;
    wire [  7:0] dma_ar_bits_len;
    wire [  7:0] dma_ar_bits_size;
//  wire [  1:0] dma_ar_bits_burst;
//  wire         dma_ar_bits_lock;
//  wire [  3:0] dma_ar_bits_cache;
//  wire [  2:0] dma_ar_bits_prot;
//  wire [  3:0] dma_ar_bits_qos;
    wire         dma_r_ready;
    wire         dma_r_valid;
    wire [ 31:0] dma_r_bits_id;
    wire [511:0] dma_r_bits_data;
//  wire [  1:0] dma_r_bits_resp;
    wire         dma_r_bits_last;

    FPGATop
    u_dut (.clock               (clock                   ),
           .reset               (reset                   ),
           .ctrl_aw_ready       (ctrl_aw_ready           ),
           .ctrl_aw_valid       (ctrl_aw_valid           ),
           .ctrl_aw_bits_addr   (ctrl_aw_bits_addr [31:0]),
           .ctrl_aw_bits_len    (ctrl_aw_bits_len  [ 7:0]),
           .ctrl_aw_bits_size   (ctrl_aw_bits_size [ 2:0]),
           .ctrl_aw_bits_burst  (2'b0                    ),
           .ctrl_aw_bits_lock   (1'b0                    ),
           .ctrl_aw_bits_cache  (4'b0                    ),
           .ctrl_aw_bits_prot   (3'b0                    ),
           .ctrl_aw_bits_qos    (4'b0                    ),
           .ctrl_aw_bits_region (4'b0                    ),
           .ctrl_aw_bits_user   (1'b0                    ),
           .ctrl_w_ready        (ctrl_w_ready            ),
           .ctrl_w_valid        (ctrl_w_valid            ),
           .ctrl_w_bits_data    (ctrl_w_bits_data  [31:0]),
           .ctrl_w_bits_last    (ctrl_w_bits_last        ),
           .ctrl_w_bits_strb    (ctrl_w_bits_strb  [ 3:0]),
           .ctrl_w_bits_user    (1'b0                    ),
           .ctrl_b_ready        (ctrl_b_ready            ),
           .ctrl_b_valid        (ctrl_b_valid            ),
           .ctrl_b_bits_resp    (                        ),
           .ctrl_b_bits_user    (                        ),
           .ctrl_ar_ready       (ctrl_ar_ready           ),
           .ctrl_ar_valid       (ctrl_ar_valid           ),
           .ctrl_ar_bits_addr   (ctrl_ar_bits_addr [31:0]),
           .ctrl_ar_bits_len    (ctrl_ar_bits_len  [ 7:0]),
           .ctrl_ar_bits_size   (ctrl_ar_bits_size [ 2:0]),
           .ctrl_ar_bits_burst  (2'b0                    ),
           .ctrl_ar_bits_lock   (1'b0                    ),
           .ctrl_ar_bits_cache  (4'b0                    ),
           .ctrl_ar_bits_prot   (3'b0                    ),
           .ctrl_ar_bits_qos    (4'b0                    ),
           .ctrl_ar_bits_region (4'b0                    ),
           .ctrl_ar_bits_user   (1'b0                    ),
           .ctrl_r_ready        (ctrl_r_ready            ),
           .ctrl_r_valid        (ctrl_r_valid            ),
           .ctrl_r_bits_resp    (                        ),
           .ctrl_r_bits_data    (ctrl_r_bits_data  [31:0]),
           .ctrl_r_bits_last    (ctrl_r_bits_last        ),
           .ctrl_r_bits_user    (                        ),
           .mem_0_aw_ready      (mem_0_aw_ready          ),
           .mem_0_aw_valid      (mem_0_aw_valid          ),
           .mem_0_aw_bits_id    (mem_0_aw_bits_id  [15:0]),
           .mem_0_aw_bits_addr  (mem_0_aw_bits_addr[33:0]),
           .mem_0_aw_bits_len   (mem_0_aw_bits_len [ 7:0]),
           .mem_0_aw_bits_size  (mem_0_aw_bits_size[ 2:0]),
           .mem_0_aw_bits_burst (                        ),
           .mem_0_aw_bits_lock  (                        ),
           .mem_0_aw_bits_cache (                        ),
           .mem_0_aw_bits_prot  (                        ),
           .mem_0_aw_bits_qos   (                        ),
           .mem_0_w_ready       (mem_0_w_ready           ),
           .mem_0_w_valid       (mem_0_w_valid           ),
           .mem_0_w_bits_data   (mem_0_w_bits_data       ),
           .mem_0_w_bits_strb   (mem_0_w_bits_strb       ),
           .mem_0_w_bits_last   (mem_0_w_bits_last       ),
           .mem_0_b_ready       (mem_0_b_ready           ),
           .mem_0_b_valid       (mem_0_b_valid           ),
           .mem_0_b_bits_id     (mem_0_b_bits_id   [15:0]),
           .mem_0_b_bits_resp   (2'b0                    ),
           .mem_0_ar_ready      (mem_0_ar_ready          ),
           .mem_0_ar_valid      (mem_0_ar_valid          ),
           .mem_0_ar_bits_id    (mem_0_ar_bits_id  [15:0]),
           .mem_0_ar_bits_addr  (mem_0_ar_bits_addr[33:0]),
           .mem_0_ar_bits_len   (mem_0_ar_bits_len [ 7:0]),
           .mem_0_ar_bits_size  (mem_0_ar_bits_size[ 2:0]),
           .mem_0_ar_bits_burst (                        ),
           .mem_0_ar_bits_lock  (                        ),
           .mem_0_ar_bits_cache (                        ),
           .mem_0_ar_bits_prot  (                        ),
           .mem_0_ar_bits_qos   (                        ),
           .mem_0_r_ready       (mem_0_r_ready           ),
           .mem_0_r_valid       (mem_0_r_valid           ),
           .mem_0_r_bits_id     (mem_0_r_bits_id   [15:0]),
           .mem_0_r_bits_data   (mem_0_r_bits_data       ),
           .mem_0_r_bits_resp   (2'b0                    ),
           .mem_0_r_bits_last   (mem_0_r_bits_last       ),
           .mem_1_aw_ready      (mem_1_aw_ready          ),
           .mem_1_aw_valid      (mem_1_aw_valid          ),
           .mem_1_aw_bits_id    (mem_1_aw_bits_id  [ 3:0]),
           .mem_1_aw_bits_addr  (mem_1_aw_bits_addr[33:0]),
           .mem_1_aw_bits_len   (mem_1_aw_bits_len [ 7:0]),
           .mem_1_aw_bits_size  (mem_1_aw_bits_size[ 2:0]),
           .mem_1_aw_bits_burst (                        ),
           .mem_1_aw_bits_lock  (                        ),
           .mem_1_aw_bits_cache (                        ),
           .mem_1_aw_bits_prot  (                        ),
           .mem_1_aw_bits_qos   (                        ),
           .mem_1_w_ready       (mem_1_w_ready           ),
           .mem_1_w_valid       (mem_1_w_valid           ),
           .mem_1_w_bits_data   (mem_1_w_bits_data       ),
           .mem_1_w_bits_strb   (mem_1_w_bits_strb       ),
           .mem_1_w_bits_last   (mem_1_w_bits_last       ),
           .mem_1_b_ready       (mem_1_b_ready           ),
           .mem_1_b_valid       (mem_1_b_valid           ),
           .mem_1_b_bits_id     (mem_1_b_bits_id   [ 3:0]),
           .mem_1_b_bits_resp   (2'b0                    ),
           .mem_1_ar_ready      (mem_1_ar_ready          ),
           .mem_1_ar_valid      (mem_1_ar_valid          ),
           .mem_1_ar_bits_id    (mem_1_ar_bits_id  [ 3:0]),
           .mem_1_ar_bits_addr  (mem_1_ar_bits_addr[33:0]),
           .mem_1_ar_bits_len   (mem_1_ar_bits_len [ 7:0]),
           .mem_1_ar_bits_size  (mem_1_ar_bits_size[ 2:0]),
           .mem_1_ar_bits_burst (                        ),
           .mem_1_ar_bits_lock  (                        ),
           .mem_1_ar_bits_cache (                        ),
           .mem_1_ar_bits_prot  (                        ),
           .mem_1_ar_bits_qos   (                        ),
           .mem_1_r_ready       (mem_1_r_ready           ),
           .mem_1_r_valid       (mem_1_r_valid           ),
           .mem_1_r_bits_id     (mem_1_r_bits_id   [ 3:0]),
           .mem_1_r_bits_data   (mem_1_r_bits_data       ),
           .mem_1_r_bits_resp   (2'b0                    ),
           .mem_1_r_bits_last   (mem_1_r_bits_last       ),
           .mem_2_aw_ready      (mem_2_aw_ready          ),
           .mem_2_aw_valid      (mem_2_aw_valid          ),
           .mem_2_aw_bits_id    (mem_2_aw_bits_id  [ 3:0]),
           .mem_2_aw_bits_addr  (mem_2_aw_bits_addr[33:0]),
           .mem_2_aw_bits_len   (mem_2_aw_bits_len [ 7:0]),
           .mem_2_aw_bits_size  (mem_2_aw_bits_size[ 2:0]),
           .mem_2_aw_bits_burst (                        ),
           .mem_2_aw_bits_lock  (                        ),
           .mem_2_aw_bits_cache (                        ),
           .mem_2_aw_bits_prot  (                        ),
           .mem_2_aw_bits_qos   (                        ),
           .mem_2_w_ready       (mem_2_w_ready           ),
           .mem_2_w_valid       (mem_2_w_valid           ),
           .mem_2_w_bits_data   (mem_2_w_bits_data       ),
           .mem_2_w_bits_strb   (mem_2_w_bits_strb       ),
           .mem_2_w_bits_last   (mem_2_w_bits_last       ),
           .mem_2_b_ready       (mem_2_b_ready           ),
           .mem_2_b_valid       (mem_2_b_valid           ),
           .mem_2_b_bits_id     (mem_2_b_bits_id   [ 3:0]),
           .mem_2_b_bits_resp   (2'b0                    ),
           .mem_2_ar_ready      (mem_2_ar_ready          ),
           .mem_2_ar_valid      (mem_2_ar_valid          ),
           .mem_2_ar_bits_id    (mem_2_ar_bits_id  [ 3:0]),
           .mem_2_ar_bits_addr  (mem_2_ar_bits_addr[33:0]),
           .mem_2_ar_bits_len   (mem_2_ar_bits_len [ 7:0]),
           .mem_2_ar_bits_size  (mem_2_ar_bits_size[ 2:0]),
           .mem_2_ar_bits_burst (                        ),
           .mem_2_ar_bits_lock  (                        ),
           .mem_2_ar_bits_cache (                        ),
           .mem_2_ar_bits_prot  (                        ),
           .mem_2_ar_bits_qos   (                        ),
           .mem_2_r_ready       (mem_2_r_ready           ),
           .mem_2_r_valid       (mem_2_r_valid           ),
           .mem_2_r_bits_id     (mem_2_r_bits_id   [ 3:0]),
           .mem_2_r_bits_data   (mem_2_r_bits_data       ),
           .mem_2_r_bits_resp   (2'b0                    ),
           .mem_2_r_bits_last   (mem_2_r_bits_last       ),
           .mem_3_aw_ready      (mem_3_aw_ready          ),
           .mem_3_aw_valid      (mem_3_aw_valid          ),
           .mem_3_aw_bits_id    (mem_3_aw_bits_id  [ 3:0]),
           .mem_3_aw_bits_addr  (mem_3_aw_bits_addr[33:0]),
           .mem_3_aw_bits_len   (mem_3_aw_bits_len [ 7:0]),
           .mem_3_aw_bits_size  (mem_3_aw_bits_size[ 2:0]),
           .mem_3_aw_bits_burst (                        ),
           .mem_3_aw_bits_lock  (                        ),
           .mem_3_aw_bits_cache (                        ),
           .mem_3_aw_bits_prot  (                        ),
           .mem_3_aw_bits_qos   (                        ),
           .mem_3_w_ready       (mem_3_w_ready           ),
           .mem_3_w_valid       (mem_3_w_valid           ),
           .mem_3_w_bits_data   (mem_3_w_bits_data       ),
           .mem_3_w_bits_strb   (mem_3_w_bits_strb       ),
           .mem_3_w_bits_last   (mem_3_w_bits_last       ),
           .mem_3_b_ready       (mem_3_b_ready           ),
           .mem_3_b_valid       (mem_3_b_valid           ),
           .mem_3_b_bits_id     (mem_3_b_bits_id   [ 3:0]),
           .mem_3_b_bits_resp   (2'b0                    ),
           .mem_3_ar_ready      (mem_3_ar_ready          ),
           .mem_3_ar_valid      (mem_3_ar_valid          ),
           .mem_3_ar_bits_id    (mem_3_ar_bits_id  [ 3:0]),
           .mem_3_ar_bits_addr  (mem_3_ar_bits_addr[33:0]),
           .mem_3_ar_bits_len   (mem_3_ar_bits_len [ 7:0]),
           .mem_3_ar_bits_size  (mem_3_ar_bits_size[ 2:0]),
           .mem_3_ar_bits_burst (                        ),
           .mem_3_ar_bits_lock  (                        ),
           .mem_3_ar_bits_cache (                        ),
           .mem_3_ar_bits_prot  (                        ),
           .mem_3_ar_bits_qos   (                        ),
           .mem_3_r_ready       (mem_3_r_ready           ),
           .mem_3_r_valid       (mem_3_r_valid           ),
           .mem_3_r_bits_id     (mem_3_r_bits_id   [ 3:0]),
           .mem_3_r_bits_data   (mem_3_r_bits_data       ),
           .mem_3_r_bits_resp   (2'b0                    ),
           .mem_3_r_bits_last   (mem_3_r_bits_last       ),
           .dma_aw_ready        (dma_aw_ready            ),
           .dma_aw_valid        (dma_aw_valid            ),
           .dma_aw_bits_id      (dma_aw_bits_id    [ 3:0]),
           .dma_aw_bits_addr    (dma_aw_bits_addr        ),
           .dma_aw_bits_len     (dma_aw_bits_len   [ 7:0]),
           .dma_aw_bits_size    (dma_aw_bits_size  [ 2:0]),
           .dma_aw_bits_burst   (2'b0                    ),
           .dma_aw_bits_lock    (1'b0                    ),
           .dma_aw_bits_cache   (4'b0                    ),
           .dma_aw_bits_prot    (3'b0                    ),
           .dma_aw_bits_qos     (4'b0                    ),
           .dma_w_ready         (dma_w_ready             ),
           .dma_w_valid         (dma_w_valid             ),
           .dma_w_bits_data     (dma_w_bits_data         ),
           .dma_w_bits_strb     (dma_w_bits_strb         ),
           .dma_w_bits_last     (dma_w_bits_last         ),
           .dma_b_ready         (dma_b_ready             ),
           .dma_b_valid         (dma_b_valid             ),
           .dma_b_bits_id       (dma_b_bits_id     [ 3:0]),
           .dma_b_bits_resp     (                        ),
           .dma_ar_ready        (dma_ar_ready            ),
           .dma_ar_valid        (dma_ar_valid            ),
           .dma_ar_bits_id      (dma_ar_bits_id    [ 3:0]),
           .dma_ar_bits_addr    (dma_ar_bits_addr        ),
           .dma_ar_bits_len     (dma_ar_bits_len   [ 7:0]),
           .dma_ar_bits_size    (dma_ar_bits_size  [ 2:0]),
           .dma_ar_bits_burst   (2'b0                    ),
           .dma_ar_bits_lock    (1'b0                    ),
           .dma_ar_bits_cache   (4'b0                    ),
           .dma_ar_bits_prot    (3'b0                    ),
           .dma_ar_bits_qos     (4'b0                    ),
           .dma_r_ready         (dma_r_ready             ),
           .dma_r_valid         (dma_r_valid             ),
           .dma_r_bits_id       (dma_r_bits_id     [ 3:0]),
           .dma_r_bits_data     (dma_r_bits_data         ),
           .dma_r_bits_resp     (                        ),
           .dma_r_bits_last     (dma_r_bits_last         ));


    //
    // firesim

    // implicit type conversion is unfortunately unavoidable

`define LIST(mst, slv)               \
    input int     unsigned  idx,     \
    input bit               reset,   \
    mst   bit              ar_valid, \
    slv   bit              ar_ready, \
    mst   longint unsigned ar_addr,  \
    mst   int     unsigned ar_id,    \
    mst   byte    unsigned ar_size,  \
    mst   byte    unsigned ar_len,   \
    slv   bit               r_valid, \
    mst   bit               r_ready, \
    slv   bit     [511:0]   r_data,  \
    slv   int     unsigned  r_id,    \
    slv   bit               r_last,  \
    mst   bit              aw_valid, \
    slv   bit              aw_ready, \
    mst   longint unsigned aw_addr,  \
    mst   int     unsigned aw_id,    \
    mst   byte    unsigned aw_size,  \
    mst   byte    unsigned aw_len,   \
    mst   bit               w_valid, \
    slv   bit               w_ready, \
    mst   bit     [511:0]   w_data,  \
    mst   longint unsigned  w_strb,  \
    mst   bit               w_last,  \
    slv   bit               b_valid, \
    mst   bit               b_ready, \
    slv   int     unsigned  b_id

    import "DPI-C" function void firesim_init(input string rom,
                                              input string bin,
                                              input string img,
                                              input int    port);
    import "DPI-C" function void firesim_tick();
    import "DPI-C" function void firesim_axi_mst_drv_tick(`LIST(inout, input));
    import "DPI-C" function void firesim_axi_mst_mon_tick(`LIST(inout, input));
    import "DPI-C" function void firesim_axi_slv_drv_tick(`LIST(input, inout));
    import "DPI-C" function void firesim_axi_slv_mon_tick(`LIST(input, inout));

`undef LIST

    initial begin
        string rom;
        string bin;
        string img;
        int    port;

        if (!$value$plusargs("rom=%s",  rom))
            rom  = "rom";
        if (!$value$plusargs("bin=%s",  bin))
            bin  = "bin";
        if (!$value$plusargs("img=%s",  img))
            img  = "img";
        if (!$value$plusargs("port=%d", port))
            port = 22090;

        firesim_init(rom, bin, img, port);
    end

`define TICK(func, idx, pre)     \
    do begin                     \
        func(idx,                \
             reset,              \
             pre``_ar_valid,     \
             pre``_ar_ready,     \
             pre``_ar_bits_addr, \
             pre``_ar_bits_id,   \
             pre``_ar_bits_size, \
             pre``_ar_bits_len,  \
             pre``_r_valid,      \
             pre``_r_ready,      \
             pre``_r_bits_data,  \
             pre``_r_bits_id,    \
             pre``_r_bits_last,  \
             pre``_aw_valid,     \
             pre``_aw_ready,     \
             pre``_aw_bits_addr, \
             pre``_aw_bits_id,   \
             pre``_aw_bits_size, \
             pre``_aw_bits_len,  \
             pre``_w_valid,      \
             pre``_w_ready,      \
             pre``_w_bits_data,  \
             pre``_w_bits_strb,  \
             pre``_w_bits_last,  \
             pre``_b_valid,      \
             pre``_b_ready,      \
             pre``_b_bits_id);   \
    end while (0)

    always_ff @(posedge clock) begin
       `TICK(firesim_axi_mst_mon_tick, 0, ctrl);
       `TICK(firesim_axi_mst_mon_tick, 1, dma);

       `TICK(firesim_axi_slv_mon_tick, 0, mem_0);
       `TICK(firesim_axi_slv_mon_tick, 1, mem_1);
       `TICK(firesim_axi_slv_mon_tick, 2, mem_2);
       `TICK(firesim_axi_slv_mon_tick, 3, mem_3);

        firesim_tick();
    end

    always_ff @(negedge clock) begin
       `TICK(firesim_axi_mst_drv_tick, 0, ctrl);
       `TICK(firesim_axi_mst_drv_tick, 1, dma);

       `TICK(firesim_axi_slv_drv_tick, 0, mem_0);
       `TICK(firesim_axi_slv_drv_tick, 1, mem_1);
       `TICK(firesim_axi_slv_drv_tick, 2, mem_2);
       `TICK(firesim_axi_slv_drv_tick, 3, mem_3);
    end

`undef TICK

endmodule
