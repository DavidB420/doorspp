.section init //Init section for ELF binaries

.option norvc //Stops GAS from doing some instruction compression

.type start,@function //Start of function
.global start //For the linker
start:
.cfi_startproc //Initializes some internal data structures
.option push //Push current options
.option norelax //Disable linker relaxation (not a big fan of this)
    la gp, global_pointer
 
	/* Reset satp */
	csrw satp, zero
 
	/* Setup stack */
	la sp, stack_top
 
	/* Clear the BSS section */
	la t5, bss_start
	la t6, bss_end
bss_clear:
	sd zero, (t5)
	addi t5, t5, 8
	bgeu t5, t6, bss_clear
 
	la t0, kmain
	csrw mepc, t0
 
	.cfi_endproc //Disables
 
.end