#include "axi_mst.h"


void axi_mst_t::rd_req(uint64_t addr, uint8_t size, uint8_t len) {
    acquire();
    auto elem = 1lu << size;

    m_ar.push({addr & ~(elem - 1lu), 0, size, len});
    release();
}

void axi_mst_t::wr_req(uint64_t addr, uint8_t size, uint8_t len, void *data, uint64_t *strb) {
    acquire();
    auto elem = 1lu << size;

    for (auto i = 0lu, e = 0lu; i <= len; i++, e += elem) {
        auto p = new char [m_wid];

        memcpy(p + (e & m_msk), (char *)(data) + e, elem);

        m_w.push({p, strb[i], i == len});
    }

    m_aw.push({addr & ~(elem - 1lu), 0, size, len});
    release();
}


bool axi_mst_t::rd_resp(void *data) {
    acquire();
    auto ret  = false;

    auto len  =        m_ar.front().m_len;
    auto elem = 1lu << m_ar.front().m_size;

    if (m_ar.empty() || (m_r.size() <= len))
        goto out;

    for (auto i = 0lu, e = 0lu; i <= len; i++, e += elem) {
        auto r = m_r.front();

        memcpy((char *)(data) + e, (char *)(r.m_data) + (e & m_msk), elem);
        delete [] (char *)(r.m_data);

        m_r.pop();
    }

    m_ar.pop();
    m_rd_busy = false;

    ret = true;

out:
    release();
    return ret;
}

bool axi_mst_t::wr_resp(void) {
    acquire();
    auto ret = false;

    if (m_aw.empty() || m_b.empty())
        goto out;

    m_aw.pop();
    m_b .pop();
    m_wr_busy = false;

    ret = true;

out:
    release();
    return ret;
}


void axi_mst_t::tick(uint8_t ar_valid,
                     uint8_t ar_ready,
                     uint8_t  r_valid,
                     uint8_t  r_ready,
                     void    *r_data,
                     uint32_t r_id,
                     uint8_t  r_last,
                     uint8_t aw_valid,
                     uint8_t aw_ready,
                     uint8_t  w_valid,
                     uint8_t  w_ready,
                     uint8_t  b_valid,
                     uint8_t  b_ready,
                     uint32_t b_id) {

    if (ar_valid && ar_ready)
        m_rd_busy = true;

    if ( r_valid &&  r_ready)
        m_r.push({memcpy(new char [m_wid], r_data, m_wid), r_id, r_last});

    if (aw_valid && aw_ready)
        m_wr_busy = true;

    if ( w_valid &&  w_ready) {
        delete [] (char *)(m_w.front().m_data);
        m_w.pop();
    }

    if ( b_valid &&  b_ready)
        m_b.push({b_id});
}