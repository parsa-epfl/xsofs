#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

#include "new_uart.h"


new_uart_t::new_uart_t(sim_t *sim, type_t *mmio): common_t(sim, mmio) { }


void new_uart_t::init(void) {
    // non-blocking
    if (fcntl(STDIN_FILENO, F_SETFL, fcntl(0, F_GETFL) | O_NONBLOCK) == -1)
        die("fcntl(%d) failed", STDIN_FILENO);

    // non-buffering
    struct termios ios;

    if (tcgetattr(STDIN_FILENO, &ios))
        die("tcgetattr(%d) failed", STDIN_FILENO);

    ios.c_lflag  &= ~(ICANON | ECHO | ECHOE);
    ios.c_cc[VMIN ] = 0;
    ios.c_cc[VTIME] = 0;

    if (tcsetattr(STDIN_FILENO, TCSANOW, &ios))
        die("tcsetattr(%d) failed", STDIN_FILENO);
}


void new_uart_t::tick(void) {
    if (m_que.size() < 64) {
        char c;

        if (::read(STDIN_FILENO, &c, 1) == 1)
            m_que.push_back(c);
    }

    if (m_que.size() && rd(m_mmio->tx_ready)) {
        wr(m_mmio->tx_bits, (uint32_t)(m_que.front()));
        wr(m_mmio->tx_valid, true);

        m_que.pop_front();
    }

    if (rd(m_mmio->rx_valid)) {
        if (m_sim->curr() == 0)
            m_sim->next();

        char c = (char)(rd(m_mmio->rx_bits));

        if (c == 0x7f) {
            putchar('\b');
            putchar(' ');
            putchar('\b');
        } else
            putchar(c);

        fflush(stdout);

        wr(m_mmio->rx_ready, true);
    }
}