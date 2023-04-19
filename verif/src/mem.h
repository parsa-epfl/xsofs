// See LICENSE.md for license details

#ifndef __MEM_H__
#define __MEM_H__

#include <stdint.h>
#include <stddef.h>


class mem_t {
public:
    mem_t(uint64_t wid, uint64_t dep);
   ~mem_t(void);

    void init(const char *fn, uint64_t offs = 0);
    void rd  (uint64_t addr, void *data);
    void wr  (uint64_t addr, void *data, void *strb);

    inline uint64_t get_wid (void)          { return         m_wid; }
    inline uint64_t get_addr(uint64_t addr) { return addr >> m_shf; }

private:
    void    *m_mem = NULL;
    uint64_t m_wid;
    uint64_t m_cap;
    uint32_t m_shf;
};

#endif
