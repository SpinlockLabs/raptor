arch("x86" "arch/x86")
option(OPTIMIZE_NATIVE "Optimize for the native machine." OFF)
option(ENABLE_X64 "Enable x86_64 mode." OFF)

cflags(
  -DARCH_X86
)

if(ENABLE_X64)
  cflags(-m64)
else()
  cflags(-m32)
endif()

if(CLANG)
  cflags(-target i686-pc-elf)
endif()

if(OPTIMIZE_NATIVE)
    cflags(-march=native)
else()
    cflags(-mtune=generic)
endif()

kernel_cflags(
  -fno-stack-protector
  -fno-pic
)

if(NOT CLANG)
  kernel_cflags(-no-pie)
endif()

if(EXISTS ${RAPTOR_DIR}/kernel/arch/x86/acpi/include)
  kernel_cflags(-I${RAPTOR_DIR}/kernel/arch/x86/acpi/include)
endif()

kernel_ldscript("${KERNEL_DIR}/arch/x86/linker.ld")

set(QEMU_CMD_BASE
  qemu-system-i386
    -cpu core2duo
    -m 256
    -net nic,model=rtl8139
    -drive "file=${CMAKE_BINARY_DIR}/raptor.img,format=raw,if=ide,media=disk"
)

set(QEMU_CMD
  ${QEMU_CMD_BASE}
)

add_custom_target(qemu
  COMMAND ${QEMU_CMD} -net user
  DEPENDS kernel diskimg
)

add_custom_target(qemu-gdb
  COMMAND ${QEMU_CMD} -S -s -append debug -net user
  DEPENDS kernel diskimg
)

add_custom_target(qemu-cli
  COMMAND ${QEMU_CMD} -monitor none -nographic -net user
  DEPENDS kernel diskimg
)

add_custom_target(qemu-cli-gdb
  COMMAND ${QEMU_CMD} -S -s -append debug -monitor none -nographic
  DEPENDS kernel diskimg
)

add_custom_target(
  iso
  DEPENDS kernel filesystem
  COMMAND bash
            ${CMAKE_SOURCE_DIR}/build/scripts/mkgrubiso.sh
            "${CMAKE_BINARY_DIR}/kernel.elf"
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
)

add_custom_target(qemu-iso
  COMMAND ${QEMU_CMD_BASE}
            -cdrom "${CMAKE_BINARY_DIR}/raptor.iso"
            -boot d
            -monitor none
            -nographic
            -net user
  DEPENDS iso diskimg
)

add_custom_target(bochs
  COMMAND bochs -q -f "${CMAKE_SOURCE_DIR}/build/bochs/raptor.bcfg"
  DEPENDS iso
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
)

add_custom_target(
  diskimg
  COMMAND "${CMAKE_SOURCE_DIR}/build/scripts/gendiskimg.sh"
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
  DEPENDS filesystem
  SOURCES ${FS_DIR}
  USES_TERMINAL
)

if(RAPTOR_WINDOWS)
    add_custom_target(qemu-windows
      COMMAND "C:/Program Files/qemu/qemu-system-i386.exe"
            -net user
            -net nic,model=e1000
            -cpu core2duo
            -m 256
            -kernel "${CMAKE_BINARY_DIR}/kernel.elf"
      DEPENDS kernel diskimg
    )
endif()
