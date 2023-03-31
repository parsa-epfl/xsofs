#ifndef __AXI_MST_H__
#define __AXI_MST_H__

#include <stdint.h>
#include <string.h>
#include <queue>
#include <pthread.h>


class axi_mst_t {
public:
    axi_mst_t(uint32_t wid):
        m_wid(wid),
        m_msk((1lu << wid) - 1lu) { }

    struct addr_t {
        uint64_t m_addr;
        uint32_t m_id;
        uint8_t  m_size;
        uint8_t  m_len;
    };

    struct data_t {
        void    *m_data;
        uint64_t m_strb;
        uint8_t  m_last;
    };

    struct resp_t {
        void    *m_data;
        uint32_t m_id;
        uint8_t  m_last;
    };

    inline uint64_t get_wid(void) { return  m_wid;                      }

    inline uint8_t ar_valid(void) { return !m_ar.empty() && !m_rd_busy; }
    inline addr_t *ar_payld(void) { return &m_ar.front();               }
    inline uint8_t  r_ready(void) { return  m_rd_busy;                  }
    inline uint8_t aw_valid(void) { return !m_aw.empty() && !m_wr_busy; }
    inline addr_t *aw_payld(void) { return &m_aw.front();               }
    inline uint8_t  w_valid(void) { return !m_w .empty() &&  m_wr_busy; }
    inline data_t * w_payld(void) { return &m_w .front();               }
    inline uint8_t  b_ready(void) { return  m_wr_busy;                  }

    inline void     acquire(void) { pthread_mutex_lock  (&m_lock);      }
    inline void     release(void) { pthread_mutex_unlock(&m_lock);      }

    void rd_req (uint64_t addr, uint8_t size, uint8_t len);
    bool rd_resp(void *data);
    void wr_req (uint64_t addr, uint8_t size, uint8_t len, void *data, uint64_t *strb);
    bool wr_resp(void);

    void tick(uint8_t ar_valid,
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
              uint32_t b_id);

private:
    std::queue<addr_t> m_ar;
    std::queue<resp_t> m_r;
    std::queue<addr_t> m_aw;
    std::queue<data_t> m_w;
    std::queue<size_t> m_b;

    uint64_t m_wid;
    uint64_t m_msk;
    uint8_t  m_rd_busy = false;
    uint8_t  m_wr_busy = false;

    pthread_mutex_t m_lock = PTHREAD_MUTEX_INITIALIZER;
};

#endif