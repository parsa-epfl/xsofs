#include <common.h>
#include <locale.h>

#include "difftest.h"
#include "device.h"
#include "goldenmem.h"
#include "ram.h"
#include "flash.h"
#include "refproxy.h"


#define MAX 256


static bool g_en = false;

static char g_lib[MAX];
static char g_rom[MAX];
static char g_bin[MAX];
static char g_img[MAX];
static char g_cmd[MAX];


extern const char *difftest_ref_so;


extern "C" {

int diff_init(const char *lib,
              const char *rom,
              const char *bin,
              const char *img,
              const char *cmd) {

    if (!strlen(lib) || !strlen(rom) || !strlen(bin))
        return 0;

    strncpy(g_lib, lib, MAX);
    strncpy(g_rom, rom, MAX);
    strncpy(g_bin, bin, MAX);
    strncpy(g_img, img, MAX);
    strncpy(g_cmd, cmd, MAX);

    difftest_ref_so = g_lib;

    init_ram  (g_bin);
    init_flash(g_rom);

    if (getenv("NO_DIFF"))
        return 0;

    difftest_init(g_cmd);

    init_device   ();
    init_goldenmem();
    init_nemuproxy(1lu << 31);

    difftest_load(g_img, 0x2000000);

    g_en = true;

    return 1;
}

int diff_step(const uint64_t time) {
    if (g_en == false)
        return 0;

    if (assert_count > 0) {
        eprintf("assert_count: %d\n", assert_count);
        return 1;
    }

    int state;

    if ((state = difftest_state()) != -1) {
        eprintf("difftest_state(): %d\n", state);
        return state + 1;
    }

    return difftest_step(time);
}

}
