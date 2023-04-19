// See LICENSE.md for license details

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/stat.h>

#include "mem.h"


#define die(fmt, ...)                           \
    do {                                        \
        fprintf(stderr, "%s:%d: " fmt ": %s\n", \
                __FILE__, __LINE__,             \
                ##__VA_ARGS__,                  \
                strerror(errno));               \
        exit(-1);                               \
    } while (0)


mem_t::mem_t(uint64_t wid, uint64_t cap):
    m_mem(NULL),
    m_wid(wid ),
    m_cap(cap ),
    m_shf(__builtin_ctz(wid)) { }

mem_t::~mem_t(void) {
    if (m_mem)
        munmap(m_mem, m_cap);
}


void mem_t::init(const char *fn, uint64_t offs) {
    FILE *fp;

    if ((fn == NULL) || !strlen(fn))
        return;

    if (m_mem == NULL)
        if ((m_mem = mmap(NULL, m_cap, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE | MAP_NORESERVE, -1, 0)) == MAP_FAILED)
            die("mmap(%lx) failed", m_cap);

    if ((fp = fopen(fn, "rb")) == NULL)
        die("fopen(%s) failed", fn);

    struct stat st;
    stat(fn, &st);

    if (fread((char *)(m_mem) + offs, st.st_size, 1, fp) != 1)
        die("fread(%lx) failed", st.st_size);

    fclose(fp);
}


void mem_t::rd(uint64_t addr, void *data) {
    memcpy(data, (char *)(m_mem) + (addr << m_shf), m_wid);
}

void mem_t::wr(uint64_t addr, void *data, void *strb) {
    auto dst = (char *)(m_mem) + (addr << m_shf);
    auto src = (char *)(data);
    auto chk = (char *)(strb);

    for (auto i = 0lu; i < m_wid; i++) {
        auto x = i >> 0x3;
        auto y = i &  0x7;

        if ((chk[x] >> y) & 0x1)
            dst[i] = src[i];
    }
}


static mem_t *g_mem = NULL;


extern "C" {

void mem_init(const char *fn, uint64_t wid, uint64_t cap) {
    g_mem = new mem_t(wid, cap);
    g_mem->init(fn);
}

void mem_load(const char *fn, uint64_t offs) {
    g_mem->init(fn, offs);
}

void mem_rd(uint64_t addr, uint32_t *data) {
    g_mem->rd(addr, data);
}

void mem_wr(uint64_t addr, uint32_t *data, uint32_t *strb) {
    g_mem->wr(addr, data, strb);
}

}
