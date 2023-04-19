// See LICENSE.md for license details

#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/tcp.h>

#include "new_jtag.h"


new_jtag_t::new_jtag_t(sim_t *sim, type_t *mmio, int port): common_t(sim, mmio),
    m_port(port) { }


static void *jtag_wait(void *p) {
    auto jtag = (new_jtag_t *)(p);

    jtag->wait();

    return NULL;
}


void new_jtag_t::init(void) {
    if (m_port < 0)
        return;

    if ((m_srv = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        die("socket(%i) failed", m_port);

    int flag = 1;
    if (setsockopt(m_srv, SOL_SOCKET, SO_REUSEPORT, &flag, sizeof(flag)) < 0)
        die("setsockopt(%i) failed", m_srv);

    struct sockaddr_in sock;

    memset(&sock, 0, sizeof(sock));
    sock.sin_family      = AF_INET;
    sock.sin_addr.s_addr = htonl(INADDR_ANY);
    sock.sin_port        = htons(m_port);

    if (bind(m_srv, (struct sockaddr *)(&sock), sizeof(sock)) < 0)
        die("bind(%d) failed", m_srv);

    pthread_create(&m_thrd, NULL, jtag_wait, this);
    pthread_detach( m_thrd);
}


void new_jtag_t::wait(void) {
    if (listen(m_srv, 1) < 0)
        die("listen(%d) failed", m_srv);

    if ((m_cli = accept(m_srv, (struct sockaddr *)(NULL), NULL)) < 0)
        die("accept(%d) failed", m_srv);

    int flag = 1;
    if (setsockopt(m_cli, IPPROTO_TCP, TCP_NODELAY, (void *)(&flag), sizeof(flag)) < 0)
        die("setsocketopt(%d) failed", m_cli);

    m_flag = true;
}


void new_jtag_t::finish(void) {
    shutdown(m_srv, SHUT_RDWR);
    shutdown(m_cli, SHUT_RDWR);
}


bool new_jtag_t::sock_rd(void) {
    if (m_ptr == NULL) {
        m_ptr = (uint8_t *)(&m_cmd);
        m_cnt =  sizeof(m_cmd);
    }

    while (m_cnt) {
        int ret = recv(m_cli, m_ptr, m_cnt, MSG_DONTWAIT);

        switch (ret) {
        case -1:
            if ((errno == EAGAIN) || (errno == EWOULDBLOCK))
                return false;
            die("read(%d) failed", m_cli);

        case  0:
            m_flag = false;
            return false;
        }

        m_ptr += ret;
        m_cnt -= ret;
    }

    switch (m_cmd.cmd) {
    case 0:
        m_cmd.cmd   = 2;
        m_cmd.bits  = 5;
        m_cmd.bytes = 1;

        // tms: 011111
        m_cmd.in[0] = 0x1f;
        break;

    case 1:
    case 2:
    case 3:
        m_cmd.cmd  ^= 2;
        m_cmd.bits -= 1;
        break;

    default:
        die("unsupported cmd: %d\n", m_cmd.cmd);
    }

    m_in  = (uint32_t *)(m_cmd.in);
    m_out = (uint32_t *)(m_cmd.out);
    m_cnt =  m_cmd.bytes;

    return true;
}

void new_jtag_t::sock_wr(void) {
    m_cmd.cmd  ^= 2;
    m_cmd.bits += 1;

    uint8_t *buf = (uint8_t *)(&m_cmd);
    uint32_t cnt =  sizeof(m_cmd);

    while (cnt) {
        int ret = send(m_cli, buf, cnt, 0);

        switch (ret) {
        case -1:
            if ((errno == EAGAIN) || (errno == EWOULDBLOCK))
                continue;
            die("send(%d) failed", m_cli);

        case  0:
            m_flag = false;
            return;
        }
    }

    m_ptr = NULL;
}


void new_jtag_t::tick(void) {
    if (!m_flag)
        return;

    bool resp;

    switch (m_fsm) {
    case 0:
        if (sock_rd())
            m_fsm++;
        return;

    case 1:
        if (rd(m_mmio->tx_ready)) {
            wr(m_mmio->tx_bits, (m_cmd.cmd << 16) | (m_cmd.bits & 0xffff));
            wr(m_mmio->tx_valid, true);

            m_fsm++;
        }
        return;

    case 2:
        if (rd(m_mmio->tx_ready)) {
            wr(m_mmio->tx_bits,  m_in[0]);
            wr(m_mmio->tx_valid, true);

            m_fsm++;
        }
        return;

    case 3:
        resp = !((m_cmd.cmd >> 1) & 0x1);

        if (resp && rd(m_mmio->rx_valid)) {
            m_out[0] = rd(m_mmio->rx_bits);
            wr(m_mmio->rx_ready, true);
        }

        m_in  += 1;
        m_out += 1;
        m_cnt -= 1;
        m_fsm  = 2;

        if (m_cnt == 0) {
            if (resp)
                sock_wr();
            m_fsm = 0;
        }
        return;
    }
}
