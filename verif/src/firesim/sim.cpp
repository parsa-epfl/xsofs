// See LICENSE.md for license details

#include <string>

#include "Dut.fs.const.h"

#include "sim.h"
#include "fased_memory_timing_model.h"
#include "reset_pulse.h"
#include "new_rom.h"
#include "new_uart.h"
#include "new_jtag.h"
#include "new_load.h"


void sim_t::host_init(int argc, char **argv) {
    using namespace std::placeholders;

    auto fn_mmio_rd = std::bind(&sim_t::read,    this, _1);
    auto fn_pcis_rd = std::bind(&sim_t::pcis_rd, this, _1, _2, _3);
    auto fn_pcis_wr = std::bind(&sim_t::pcis_wr, this, _1, _2, _3);

    for (auto i = 0u; i < CPUMANAGEDSTREAMENGINE_0_from_cpu_stream_count; i++)
        m_from.emplace_back(
            CPUManagedStreamParameters(
                std::string(CPUMANAGEDSTREAMENGINE_0_from_cpu_names[i]),
                CPUMANAGEDSTREAMENGINE_0_from_cpu_dma_addrs   [i],
                CPUMANAGEDSTREAMENGINE_0_from_cpu_count_addrs [i],
                CPUMANAGEDSTREAMENGINE_0_from_cpu_buffer_sizes[i]),
            fn_mmio_rd,
            fn_pcis_wr);

    for (auto i = 0u; i < CPUMANAGEDSTREAMENGINE_0_to_cpu_stream_count; i++)
        m_to  .emplace_back(
            CPUManagedStreamParameters(
                std::string(CPUMANAGEDSTREAMENGINE_0_to_cpu_names[i]),
                CPUMANAGEDSTREAMENGINE_0_to_cpu_dma_addrs   [i],
                CPUMANAGEDSTREAMENGINE_0_to_cpu_count_addrs [i],
                CPUMANAGEDSTREAMENGINE_0_to_cpu_buffer_sizes[i]),
            fn_mmio_rd,
            fn_pcis_rd);

    RESETPULSEBRIDGEMODULE_0_substruct_create;
    FASEDMEMORYTIMINGMODEL_0_substruct_create;
    LOADMEMWIDGET_0_substruct_create;

    FIRESIMBRIDGEIMP_0_substruct_create;
    FIRESIMBRIDGEIMP_1_substruct_create;
    FIRESIMBRIDGEIMP_2_substruct_create;

    // parse
    std::vector<std::string> args(argv + 1, argv + argc);

    auto rom  = "rom";
    auto inc  =  m_emu ? 10 : 1;
    auto port = -1;

    for (auto &a: args) {
        if (a.rfind("+rom=" ) == 0)
            rom  = a.c_str() + 5;
        if (a.rfind("+inc=" ) == 0)
            inc  = atoi(a.c_str() + 5);
        if (a.rfind("+port=") == 0)
            port = atoi(a.c_str() + 6);
    }

    m_inc = inc;

    m_mod.emplace_back(new FASEDMemoryTimingModel(
        this,
        AddressMap(FASEDMEMORYTIMINGMODEL_0_R_num_registers,
                   FASEDMEMORYTIMINGMODEL_0_R_addrs,
                   FASEDMEMORYTIMINGMODEL_0_R_names,
                   FASEDMEMORYTIMINGMODEL_0_W_num_registers,
                   FASEDMEMORYTIMINGMODEL_0_W_addrs,
                   FASEDMEMORYTIMINGMODEL_0_W_names),
        argc,
        argv,
       "fased_0.csv",
        1lu << FASEDMEMORYTIMINGMODEL_0_target_addr_bits,
       "_0"));

    m_drv.emplace_back(new reset_pulse_t(
        this,
        args,
        RESETPULSEBRIDGEMODULE_0_substruct,
        RESETPULSEBRIDGEMODULE_0_max_pulse_length,
        RESETPULSEBRIDGEMODULE_0_default_pulse_length,
        0));

    m_drv.emplace_back(new new_rom_t (this, FIRESIMBRIDGEIMP_0_substruct, rom, 0x10000000lu, 1lu << 20));
    m_drv.emplace_back(new new_uart_t(this, FIRESIMBRIDGEIMP_1_substruct));
    m_drv.emplace_back(new new_jtag_t(this, FIRESIMBRIDGEIMP_2_substruct, port));
    m_drv.emplace_back(new new_load_t(this, LOADMEMWIDGET_0_substruct));
}


void sim_t::main(void) {
    if (m_emu)
        take_steps(100, false);

    for (auto &m: m_mod)
        m->init();
    for (auto &d: m_drv)
        d->init();

    while (true) {
        take_steps(m_inc, false);

        for (auto &d: m_drv)
            d->tick();
    }
}


size_t sim_t::push(unsigned int sid, void *src, size_t nb, size_t tb) {
    return m_from[sid].push(src, nb, tb);
}

size_t sim_t::pull(unsigned int sid, void *dst, size_t nb, size_t tb) {
    return m_to  [sid].pull(dst, nb, tb);
}
