// See LICENSE.md for license details

#ifndef __AWS_H__
#define __AWS_H__

#include "sim.h"


class aws_t: public sim_t {
public:
    aws_t(void): sim_t(false) { }
   ~aws_t(void)               { }

    virtual void     host_init  (int argc, char **argv);
    virtual int      host_finish(void);

    virtual void     write      (size_t addr, uint32_t data);
    virtual uint32_t read       (size_t addr);

private:
    virtual size_t   pcis_rd    (size_t addr, void *data, size_t size);
    virtual size_t   pcis_wr    (size_t addr, void *data, size_t size);

    int m_pci = 0;
    int m_dma_rd;
    int m_dma_wr;
};

#endif
