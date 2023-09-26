#include "stdio.h"

int main()
{
  int fpu_available, mmx_available;

  


  asm (
    "movl $1, %%eax; cpuid; test $0x00000001, %%edx; jnz FPU; movl $0, %0; jmp done; FPU:; movl $2, %0; done:;"
    : "=m" (fpu_available)
    :
    : "%eax", "%edx"
  );

  asm (
    "movl $1, %%eax; cpuid; test $0x00800000, %%edx; jnz MMX; movl $0, %0; jmp done; MMX:; movl $2, %0;"
    : "=m" (mmx_available)
    :
    : "%eax", "%edx"
  );

  if (fpu_available == 0 && mmx_available == 0)
  {
    printf("Никто не доступен\n");
    return 1;
  }
  
  if (fpu_available == 2)
  {
    printf("FPU\n");
  }
  
  if (mmx_available == 2)
  {
    printf("MMX\n");
  }

  return 0;
}
