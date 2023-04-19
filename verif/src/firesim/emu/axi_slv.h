// See LICENSE.md for license details

#ifndef __AXI_SLV_H__
#define __AXI_SLV_H__

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <queue>
#include <list>
#include <pthread.h>

#include "mem.h"


class axi_slv_t {
public:
    axi_slv_t(uint64_t base, uint64_t wid, uint64_t cap):
        m_base(base),
        m_mem (wid, cap) { }

    struct addr_t {
        uint64_t m_addr;
        uint32_t m_id;
        uint8_t  m_size;
        uint8_t  m_len;
    };

    struct data_t {
        void    *m_data;
        uint32_t m_cnt;
        uint32_t m_id;
        uint8_t  m_last;
    };

    struct resp_t {
        uint32_t m_cnt;
        uint32_t m_id;
    };

    inline uint64_t get_wid(void) { return  m_mem.get_wid();          }

    inline uint8_t ar_ready(void) { return  true;                     }
           uint8_t  r_valid(void);
    inline data_t  *r_payld(void) { return &m_r .front();             }
    inline uint8_t aw_ready(void) { return  true;                     }
    inline uint8_t  w_ready(void) { return !m_aw.empty();             }
           uint8_t  b_valid(void);
    inline resp_t  *b_payld(void) { return &m_b .front();             }

    inline void     acquire(void) { pthread_mutex_lock  (&m_lock);    }
    inline void     release(void) { pthread_mutex_unlock(&m_lock);    }

    void init(const char *fn, uint64_t offs = 0);
    void rd  (uint64_t addr, void *data);
    void wr  (uint64_t addr, void *data, uint64_t strb);

    void tick(uint8_t  ar_valid,
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
              uint8_t   b_ready);

protected:
    std::queue<addr_t> m_aw;
    std::list <data_t> m_r;
    std::list <resp_t> m_b;

    uint64_t m_base;
    mem_t    m_mem;

    pthread_mutex_t m_lock = PTHREAD_MUTEX_INITIALIZER;
};

#endif
