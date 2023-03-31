#include "new_rom.h"


new_rom_t::new_rom_t(sim_t *sim, type_t *mmio, const char *fn, uint64_t base, uint64_t cap): common_t(sim, mmio),
    m_base(base),
    m_mem (8, cap) {
    m_mem.init(fn);
}


void new_rom_t::tick(void) {
    if (m_sim->curr())
        return;

    if (m_fsm) {
        if (rd(m_mmio->tx_ready)) {
            wr(m_mmio->tx_bits, (uint32_t)(m_data));
            wr(m_mmio->tx_valid, true);

            m_fsm  = (m_fsm  == 2) ? 0 : (m_fsm + 1);
            m_data =  m_data >> 32;
        }

    } else if (rd(m_mmio->rx_valid)) {
        m_mem.rd(m_mem.get_addr(rd(m_mmio->rx_bits) - m_base), &m_data);

        wr(m_mmio->rx_ready, true);

        m_fsm = 1;
    }
}