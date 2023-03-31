#ifndef __NEW_ROM_H__
#define __NEW_ROM_H__

#include <string>

#include "common.h"
#include "mem.h"


class new_rom_t: public common_t {
public:
    new_rom_t(sim_t *sim, type_t *mmio, const char *fn, uint64_t base, uint64_t cap);
   ~new_rom_t(void) { }

    virtual void tick  (void);
    virtual void init  (void) { }
    virtual void finish(void) { }

private:
    uint64_t m_base;
    mem_t    m_mem;

    int      m_fsm  = 0;
    uint64_t m_data = 0;
};

#endif