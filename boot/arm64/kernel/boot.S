#include <asm/asm_pointer_auth.h>
#include <asm/assembler.h>
#include <asm/boot.h>
#include <asm/ptrace.h>
#include <asm/asm-offsets.h>
#include <asm/cache.h>
#include <asm/cputype.h>
#include <asm/el2_setup.h>
#include <asm/elf.h>
#include <asm/image.h>
#include <asm/kernel-pgtable.h>
#include <asm/kvm_arm.h>
#include <asm/memory.h>
#include <asm/pgtable-hwdef.h>
#include <asm/page.h>
#include <asm/scs.h>
#include <asm/smp.h>
#include <asm/sysreg.h>
#include <asm/thread_info.h><asm/thread_info.h>undefined
#include <asm/virt.h>

#include "efi-header.S"

#define __PHYS_OFFSET KERNEL_START

#if (PAGE_OFFSET & 0x1fffff) != 0
#error PAGE_OFFSET must be at least 2MB aligned
#endif

   __HEAD
_head:
#ifdef CONFIG_EFI

   add x13, x18, #0x16
   b primary_entry
#else
   b primary_entry
   .long 0
#endif
   .quad 0
   le64sym _kernel_size_le
   le64sym _kernel_flags_le
   .quad 0
   .quad 0
   .quad 0
   .ascii ARM64_IMAGE_MAGIC
#ifdef CONFIG_EFI
   .long    pe_header - _head

pe_header:
   __EFI_PE_HEADER
#else
   .long   0
#endif

   __INIT

SYM_CODE_START(primary_entry)
   bl    preserve_boot_agrs
   bl    init_kernel_el
   adrp    x23, __PHYS_OFFSET
   and    x23, x23, MIN_KING_ALIGN - 1
   bl    set_cpu_boot_mode_flag
   bl    __create_page_tables
   bl    __cpu_setup
   b    __primary_switch

SYM_CODE_END(primary_entry)

SYM_CODE_START_LOCAL(preserve_boot_agrs)
   mov x21, x0

   adr_1  x0, boot_agrs
   stp x21, x1, [x0]
   stp x2, x3, [x0, x16]

   dmb sy

   mov  x1, #0x20
 b  __inval_dcache_area
