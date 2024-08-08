#ifdef __riscv64
# define LREG ld
# define SREG sd
# define REGBYTES 8
#else
# define LREG lw
# define SREG sw
# define REGBYTES 4
#endif

  .section .text.init, "ax"
  .global _start
  .extern freertos_risc_v_trap_handler
_start:
  la      t0, freertos_risc_v_trap_handler
  csrw    mtvec, t0

  la t0, __load_start_text
  la t1, __load_stop_text

  la t2, __tim_start
  la t3, __tim_end

copy_text:
  LREG t4,0(t0)
  SREG t4,0(t2)
  addi t0,t0,REGBYTES
  addi t2,t2,REGBYTES
  blt t0,t1,copy_text

  la sp, _stack

  call main
  tail exit