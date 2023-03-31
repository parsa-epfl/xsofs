#ifndef __COMMON_H__
#define __COMMON_H__

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#include "Dut.fs.const.h"
#include "sim.h"


#define die(fmt, ...)                           \
    do {                                        \
        fprintf(stderr, "%s:%d: " fmt ": %s\n", \
                __FILE__, __LINE__,             \
                ##__VA_ARGS__,                  \
                strerror(errno));               \
        exit(-1);                               \
    } while (0)


class common_t: public bridge_driver_t {
public:
    typedef FIRESIMBRIDGEIMP_struct type_t;

    common_t(sim_t *sim, type_t *mmio): bridge_driver_t(sim), m_sim(sim), m_mmio(mmio) { }
   ~common_t(void) { free(m_mmio); }

    virtual void init     (void) = 0;
    virtual void tick     (void) = 0;
    virtual void finish   (void) = 0;

    virtual bool terminate(void) { return false; }
    virtual int  exit_code(void) { return 0;     }

protected:
    uint32_t rd(uint64_t addr)                { return m_sim->read(addr); }
    void     wr(uint64_t addr, uint32_t data) { m_sim->write(addr, data); }

    sim_t   *m_sim;
    type_t  *m_mmio;
};

#endif
