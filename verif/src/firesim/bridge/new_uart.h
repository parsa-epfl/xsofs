#ifndef __NEW_UART_H__
#define __NEW_UART_H__

#include <deque>
#include "common.h"


class new_uart_t: public common_t {
public:
    new_uart_t(sim_t *sim, type_t *mmio);
   ~new_uart_t(void) { }

    virtual void tick  (void);
    virtual void init  (void);
    virtual void finish(void) { }

private:
    std::deque<char> m_que;
};

#endif