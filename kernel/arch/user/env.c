﻿#include <liblox/lox-internal.h>
#include <liblox/io.h>

#include <kernel/tty.h>
#include <kernel/rkmalloc/rkmalloc.h>
#include <kernel/time.h>
#include <kernel/cpu/task.h>

#include "env.h"

tty_t* console_tty = NULL;

void heap_init(void) {}
void paging_init(void) {}

void arch_panic_handler(char* msg) {
    if (msg != NULL) {
        puts(msg);
    }

    raptor_user_abort();
}

rkmalloc_heap* heap_get(void) {
    return NULL;
}

static ulong ticks = 0;

ulong timer_get_ticks(void) {
    return ++ticks;
}

void irq_wait(void) {
}

void kernel_setup_devices(void) {
    tty_t* tty = tty_create("console");
    tty->write = raptor_user_console_write;
    tty->flags.write_kernel_log = true;
    tty->flags.allow_debug_console = true;

#ifndef __unix__
    tty->flags.echo = true;
#endif

    tty_register(tty);
    console_tty = tty;
}

void kernel_modules_load(void) {}

void time_get(time_t* time) {
    memset(time, 0, sizeof(time_t));
}

void cpu_run_idle(void) {
    while (true) {
        ktask_queue_flush();
        raptor_user_process_stdin();
    }
}

void* (*lox_allocate_provider)(size_t) = raptor_user_malloc;
void* (*lox_reallocate_provider)(void*, size_t) = raptor_user_realloc;
void (*lox_free_provider)(void*) = raptor_user_free;
void (*lox_output_char_provider)(char) = raptor_user_output_char;
void (*lox_output_string_provider)(char*) = raptor_user_output_string;
char* (*arch_get_cmdline)(void) = raptor_user_get_cmdline;
