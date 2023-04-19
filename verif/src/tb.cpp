// See LICENSE.md for license details

#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/ioctl.h>

#include <iostream>
#include <string>
#include <unistd.h>

#include "Vtb.h"
#include "Vtb__Syms.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#ifdef CHK
#include "Dut.h"
#endif
#ifdef DIFFTEST
#include "difftest.h"
#endif


#define SCALE 10


#define err(fmt, ...)                           \
    do {                                        \
        fprintf(stderr, "%s:%d: " fmt ": %s\n", \
                __FILE__, __LINE__,             \
                ##__VA_ARGS__,                  \
                strerror(errno));               \
        goto err;                               \
    } while (0)


// see: http://bloglitb.blogspot.com/2010/07/access-to-private-members-thats-easy.html
// see: https://gist.github.com/dabrahams/1528856
template <class Tag>
struct stowed {
    static typename Tag::type value;
}; 
template <class Tag> 
typename Tag::type stowed<Tag>::value;

template <class Tag, typename Tag::type x>
struct stowed_store {
    stowed_store(void) {
        stowed<Tag>::value = x;
    }
};

struct stowed_sym {
    typedef Vtb__Syms* const (Vtb::*type);
};
template class stowed_store<stowed_sym, &Vtb::vlSymsp>;


Vtb             *g_top  = NULL;
VerilatedVcdC   *g_vcd  = NULL;

std::atomic<int> g_flag;
vluint64_t       g_time = 0;
vluint64_t       g_next = 0;

struct termios   g_term;
int              g_cntl;


double sc_time_stamp(void) {
    return g_time;
}


// currently the only terminal that supports reusing existing ptys
static int xterm(const char *name, int mfd, int sfd) {
    std::string args("-S");

    int nul = -1;
    int pid = fork();

    if (pid < 0)
        err("fork");
    else if (pid)
        return 0;

    args.append(name)
        .append("/")
        .append(std::to_string(mfd));

    if ((nul = open("/dev/null", O_WRONLY)) < 0)
        err("open(/dev/null)");

    dup2(nul, 1);
    dup2(nul, 2);

    close(nul);
    close(sfd);

    if (execl("/usr/bin/xterm",
              "xterm", args.c_str(), NULL))
        err("exec");

    return 0;

err:
    return 1;
}

static void evil(void) {
    Vtb__Syms     *sym = g_top->*stowed<stowed_sym>::value;
    VlThreadPool **thp = const_cast<VlThreadPool **>(&sym->__Vm_threadPoolp);

    *thp = new VlThreadPool(g_top->contextp(), (*thp)->numThreads());
}

static void repl_fork(void) {
    std::string log("sim.");

    int mfd = -1;
    int sfd = -1;
    int pid = fork();

    if (pid < 0)
        err("fork");
    else if (pid)
        return;

    if ((mfd = open("/dev/ptmx", O_RDWR)) < 0)
        err("open(/dev/ptmx)");

    if (grantpt (mfd))
        err("grantpt");
    if (unlockpt(mfd))
        err("unlockpt");

    const char *name;
    if ((name = ptsname(mfd)) == NULL)
        err("ptsname");

    if ((sfd = open(name, O_RDWR)) < 0)
        err("open(%s)", name);

    if (xterm(name, mfd, sfd))
        goto err;

    if (setsid() < 0)
        err("setsid");
    if (ioctl(sfd, TIOCSCTTY, NULL) < 0)
        err("ioctl");

    log.append(std::to_string(getpid()))
       .append(".log");

    if ((pid = open(log.c_str(), O_RDWR | O_CREAT, 0644)) < 0)
        err("open(%s)", log.c_str());

    dup2(sfd, 0);
    dup2(sfd, 1);
    dup2(pid, 2);

    close(mfd);
    close(sfd);
    close(pid);

    evil();

    return;

err:
    if (mfd >= 0)
        close(mfd);
    if (sfd >= 0)
        close(sfd);
}

static bool repl_args(const std::string &str, std::string &sub) {
    if (str.length() <= 2)
        return false;
    if (str[1] != ' ')
        return false;

    sub = std::move(str.substr(2));
    return true;
}