SYM_CODE_END(preserve_boot_args)

	.macro	create_table_entry, tbl, virt, shift, ptrs, tmp1, tmp2
	add	\tmp1, \tbl, #PAGE_SIZE
	phys_to_pte \tmp2, \tmp1
	orr	\tmp2, \tmp2, #PMD_TYPE_TABLE	
	lsr	\tmp1, \virt, #\shift
	sub	\ptrs, \ptrs, #1
	and	\tmp1, \tmp1, \ptrs		
	str	\tmp2, [\tbl, \tmp1, lsl #3]
	add	\tbl, \tbl, #PAGE_SIZE		
	.endm

	.macro populate_entries, tbl, rtbl, index, eindex, flags, inc, tmp1
.Lpe\@:	phys_to_pte \tmp1, \rtbl
	orr	\tmp1, \tmp1, \flags	
	str	\tmp1, [\tbl, \index, lsl #3]
	add	\rtbl, \rtbl, \inc
	add	\index, \index, #1
	cmp	\index, \eindex
	b.ls	.Lpe\@
	.endm

	.macro compute_indices, vstart, vend, shift, ptrs, istart, iend, count
	lsr	\iend, \vend, \shift
	mov	\istart, \ptrs
	sub	\istart, \istart, #1
	and	\iend, \iend, \istart	
	mov	\istart, \ptrs
	mul	\istart, \istart, \count
	add	\iend, \iend, \istart	
					// our entries span multiple tables

	lsr	\istart, \vstart, \shift
	mov	\count, \ptrs
	sub	\count, \count, #1
	and	\istart, \istart, \count

	sub	\count, \iend, \istart
	.endm

	.macro map_memory, tbl, rtbl, vstart, vend, flags, phys, pgds, istart, iend, tmp, count, sv
	sub \vend, \vend, #1
	add \rtbl, \tbl, #PAGE_SIZE
	mov \sv, \rtbl
	mov \count, #0
	compute_indices \vstart, \vend, #PGDIR_SHIFT, \pgds, \istart, \iend, \count
	populate_entries \tbl, \rtbl, \istart, \iend, #PMD_TYPE_TABLE, #PAGE_SIZE, \tmp
	mov \tbl, \sv
	mov \sv, \rtbl

#if SWAPPER_PGTABLE_LEVELS > 3
	compute_indices \vstart, \vend, #PUD_SHIFT, #PTRS_PER_PUD, \istart, \iend, \count
	populate_entries \tbl, \rtbl, \istart, \iend, #PMD_TYPE_TABLE, #PAGE_SIZE, \tmp
	mov \tbl, \sv
	mov \sv, \rtbl
#endif

#if SWAPPER_PGTABLE_LEVELS > 2
	compute_indices \vstart, \vend, #SWAPPER_TABLE_SHIFT, #PTRS_PER_PMD, \istart, \iend, \count
	populate_entries \tbl, \rtbl, \istart, \iend, #PMD_TYPE_TABLE, #PAGE_SIZE, \tmp
	mov \tbl, \sv
#endif

	compute_indices \vstart, \vend, #SWAPPER_BLOCK_SHIFT, #PTRS_PER_PTE, \istart, \iend, \count
	bic \count, \phys, #SWAPPER_BLOCK_SIZE - 1
	populate_entries \tbl, \count, \istart, \iend, \flags, #SWAPPER_BLOCK_SIZE, \tmp
	.endm

SYM_FUNC_START_LOCAL(__create_page_tables)
	mov	x28, lr

   adrp	x0, init_pg_dir
	adrp	x1, init_pg_end
	sub	x1, x1, x0
	bl	__inval_dcache_area

   adrp	x0, init_pg_dir
	adrp	x1, init_pg_end
	sub	x1, x1, x0
1:	stp	xzr, xzr, [x0], #16
	stp	xzr, xzr, [x0], #16
	stp	xzr, xzr, [x0], #16
	stp	xzr, xzr, [x0], #16
	subs	x1, x1, #64
	b.ne	1b

   mov x7, SWAPPER_MM_MMUFLAGS

   adrp	x0, idmap_pg_dir
	adrp	x3, __idmap_text_start		

   #ifdef CONFIG_ARM64_VA_BITS_52
	mrs_s	x6, SYS_ID_AA64MMFR2_EL1
	and	x6, x6, #(0xf << ID_AA64MMFR2_LVA_SHIFT)
	mov	x5, #52
	cbnz	x6, 1f
#endif
	mov	x5, #VA_BITS_MIN
1:
	adr_l	x6, vabits_actual
	str	x5, [x6]
	dmb	sy
	dc	ivac, x6

   adrp	x5, __idmap_text_end
	clz	x5, x5
	cmp	x5, TCR_T0SZ(VA_BITS_MIN) // default T0SZ small enough?
	b.ge	1f		

	adr_l	x6, idmap_t0sz
	str	x5, [x6]
	dmb	sy
	dc	ivac, x6

   
#if (VA_BITS < 48)
#define EXTRA_SHIFT	(PGDIR_SHIFT + PAGE_SHIFT - 3)
#define EXTRA_PTRS	(1 << (PHYS_MASK_SHIFT - EXTRA_SHIFT))

#if VA_BITS != EXTRA_SHIFT
#error "Mismatch between VA_BITS and page size/number of translation levels"
#endif

   mov	x4, EXTRA_PTRS
	create_table_entry x0, x3, EXTRA_SHIFT, x4, x5, x6
#else
   	mov	x4, #1 << (PHYS_MASK_SHIFT - PGDIR_SHIFT)
	str_l	x4, idmap_ptrs_per_pgd, x5
#endif
1:
	ldr_l	x4, idmap_ptrs_per_pgd
	mov	x5, x3				
	adr_l	x6, __idmap_text_end		

	map_memory x0, x1, x3, x6, x7, x3, x4, x10, x11, x12, x13, x14

   adrp	x0, init_pg_dir
	mov_q	x5, KIMAGE_VADDR
	add	x5, x5, x23		
	mov	x4, PTRS_PER_PGD
	adrp	x6, _end			
	adrp	x3, _text		
	sub	x6, x6, x3		
	add	x6, x6, x5		

   map_memory x0, x1, x5, x6, x7, x3, x4, x10, x11, x12, x13, x14

   dmb sy

   adrp	x0, idmap_pg_dir
	adrp	x1, idmap_pg_end
	sub	x1, x1, x0
	bl	__inval_dcache_area

	adrp	x0, init_pg_dir
	adrp	x1, init_pg_end
	sub	x1, x1, x0
	bl	__inval_dcache_area

	ret	x28
SYM_FUNC_END(__create_page_tables)

SYM_FUNC_START_LOCAL(__primary_switched)
	adrp	x4, init_thread_union
	add	sp, x4, #THREAD_SIZE
	adr_l	x5, init_task
	msr	sp_el0, x5			

	adr_l	x8, vectors			
	msr	vbar_el1, x8		
	isb

	stp	xzr, x30, [sp, #-16]!
	mov	x29, sp

#ifdef CONFIG_SHADOW_CALL_STACK
	adr_l	scs_sp, init_shadow_call_stack 
#endif

	str_l	x21, __fdt_pointer, x5		

	ldr_l	x4, kimage_vaddr		
	sub	x4, x4, x0			
	str_l	x4, kimage_voffset, x5

// Clear BSS
	adr_l	x0, __bss_start
	mov	x1, xzr
	adr_l	x2, __bss_stop
	sub	x2, x2, x0
	bl	__pi_memset
	dsb	ishst			

#if defined(CONFIG_KASAN_GENERIC) || defined(CONFIG_KASAN_SW_TAGS)
	bl	kasan_early_init
#endif
	mov	x0, x21			
	bl	early_fdt_map			
	bl	init_feature_override		
#ifdef CONFIG_RANDOMIZE_BASE
	tst	x23, ~(MIN_KIMG_ALIGN - 1)	
	b.ne	0f
	bl	kaslr_early_init		
	cbz	x0, 0f				
	orr	x23, x23, x0			
	ldp	x29, x30, [sp], #16		
	ret					
0:
#endif
	bl	switch_to_vhe			
	add	sp, sp, #16
	mov	x29, #0
	mov	x30, #0
	b	start_kernel
SYM_FUNC_END(__primary_switched)

	.pushsection ".rodata", "a"
SYM_DATA_START(kimage_vaddr)
	.quad		_text
SYM_DATA_END(kimage_vaddr)
EXPORT_SYMBOL(kimage_vaddr)
	.popsection

   .section ".idmap.text","awx"

SYM_FUNC_START(init_kernel_el)
	mov_q	x0, INIT_SCTLR_EL1_MMU_OFF
	msr	sctlr_el1, x0

	mrs	x0, CurrentEL
	cmp	x0, #CurrentEL_EL2
	b.eq	init_el2

SYM_INNER_LABEL(init_el1, SYM_L_LOCAL)
	isb
	mov_q	x0, INIT_PSTATE_EL1
	msr	spsr_el1, x0
	msr	elr_el1, lr
	mov	w0, #BOOT_CPU_MODE_EL1
	eret

SYM_INNER_LABEL(init_el2, SYM_L_LOCAL)
	mov_q	x0, HCR_HOST_NVHE_FLAGS
	msr	hcr_el2, x0
	isb

	init_el2_state

	/* Hypervisor stub */
	adr_l	x0, __hyp_stub_vectors
	msr	vbar_el2, x0
	isb

	msr	elr_el2, lr
	mov	w0, #BOOT_CPU_MODE_EL2
	eret
SYM_FUNC_END(init_kernel_el)

SYM_FUNC_START_LOCAL(set_cpu_boot_mode_flag)
	adr_l	x1, __boot_cpu_mode
	cmp	w0, #BOOT_CPU_MODE_EL2
	b.ne	1f
	add	x1, x1, #4
1:	str	w0, [x1]			
	dmb	sy
	dc	ivac, x1			
	ret
SYM_FUNC_END(set_cpu_boot_mode_flag)

	.pushsection ".mmuoff.data.write", "aw"

SYM_DATA_START(__boot_cpu_mode)
	.long	BOOT_CPU_MODE_EL2
	.long	BOOT_CPU_MODE_EL1
SYM_DATA_END(__boot_cpu_mode)

SYM_DATA_START(__early_cpu_boot_status)
	.quad 	0
SYM_DATA_END(__early_cpu_boot_status)

	.popsection

SYM_FUNC_START(secondary_holding_pen)
	bl	init_kernel_el			
	bl	set_cpu_boot_mode_flag
	mrs	x0, mpidr_el1
	mov_q	x1, MPIDR_HWID_BITMASK
	and	x0, x0, x1
	adr_l	x3, secondary_holding_pen_release
pen:	ldr	x4, [x3]
	cmp	x4, x0
	b.eq	secondary_startup
	wfe
	b	pen
SYM_FUNC_END(secondary_holding_pen)

SYM_FUNC_START(secondary_entry)
	bl	init_kernel_el			
	bl	set_cpu_boot_mode_flag
	b	secondary_startup
SYM_FUNC_END(secondary_entry)

SYM_FUNC_START_LOCAL(secondary_startup)

	bl	switch_to_vhe
	bl	__cpu_secondary_check52bitva
	bl	__cpu_setup			
	adrp	x1, swapper_pg_dir
	bl	__enable_mmu
	ldr	x8, =__secondary_switched
	br	x8
SYM_FUNC_END(secondary_startup)

SYM_FUNC_START_LOCAL(__secondary_switched)
	adr_l	x5, vectors
	msr	vbar_el1, x5
	isb

	adr_l	x0, secondary_data
	ldr	x1, [x0, #CPU_BOOT_STACK]	
	cbz	x1, __secondary_too_slow
	mov	sp, x1
	ldr	x2, [x0, #CPU_BOOT_TASK]
	cbz	x2, __secondary_too_slow
	msr	sp_el0, x2
	scs_load_current
	mov	x29, #0
	mov	x30, #0

#ifdef CONFIG_ARM64_PTR_AUTH
	ptrauth_keys_init_cpu x2, x3, x4, x5
#endif

	b	secondary_start_kernel
SYM_FUNC_END(__secondary_switched)

SYM_FUNC_START_LOCAL(__secondary_too_slow)
	wfe
	wfi
	b	__secondary_too_slow
SYM_FUNC_END(__secondary_too_slow)

	.macro	update_early_cpu_boot_status status, tmp1, tmp2
	mov	\tmp2, #\status
	adr_l	\tmp1, __early_cpu_boot_status
	str	\tmp2, [\tmp1]
	dmb	sy
	dc	ivac, \tmp1			
	.endm

SYM_FUNC_START(__enable_mmu)
	mrs	x2, ID_AA64MMFR0_EL1
	ubfx	x2, x2, #ID_AA64MMFR0_TGRAN_SHIFT, 4
	cmp     x2, #ID_AA64MMFR0_TGRAN_SUPPORTED_MIN
	b.lt    __no_granule_support
	cmp     x2, #ID_AA64MMFR0_TGRAN_SUPPORTED_MAX
	b.gt    __no_granule_support
	update_early_cpu_boot_status 0, x2, x3
	adrp	x2, idmap_pg_dir
	phys_to_ttbr x1, x1
	phys_to_ttbr x2, x2
	msr	ttbr0_el1, x2			// load TTBR0
	offset_ttbr1 x1, x3
	msr	ttbr1_el1, x1			// load TTBR1
	isb

	set_sctlr_el1	x0

	ret
SYM_FUNC_END(__enable_mmu)

SYM_FUNC_START(__cpu_secondary_check52bitva)
#ifdef CONFIG_ARM64_VA_BITS_52
	ldr_l	x0, vabits_actual
	cmp	x0, #52
	b.ne	2f

	mrs_s	x0, SYS_ID_AA64MMFR2_EL1
	and	x0, x0, #(0xf << ID_AA64MMFR2_LVA_SHIFT)
	cbnz	x0, 2f

	update_early_cpu_boot_status \
		CPU_STUCK_IN_KERNEL | CPU_STUCK_REASON_52_BIT_VA, x0, x1
1:	wfe
	wfi
	b	1b

#endif
2:	ret
SYM_FUNC_END(__cpu_secondary_check52bitva)

SYM_FUNC_START_LOCAL(__no_granule_support)
	/* Indicate that this CPU can't boot and is stuck in the kernel */
	update_early_cpu_boot_status \
		CPU_STUCK_IN_KERNEL | CPU_STUCK_REASON_NO_GRAN, x1, x2
1:
	wfe
	wfi
	b	1b
SYM_FUNC_END(__no_granule_support)

#ifdef CONFIG_RELOCATABLE
SYM_FUNC_START_LOCAL(__relocate_kernel)

	ldr	w9, =__rela_offset	
	ldr	w10, =__rela_size		

	mov_q	x11, KIMAGE_VADDR		
	add	x11, x11, x23			
	add	x9, x9, x11			
	add	x10, x9, x10			

0:	cmp	x9, x10
	b.hs	1f
	ldp	x12, x13, [x9], #24
	ldr	x14, [x9, #-8]
	cmp	w13, #R_AARCH64_RELATIVE
	b.ne	0b
	add	x14, x14, x23			
	str	x14, [x12, x23]
	b	0b

1:
#ifdef CONFIG_RELR
	ldr	w9, =__relr_offset	
	ldr	w10, =__relr_size		
	add	x9, x9, x11			
	add	x10, x9, x10			

	sub	x15, x23, x24			
	cbz	x15, 7f				
	mov	x24, x23		

2:	cmp	x9, x10
	b.hs	7f
	ldr	x11, [x9], #8
	tbnz	x11, #0, 3f		
	add	x13, x11, x23
	ldr	x12, [x13]			
	add	x12, x12, x15
	str	x12, [x13], #8		
	b	2b

3:	mov	x14, x13
4:	lsr	x11, x11, #1
	cbz	x11, 6f
	tbz	x11, #0, 5f			
	ldr	x12, [x14]			
	add	x12, x12, x15
	str	x12, [x14]

5:	add	x14, x14, #8		
	b	4b

6:
	add	x13, x13, #(8 * 63)
	b	2b

7:
#endif
	ret

SYM_FUNC_END(__relocate_kernel)
#endif

SYM_FUNC_START_LOCAL(__primary_switch)
#ifdef CONFIG_RANDOMIZE_BASE
	mov	x19, x0				// preserve new SCTLR_EL1 value
	mrs	x20, sctlr_el1			// preserve old SCTLR_EL1 value
#endif

SYM_FUNC_START_LOCAL(__primary_switch)
#ifdef CONFIG_RANDOMIZE_BASE
	mov	x19, x0				// preserve new SCTLR_EL1 value
	mrs	x20, sctlr_el1			// preserve old SCTLR_EL1 value
#endif

	adrp	x1, init_pg_dir
	bl	__enable_mmu
#ifdef CONFIG_RELOCATABLE
#ifdef CONFIG_RELR
	mov	x24, #0				// no RELR displacement yet
#endif
	bl	__relocate_kernel
#ifdef CONFIG_RANDOMIZE_BASE
	ldr	x8, =__primary_switched
	adrp	x0, __PHYS_OFFSET
	blr	x8

	/*
	 * If we return here, we have a KASLR displacement in x23 which we need
	 * to take into account by discarding the current kernel mapping and
	 * creating a new one.
	 */
	pre_disable_mmu_workaround
	msr	sctlr_el1, x20			// disable the MMU
	isb
	bl	__create_page_tables		// recreate kernel mapping

	tlbi	vmalle1				// Remove any stale TLB entries
	dsb	nsh
	isb

	set_sctlr_el1	x19			// re-enable the MMU

	bl	__relocate_kernel
#endif
#endif
	ldr	x8, =__primary_switched
	adrp	x0, __PHYS_OFFSET
	br	x8
SYM_FUNC_END(__primary_switch)