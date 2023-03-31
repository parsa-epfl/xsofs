#ifndef __NEW_LOAD_H__
#define __NEW_LOAD_H__

#include "common.h"


class new_load_t: public bridge_driver_t {
public:
    typedef LOADMEMWIDGET_struct type_t;

    new_load_t(sim_t *sim, type_t *mmio);
   ~new_load_t(void) { }

    virtual void init     (void) { }
    virtual void tick     (void) { }
    virtual void finish   (void) { }

    virtual bool terminate(void) { return false; }
    virtual int  exit_code(void) { return 0;     }

    uint32_t rd(uint64_t addr)                { return m_sim->read(addr); }
    void     wr(uint64_t addr, uint32_t data) { m_sim->write(addr, data); }

    void mem_init(const char *fn, uint64_t offs = 0);
    void mem_zero(void);
    void mem_rd  (uint64_t addr, void *data);
    void mem_wr  (uint64_t addr, void *data);

private:
    sim_t   *m_sim;
    type_t  *m_mmio;
};

#endif