static bool repl_args(const std::string &str, uint64_t &val) {
    std::string sub;

    if (!repl_args(str, sub))
        return false;

    try {
        val = std::stoi(sub);
    } catch (std::invalid_argument) {
        return false;
    } catch (std::out_of_range) {
        return false;
    }

    return true;
}

static void repl(int sig, siginfo_t *si, void *arg) {
    struct sigaction cur;
    struct sigaction bak;

    switch (sig) {
        case SIGINT:
            g_flag = 1;
            return;

        case SIGTERM:
            printf("Caught SIGTERM\n");
            break;

        case SIGABRT:
            printf("Caught SIGABRT\n");
            break;

        case -1:
            sigemptyset(&cur.sa_mask);
            cur.sa_handler = SIG_IGN;
            sigaction(SIGINT, &cur, &bak);
    }

    struct termios term;
    int            cntl = fcntl(STDIN_FILENO, F_GETFL);

    tcgetattr(STDIN_FILENO, &term);
    tcsetattr(STDIN_FILENO,  TCSANOW, &g_term);
    fcntl    (STDIN_FILENO,  F_SETFL,  g_cntl);

    while (1) {
        printf(">>> ");
        fflush(stdout);

        std::string str;
        std::getline(std::cin, str);

        if (str == "q")
            exit(0);

        else if (str == "t")
            printf("%ld\n", g_time / SCALE);

        else if (str == "f") {
            if (g_vcd->isOpen())
                printf("Please close the dump file before forking.\n");
            else
                repl_fork();
        }
#ifdef DIFFTEST
        else if (str.rfind("x", 0) == 0) {
            std::string args;

            if (repl_args(str, args))
                difftest_flag(args.c_str());
        }
#endif
        else if (str.rfind("c", 0) == 0) {
            uint64_t diff;

            if (str == "c") {
                g_next = 0;
                goto ret;
            }
            if (repl_args(str, diff)) {
                g_next = g_time + diff * SCALE;
                goto ret;
            }
        }
        else if (str.rfind("u", 0) == 0) {
            uint64_t time;

            if (repl_args(str, time)) {
                g_next = time * SCALE;
                goto ret;
            }
        }
        else if (str.rfind("d", 0) == 0) {
            std::string open;

            if (repl_args(str, open) && !g_vcd->isOpen())
                g_vcd->open(open.c_str());
            else if (g_vcd->isOpen())
                g_vcd->close();
        }
#ifdef CHK
        else if (str.rfind("s", 0) == 0) {
            std::string open;

            if (repl_args(str, open))
                save_db(open.c_str());
        }
#endif
    }

ret:
    tcsetattr(STDIN_FILENO, TCSANOW, &term);
    fcntl    (STDIN_FILENO, F_SETFL,  cntl);

    g_flag = 0;

    if (sig == -1)
        sigaction(SIGINT, &bak, NULL);
}


int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);

    Verilated::assertOn(false);
    Verilated::randReset(2);
    Verilated::traceEverOn(true);

    tcgetattr(STDIN_FILENO, &g_term);

    g_cntl = fcntl(STDIN_FILENO, F_GETFL);
    g_top  = new Vtb;
    g_vcd  = new VerilatedVcdC;

    g_top->trace(g_vcd, 99);

    struct sigaction sig;

    sigemptyset(&sig.sa_mask);
    sig.sa_sigaction = repl;
    sig.sa_flags     = SA_SIGINFO;

    sigaction(SIGINT,  &sig, NULL);
    sigaction(SIGTERM, &sig, NULL);
    sigaction(SIGABRT, &sig, NULL);

    while (!Verilated::gotFinish()) {
        g_top->reset = g_time < (20 * SCALE);

        for (int i = 1; i >= 0; i--) {
            g_top->clock = i;
            g_top->eval();

            if (g_top->dump_o && !g_vcd->isOpen())
                g_vcd->open("dump.vcd");
            if (g_top->dump_o ||  g_vcd->isOpen())
                g_vcd->dump(g_time);

            g_time += SCALE / 2;
        }

        if (g_time == (60 * SCALE))
            Verilated::assertOn(true);

        if (g_flag || g_next && (g_time >= g_next))
            repl(-1, NULL, NULL);
    }

    g_top->final();

    if (g_vcd->isOpen())
        g_vcd->close();

    delete g_top;
    delete g_vcd;

    return 0;
}
