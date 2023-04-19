// See LICENSE.md for license details

#ifndef __NEW_JTAG_H__
#define __NEW_JTAG_H__

#include <pthread.h>

#include "common.h"


class new_jtag_t: public common_t {
public:
    new_jtag_t(sim_t *sim, type_t *mmio, int port);
   ~new_jtag_t(void) { }

    virtual void tick  (void);
    virtual void init  (void);
    virtual void finish(void);

    void wait(void);

private:
    bool sock_rd(void);
    void sock_wr(void);

    pthread_t m_thrd;
    bool      m_flag = false;

    int       m_port;
    int       m_srv;
    int       m_cli;

    int       m_fsm = 0;
    int       m_cnt = 0;
    uint8_t  *m_ptr = NULL;
    uint32_t *m_in;
    uint32_t *m_out;

    struct {
        uint32_t cmd;
        uint8_t  in  [512];
        uint8_t  out [512];
        uint32_t bytes;
        uint32_t bits;
    } m_cmd;
};

#endif
