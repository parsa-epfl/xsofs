module aws(
    input wire clock,
    input wire reset
);

    import "DPI-C" context task firesim_main(input string rom,
                                             input string bin,
                                             input string img,
                                             input int    port);

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

        // wait for memories
        tb.card.fpga.sh.nsec_delay(27000);

        firesim_main(rom, bin, img, port);
    end

    import tb_type_defines_pkg::*;

    initial begin
        tb.card.fpga.sh.power_up(.clk_recipe_a (ClockRecipe::A1),
                                 .clk_recipe_b (ClockRecipe::B0),
                                 .clk_recipe_c (ClockRecipe::C0));
    end

    task tb_peek_pcis(input longint unsigned addr, output int unsigned data);
        tb.card.fpga.sh.peek(.addr (addr),
                             .data (data),
                             .intf (AxiPort::PORT_DMA_PCIS));
    endtask

    task tb_poke_pcis(input longint unsigned addr, int unsigned data);
        tb.card.fpga.sh.poke(.addr (addr),
                             .data (data),
                             .intf (AxiPort::PORT_DMA_PCIS));
    endtask

    task tb_peek_ocl (input longint unsigned addr, output int unsigned data);
        tb.card.fpga.sh.peek(.addr (addr),
                             .data (data),
                             .intf (AxiPort::PORT_OCL));
    endtask

    task tb_poke_ocl (input longint unsigned addr, int unsigned data);
        tb.card.fpga.sh.poke(.addr (addr),
                             .data (data),
                             .intf (AxiPort::PORT_OCL));
    endtask

    export "DPI-C" task tb_peek_ocl;
    export "DPI-C" task tb_poke_ocl;
    export "DPI-C" task tb_peek_pcis;
    export "DPI-C" task tb_poke_pcis;

endmodule