// See LICENSE.md for license details

#ifndef __EMU_H__
#define __EMU_H__

#include "sim.h"
#include "axi_mst.h"
#include "axi_slv.h"


class emu_t: public sim_t {
public:
    emu_t(void): sim_t(true) { }
   ~emu_t(void)              { }

    virtual void     host_init  (int argc, char **argv);
    virtual int      host_finish(void) { return 0; }

    virtual void     write      (size_t addr, uint32_t data);
    virtual uint32_t read       (size_t addr);

    std::unique_ptr<axi_mst_t> &mst(int i) { return m_mst[i]; }
    std::unique_ptr<axi_slv_t> &slv(int i) { return m_slv[i]; }

    void fork   (void);
    void tick   (void);

private:
    virtual size_t   pcis_rd    (size_t addr, void *data, size_t size);
    virtual size_t   pcis_wr    (size_t addr, void *data, size_t size);

    void wait_rd(std::unique_ptr<axi_mst_t> &axi, void *data);
    void wait_wr(std::unique_ptr<axi_mst_t> &axi);
    void wait   (void);

    std::vector<std::unique_ptr<axi_mst_t>> m_mst;
    std::vector<std::unique_ptr<axi_slv_t>> m_slv;

    pthread_t        m_thrd;
    pthread_mutex_t  m_lock = PTHREAD_MUTEX_INITIALIZER;
    pthread_cond_t   m_cond = PTHREAD_COND_INITIALIZER;
};

#endif
