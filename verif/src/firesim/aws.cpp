// See LICENSE.md for license details

#include <unistd.h>
#include <fcntl.h>

#include "Dut.fs.const.h"
#include "aws.h"
#include "common.h"
#include "new_load.h"

#ifdef REAL
#include "fpga_mgmt.h"
#else
extern "C" {

void tb_peek_ocl (unsigned long long addr, unsigned int *data);
void tb_poke_ocl (unsigned long long addr, unsigned int  data);
void tb_peek_pcis(unsigned long long addr, unsigned int *data);
void tb_poke_pcis(unsigned long long addr, unsigned int  data);

}
#endif


void aws_t::host_init(int argc, char **argv) {
    sim_t::host_init(argc, argv);

    // parse
    std::vector<std::string> args(argv + 1, argv + argc);

    auto bin  = "bin";
    auto img  = "";
    int  slot =  0;
    int  ret;

    for (auto &a: args) {
        if (a.rfind("+bin=" ) == 0)
            bin  = a.c_str() + 5;
        if (a.rfind("+img=" ) == 0)
            img  = a.c_str() + 5;
        if (a.rfind("+slot=") == 0)
            slot = atoi(a.c_str() + 6);
    }

    printf("INFO: setting up PCIe %d\n", slot);

#ifdef REAL
    if ((ret = fpga_mgmt_init()))
        die("fpga_mgmt_init failed");

    struct fpga_mgmt_image_info info = {0};

    info.spec.map[FPGA_APP_PF].vendor_id = 0;
    info.spec.map[FPGA_APP_PF].device_id = 0;

    while (true) {
        if ((ret = fpga_mgmt_describe_local_image(slot, &info, 0)))
            die("fpga_mgmt_describe_local_image(%d) failed. maybe you are not root?", slot);

        if (info.status != FPGA_STATUS_LOADED)
            die("AFI is not ready");

        if ((info.spec.map[FPGA_APP_PF].vendor_id == 0x1d0f) ||
            (info.spec.map[FPGA_APP_PF].device_id == 0xf001))
            break;

        if ((ret = fpga_pci_rescan_slot_app_pfs(slot)))
            die("fpga_pci_rescan_slot_app_pfs(%d) failed", slot);
    }

    m_pci = PCI_BAR_HANDLE_INIT;
    if ((ret = fpga_pci_attach(slot, FPGA_APP_PF, APP_PF_BAR0, 0, &m_pci)))
        die("fpga_pci_attach failed");

    std::string h2c("/dev/xdma");
    std::string c2h("/dev/xdma");

    h2c.append(std::to_string(slot)).append("_h2c_0");
    c2h.append(std::to_string(slot)).append("_c2h_0");

    if ((m_dma_rd = open(c2h.c_str(), O_RDONLY)) < 0)
        die("open(%s) failed", c2h.c_str());
    if ((m_dma_wr = open(h2c.c_str(), O_WRONLY)) < 0)
        die("open(%s) failed", h2c.c_str());
#endif

    printf("INFO: loading %s...\n", bin);

    // we know it is the last
    new_load_t *load = dynamic_cast<new_load_t *>(m_drv.back().get());

    load->mem_init(bin);
    load->mem_init(img, 0x2000000);

    printf("INFO: done\n");
}

int aws_t::host_finish(void) {
    int ret = 0;

    if (m_pci == 0)
        return 0;

#ifdef REAL
    if ((ret = fpga_pci_detach(m_pci)))
        die("fpga_pci_detach failed");

    close(m_dma_rd);
    close(m_dma_wr);
#endif

    return ret;
}


uint32_t aws_t::read(size_t addr) {
    uint32_t val;

#ifdef REAL
    if (fpga_pci_peek(m_pci, addr, &val))
        die("fpga_pci_peek(%d, %zx) failed", m_pci, addr);
#else
    tb_peek_ocl(addr, &val);
#endif

    return val;
}

void aws_t::write(size_t addr, uint32_t data) {
#ifdef REAL
    if (fpga_pci_poke(m_pci, addr, data))
        die("fpga_pci_poke(%d, %zx, %x) failed", m_pci, addr, data);
#else
    tb_poke_ocl(addr, data);
#endif
}


size_t aws_t::pcis_rd(size_t addr, void *data, size_t size) {
#ifdef REAL
    return pread (m_dma_rd, data, size, addr);
#else
    uint32_t *ptr = (uint32_t *)(data);

    for (int i = 0; i < size; i += 4, ptr++)
        tb_peek_pcis(addr + i, ptr);

    return size;
#endif
}

size_t aws_t::pcis_wr(size_t addr, void *data, size_t size) {
#ifdef REAL
    return pwrite(m_dma_wr, data, size, addr);
#else
    uint32_t *ptr = (uint32_t *)(data);

    for (int i = 0; i < size; i += 4, ptr++)
        tb_poke_pcis(addr, *ptr);

    return size;
#endif
}


static aws_t *g_aws = NULL;


#ifdef REAL
int main(int argc, char **argv) {
    g_aws = new aws_t();
    g_aws->host_init(argc, argv);
    g_aws->main();

    return 0;
}
#else
extern "C" {

void firesim_main(const char *r, const char *b, const char *i, int p) {
    std::string rom ("+rom=");
    std::string bin ("+bin=");
    std::string img ("+img=");
    std::string port("+port=");

    rom  += r;
    bin  += b;
    img  += i;
    port += p;

    char *args[] = {(char *)("self"),
                    (char *)( rom .c_str()),
                    (char *)( bin .c_str()),
                    (char *)( img .c_str()),
                    (char *)( port.c_str()),
                    (char *)("+mm_readLatency_0=30"),
                    (char *)("+mm_readMaxReqs_0=8"),
                    (char *)("+mm_writeLatency_0=30"),
                    (char *)("+mm_writeMaxReqs_0=8"),
                    (char *)("+mm_relaxFunctionalModel_0=0"),
                    (char *)("+inc=50")};

    g_aws = new aws_t();
    g_aws->host_init(11, args);
    g_aws->main();
}

}
#endif
