#include <liblox/common.h>
#include <stdint.h>

#define mmio_op(x) *((uintptr_t*) (x))

uint32_t mmio_read(uint32_t reg);
void mmio_write(uint32_t reg, uint32_t data);
