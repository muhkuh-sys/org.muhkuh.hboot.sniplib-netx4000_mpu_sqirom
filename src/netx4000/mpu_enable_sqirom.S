#include "netx_io_areas.S"
#include "cr7.S"

	.section .init_code, "ax"
	.arm 

	.global start

  .func start
start:
	stmfd   sp!, {r0, r1, r2, r3, lr}

@ =====================================================================
@ Disable MPU 
@ =====================================================================
	/* Read the system control register. */
	mrc     p15, 0, r0, c1, c0, 0

	/* Disable all stuff. */
	bic     r0, r0, #MSK_CR7_CP15_SCTRL_M
	bic     r0, r0, #MSK_CR7_CP15_SCTRL_C
	bic     r0, r0, #MSK_CR7_CP15_SCTRL_Z
	bic     r0, r0, #MSK_CR7_CP15_SCTRL_I
	bic     r0, r0, #MSK_CR7_CP15_SCTRL_V
	bic     r0, r0, #MSK_CR7_CP15_SCTRL_EE

	/* Ensure all previous loads/stores have completed */
	dsb

	mcr     p15, 0, r0, c1, c0, 0
	
	/* Ensure subsequent insts execute wrt new MPU settings. */
	isb

	@ Invalidate the complete branch predictor array.
	mcr     p15, 0, r1, c7, c5, 6
	
	
@ =====================================================================
@ Re-configure MPU
@ =====================================================================

	// region  0: this is the base region. It is device type to ensure that all accesses are ordered by default.
	MACRO_MPU_REGION  0, 1, 0x00000000, "ffffffff", MPU_MT_Device_NonShareable,          MPU_AP_RW_RW
	
	// region  1: ROM POR, ITCM and DTCM mirror.
	MACRO_MPU_REGION  1, 1, HOSTADDR(CR7_ITCM), "0003ffff", MPU_MT_Normal_Buffered_NonShareable, MPU_AP_RW_RW
	
	// region  2: LLRAM
	MACRO_MPU_REGION  2, 1, HOSTADDR(CR7_llram), "03ffffff", MPU_MT_Normal_Buffered_NonShareable, MPU_AP_RW_RW
	
	// region  3: ROM
	MACRO_MPU_REGION  3, 1, HOSTADDR(CR7_rom), "0001ffff", MPU_MT_Normal_Buffered_NonShareable, MPU_AP_RO_RO  
	
	// region  4: SQIROM0 and SQIROM1
	MACRO_MPU_REGION  4, 1, HOSTADDR(NX2RAP_SQIROM0), "07ffffff", MPU_MT_Normal_Buffered_NonShareable, MPU_AP_RO_RO 
 
	// region  5: HIF SDRAM and EXT SDRAM
	MACRO_MPU_REGION  5, 1, HOSTADDR(hif_sdram), "1fffffff", MPU_MT_Normal_Buffered_NonShareable, MPU_AP_RW_RW
	
	// region  6: DDR Lo
	MACRO_MPU_REGION  6, 1, HOSTADDR(NX2RAP_ddr_lo), "3fffffff", MPU_MT_Normal_Buffered_NonShareable, MPU_AP_RW_RW
	
	// region  7: DDR Hi
	MACRO_MPU_REGION  7, 1, HOSTADDR(NX2RAP_ddr_hi), "3fffffff", MPU_MT_Normal_Buffered_NonShareable, MPU_AP_RW_RW
	
	// region  8: off
	MACRO_MPU_REGION  8, 0, 0,                             0,    0,                                   0
	
	// region  9: off
	MACRO_MPU_REGION  9, 0, 0,                             0,    0,                                   0
	
	// region 10: off
	MACRO_MPU_REGION 10, 0, 0,                             0,    0,                                   0
	
	// region 11: off
	MACRO_MPU_REGION 11, 0, 0,                             0,    0,                                   0
	
	// region 12: off
	MACRO_MPU_REGION 12, 0, 0,                             0,    0,                                   0
	
	// region 13: off
	MACRO_MPU_REGION 13, 0, 0,                             0,    0,                                   0
	
	// region 14: off
	MACRO_MPU_REGION 14, 0, 0,                             0,    0,                                   0
	
	// region 15: off
	MACRO_MPU_REGION 15, 0, 0,                             0,    0,                                   0
	 

@ =====================================================================
@ Enable the MPU.
@ =====================================================================
	/* Enable the MPU and branch prediction.
	 * NOTE: enable I and D caches later.
	 */
	mrc     p15, 0, r0, c1, c0, 0
	orr     r0, r0, #MSK_CR7_CP15_SCTRL_M
	orr     r0, r0, #MSK_CR7_CP15_SCTRL_Z

	/* Ensure all previous loads/stores have completed */
	dsb

	mcr     p15, 0, r0, c1, c0, 0
	isb  

   /* return into ROM loader and proceed with chunk processing*/
	ldmfd   sp!, {r0, r1, r2, r3, lr}
	bx      lr

  .endfunc
  .end
 