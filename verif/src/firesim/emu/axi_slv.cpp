// See LICENSE.md for license details

#include "axi_slv.h"


void axi_slv_t::init(const char *fn, uint64_t offs) {
    m_mem.init(fn, offs);
}


void axi_slv_t::rd(uint64_t addr, void *data) {
    m_mem.rd(m_mem.get_addr(addr - m_base), data);
}

void axi_slv_t::wr(uint64_t addr, void *data, uint64_t strb) {
    m_mem.wr(m_mem.get_addr(addr - m_base), data, &strb);
}


uint8_t axi_slv_t::r_valid(void) {
    if (m_r.empty())
        return 0;

    auto r = &m_r.front();

    if (r->m_cnt == 0)
        return 1;

    r->m_cnt--;
    return 0;
}

uint8_t axi_slv_t::b_valid(void) {
    if (m_b.empty())
        return 0;

    auto b = &m_b.front();

    if (b->m_cnt == 0)
        return 1;

    b->m_cnt--;
    return 0;
}


void axi_slv_t::tick(uint8_t  ar_valid,
                     uint8_t  ar_ready,
                     uint64_t ar_addr,
                     uint32_t ar_id,
                     uint8_t  ar_size,
                     uint8_t  ar_len,
                     uint8_t   r_valid,
                     uint8_t   r_ready,
                     uint8_t  aw_valid,
                     uint8_t  aw_ready,
                     uint64_t aw_addr,
                     uint32_t aw_id,
                     uint8_t  aw_size,
                     uint8_t  aw_len,
                     uint8_t   w_valid,
                     uint8_t   w_ready,
                     void     *w_data,
                     uint64_t  w_strb,
                     uint8_t   w_last,
                     uint8_t   b_valid,
                     uint8_t   b_ready) {

    if (ar_valid && ar_ready) {
        auto elem = 1lu << ar_size;
        auto iter = m_r.begin();

        for (auto i = 0lu, e = 0lu; i <= ar_len; i++, e += elem) {
            auto p = new char [m_mem.get_wid()];

            rd(ar_addr + e, p);

            if (iter == m_r.begin())
                for (auto j = m_r.begin(); j != m_r.end(); j++)
                    if (j->m_id == ar_id) {
                        iter = j;
                        iter++;
                    }

            if (iter != m_r.end())
                std::advance(iter, rand() % (m_r.size() - std::distance(m_r.begin(), iter)));

            uint32_t dly = (i == 0) ? (rand() % 100 + 50) :
                                      (rand() % 10);

            m_r.insert(iter, {p, dly, ar_id, i == ar_len});

            iter++;
        }
    }

    if ( r_valid &&  r_ready) {
        delete [] (char *)(m_r.front().m_data);

        m_r.pop_front();
    }

    if (aw_valid && aw_ready) {
        m_aw.push({aw_addr, aw_id, aw_size, aw_len});

        auto iter = m_b.begin();

        for (auto j = m_b.begin(); j != m_b.end(); j++)
            if (j->m_id == aw_id) {
                iter = j;
                iter++;
            }

        if (iter != m_b.end())
            std::advance(iter, rand() % (m_b.size() - std::distance(m_b.begin(), iter)));

        uint32_t dly = rand() % 100 + 50;

        m_b.insert(iter, {dly, aw_id});
    }

    if ( w_valid &&  w_ready) {
        auto aw = &m_aw.front();

        wr(aw->m_addr, w_data, w_strb);

        if (w_last)
            m_aw.pop();
        else
            aw->m_addr += 1lu << aw->m_size;
    }

    if ( b_valid &&  b_ready)
        m_b.pop_front();
}
