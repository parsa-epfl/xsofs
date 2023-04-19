// See LICENSE.md for license details

#include "Dut.fs.const.h"
#include "emu.h"


void emu_t::host_init(int argc, char **argv) {
    sim_t::host_init(argc, argv);

    // parse
    std::vector<std::string> args(argv + 1, argv + argc);

    auto bin = "bin";
    auto img = "";

    for (auto &a: args) {
        if (a.rfind("+bin=") == 0)
            bin = a.c_str() + 5;
        if (a.rfind("+img=") == 0)
            img = a.c_str() + 5;
    }

    m_mst.emplace_back(new axi_mst_t(CTRL_BEAT_BYTES));
    m_mst.emplace_back(new axi_mst_t( DMA_BEAT_BYTES));

    for (int i = 0; i < MEM_NUM_CHANNELS; i++)
        m_slv.emplace_back(new axi_slv_t(0x0lu, MEM_BEAT_BYTES, 1lu << MEM_ADDR_BITS));

    m_slv[0]->init(bin);
    m_slv[0]->init(img, 0x2000000);
}


void emu_t::wait_rd(std::unique_ptr<axi_mst_t> &axi, void *data) {
    while (!axi->rd_resp(data))
        wait();
}

void emu_t::wait_wr(std::unique_ptr<axi_mst_t> &axi) {
    while (!axi->wr_resp())
        wait();
}


uint32_t emu_t::read(size_t addr) {
    uint32_t data;

    m_mst[0]->rd_req(addr & ~0x3lu, CTRL_AXI4_SIZE, 0);
    wait_rd(m_mst[0], &data);

    return data;
}

void emu_t::write(size_t addr, uint32_t data) {
    auto strb = (1lu << CTRL_STRB_BITS) - 1lu;

    m_mst[0]->wr_req(addr & ~0x3lu, CTRL_AXI4_SIZE, 0, &data, &strb);
    wait_wr(m_mst[0]);
}


size_t emu_t::pcis_rd(size_t addr, void *data, size_t size) {
    auto len = (uint8_t)(((ssize_t)(size) - 1) / DMA_BEAT_BYTES);

    m_mst[1]->rd_req(addr, DMA_SIZE, len);
    wait_rd(m_mst[1], data);

    return size;
}

size_t emu_t::pcis_wr(size_t addr, void *data, size_t size) {
    auto len = (uint8_t)(((ssize_t)(size) - 1) / DMA_BEAT_BYTES);

    uint64_t strb[len + 1];

    for (int i = 0; i <= len; i++)
        strb[i] = (1lu << (size - i * DMA_BEAT_BYTES)) - 1lu;

    m_mst[1]->wr_req(addr, DMA_SIZE, len, data, strb);
    wait_wr(m_mst[1]);

    return size;
}


static void *emu_main(void *p) {
    auto sim = (sim_t *)(p);

    sim->main();

    return NULL;
}

void emu_t::fork(void) {
    pthread_mutex_lock (&m_lock);
    pthread_create     (&m_thrd, NULL, emu_main, this);
    pthread_detach     ( m_thrd);
}

void emu_t::wait(void) {
    pthread_cond_wait  (&m_cond, &m_lock);
}

void emu_t::tick(void) {
    pthread_cond_signal(&m_cond);
}
