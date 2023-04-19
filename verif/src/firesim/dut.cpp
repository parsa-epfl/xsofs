// See LICENSE.md for license details

#include "emu.h"

#define MASK_ADDR ((1lu << MEM_ADDR_BITS) - 1lu)
#define MASK_ID   ((1lu << MEM_ID_BITS  ) - 1lu)
#define MASK_SIZE ((1lu << 3            ) - 1lu)
#define MASK_LEN  ((1lu << 8            ) - 1lu)

#if MEM_STRB_BITS >= 64
#define MASK_STRB 0xfffffffffffffffflu
#else
#define MASK_STRB ((1lu << MEM_STRB_BITS) - 1lu)
#endif


static emu_t *g_emu = NULL;


extern "C" {

void firesim_init(const char *r, const char *b, const char *i, int p) {
    std::string rom ("+rom=");
    std::string bin ("+bin=");
    std::string img ("+img=");
    std::string port("+port=");

    rom  += r;
    bin  += b;
    img  += i;
    port += p;

    char *args[] = {(char *)("self"),
                    (char *)( rom .c_str()),
                    (char *)( bin .c_str()),
                    (char *)( img .c_str()),
                    (char *)( port.c_str()),
                    (char *)("+mm_readLatency_0=30"),
                    (char *)("+mm_readMaxReqs_0=8"),
                    (char *)("+mm_writeLatency_0=30"),
                    (char *)("+mm_writeMaxReqs_0=8"),
                    (char *)("+mm_relaxFunctionalModel_0=0")};

    g_emu = new emu_t();
    g_emu->host_init(10, args);
    g_emu->fork();
}

void firesim_tick(void) {
    g_emu->tick();
}


#define LIST(mst, slv)     \
    uint32_t      i,       \
    uint8_t       reset,   \
    uint8_t  mst ar_valid, \
    uint8_t  slv ar_ready, \
    uint64_t mst ar_addr,  \
    uint32_t mst ar_id,    \
    uint8_t  mst ar_size,  \
    uint8_t  mst ar_len,   \
    uint8_t  slv  r_valid, \
    uint8_t  mst  r_ready, \
    uint32_t     *r_data,  \
    uint32_t slv  r_id,    \
    uint8_t  slv  r_last,  \
    uint8_t  mst aw_valid, \
    uint8_t  slv aw_ready, \
    uint64_t mst aw_addr,  \
    uint32_t mst aw_id,    \
    uint8_t  mst aw_size,  \
    uint8_t  mst aw_len,   \
    uint8_t  mst  w_valid, \
    uint8_t  slv  w_ready, \
    uint32_t     *w_data,  \
    uint64_t mst  w_strb,  \
    uint8_t  mst  w_last,  \
    uint8_t  slv  b_valid, \
    uint8_t  mst  b_ready, \
    uint32_t slv  b_id

void firesim_axi_mst_drv_tick(LIST(*, )) {
    if (reset) {
        *ar_valid = 0;
        * r_ready = 0;
        *aw_valid = 0;
        * w_valid = 0;
        * b_ready = 0;

        return;
    }

    auto mst = g_emu->mst(i).get();

    mst->acquire();
    *ar_valid = mst->ar_valid();
    * r_ready = mst-> r_ready();
    *aw_valid = mst->aw_valid();
    * w_valid = mst-> w_valid();
    * b_ready = mst-> b_ready();

    auto ar = mst->ar_payld();
    auto aw = mst->aw_payld();
    auto  w = mst-> w_payld();

    if (*ar_valid) {
        *ar_addr = ar->m_addr;
        *ar_id   = ar->m_id;
        *ar_size = ar->m_size;
        *ar_len  = ar->m_len;
    }

    if (*aw_valid) {
        *aw_addr = aw->m_addr;
        *aw_id   = aw->m_id;
        *aw_size = aw->m_size;
        *aw_len  = aw->m_len;
    }

    if (*w_valid) {
        *w_strb  =  w->m_strb;
        *w_last  =  w->m_last;

        memcpy(w_data, w->m_data, mst->get_wid());
    }
    mst->release();
}

void firesim_axi_mst_mon_tick(LIST(*, )) {
    if (reset)
        return;

    auto mst = g_emu->mst(i).get();

    mst->acquire();
    mst->tick(*ar_valid,
               ar_ready,
                r_valid,
              * r_ready,
                r_data,
                r_id,
                r_last,
              *aw_valid,
               aw_ready,
              * w_valid,
                w_ready,
                b_valid,
              * b_ready,
                b_id);
    mst->release();
}

void firesim_axi_slv_drv_tick(LIST(, *)) {
    if (reset) {
        *ar_ready = 0;
        * r_valid = 0;
        *aw_ready = 0;
        * w_ready = 0;
        * b_valid = 0;

        return;
    }

    auto slv = g_emu->slv(i).get();

    slv->acquire();
    *ar_ready = slv->ar_ready();
    * r_valid = slv-> r_valid();
    *aw_ready = slv->aw_ready();
    * w_ready = slv-> w_ready();
    * b_valid = slv-> b_valid();

    auto r = slv->r_payld();
    auto b = slv->b_payld();

    if (*r_valid) {
        *r_id   = r->m_id;
        *r_last = r->m_last;

        memcpy(r_data, r->m_data, slv->get_wid());
    }

    if (*b_valid) {
        *b_id   = b->m_id;
    }
    slv->release();
}

void firesim_axi_slv_mon_tick(LIST(, *)) {
    if (reset)
        return;

    auto slv = g_emu->slv(i).get();

    slv->acquire();
    slv->tick( ar_valid,
              *ar_ready,
               ar_addr & MASK_ADDR,
               ar_id   & MASK_ID,
               ar_size & MASK_SIZE,
               ar_len  & MASK_LEN,
              * r_valid,
                r_ready,
               aw_valid,
              *aw_ready,
               aw_addr & MASK_ADDR,
               aw_id   & MASK_ID,
               aw_size & MASK_SIZE,
               aw_len  & MASK_LEN,
                w_valid,
              * w_ready,
                w_data,
                w_strb & MASK_STRB,
                w_last,
              * b_valid,
                b_ready);
    slv->release();
}

#undef LIST

}
