#include <stdio.h>
#include <sys/stat.h>

#include "Dut.fs.const.h"
#include "new_load.h"


new_load_t::new_load_t(sim_t *sim, type_t *mmio): bridge_driver_t(sim),
    m_sim (sim ),
    m_mmio(mmio) { }


void new_load_t::mem_init(const char *fn, uint64_t offs) {
    FILE *fp;
    char *buf;

    if ((fn == NULL) || !strlen(fn))
        return;

    if ((fp = fopen(fn, "rb")) == NULL)
        die("fopen(%s) failed", fn);

    struct stat st;
    stat(fn, &st);

    auto sz = st.st_size;

    if ((buf = (char *)(malloc(sz + 8))) == NULL)
        die("malloc(%ld) failed\n", sz + 8);

    if (fread(buf, sz, 1, fp) != 1)
        die("fread(%lx) failed", sz);

    fclose(fp);

    for (auto i = 0l; i < sz; i += MEM_BEAT_BYTES)
        mem_wr(offs + i, buf + i);

    free(buf);
}


void new_load_t::mem_zero(void) {
    wr(m_mmio->ZERO_OUT_DRAM, 1);

    while(!rd(m_mmio->ZERO_FINISHED));
}


void new_load_t::mem_rd(uint64_t addr, void *data) {
    wr(m_mmio->R_ADDRESS_H, (addr >> 32) & 0xfffffffflu);
    wr(m_mmio->R_ADDRESS_L,  addr        & 0xfffffffflu);

    auto buf = (uint32_t *)(data);

    for (auto i = 0lu; i < MEM_DATA_CHUNK; i++)
        buf[i] = rd(m_mmio->R_DATA);
}


void new_load_t::mem_wr(uint64_t addr, void *data) {
    wr(m_mmio->W_ADDRESS_H, (addr >> 32) & 0xfffffffflu);
    wr(m_mmio->W_ADDRESS_L,  addr        & 0xfffffffflu);
    wr(m_mmio->W_LENGTH,     1);

    auto buf = (uint32_t *)(data);

    for (auto i = 0lu; i < MEM_DATA_CHUNK; i++)
        wr(m_mmio->W_DATA, buf[i]);
}