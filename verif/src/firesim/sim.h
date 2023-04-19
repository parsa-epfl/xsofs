// See LICENSE.md for license details

#ifndef __SIM_H__
#define __SIM_H__

#include <pthread.h>

#include <string>
#include <memory>
#include <vector>

#include "simif.h"
#include "bridge_driver.h"
#include "cpu_managed_stream.h"
#include "fpga_model.h"


class sim_t: public simif_t {
public:
    sim_t(bool e): simif_t(), m_emu(e) { }
   ~sim_t(void)                        { }

    virtual void     host_init  (int argc, char **argv) = 0;
    virtual int      host_finish(void)                  = 0;

    virtual void     write      (size_t addr, uint32_t data) = 0;
    virtual uint32_t read       (size_t addr)                = 0;

    virtual size_t   push       (unsigned int sid, void *src, size_t nb, size_t tb);
    virtual size_t   pull       (unsigned int sid, void *dst, size_t nb, size_t tb);

    void main(void);

    int  curr(void) { return m_fsm;   }
    void next(void) {        m_fsm++; }

protected:
    virtual size_t   pcis_rd    (size_t addr, void *data, size_t size) = 0;
    virtual size_t   pcis_wr    (size_t addr, void *data, size_t size) = 0;

    std::vector<StreamToCPU  > m_to;
    std::vector<StreamFromCPU> m_from;

    std::vector<std::unique_ptr<bridge_driver_t>> m_drv;
    std::vector<std::unique_ptr<FpgaModel      >> m_mod;

private:
    bool m_emu;
    int  m_inc;
    int  m_fsm = 0;
};

#endif
