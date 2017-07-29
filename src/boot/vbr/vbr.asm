%include "vbr.inc"

bits 16 ; Running on real mode

section .text vstart=BASE_ADDRESS align=SECTION_ALIGNMENT ; Base address of the program in memory
                                                          ; using 0x0000:0x7C00 (CS:IP)
_start:
    jmp 0x0000:_init  ; Make sure that CS = 0

_init:
    cli  ; Cancel interrupts

    ; Set up segments registers
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; Set up stack
    mov ss, ax
    mov sp, BASE_ADDRESS
    
    sti  ; Restore interrupts

    push dx     ; Drive number
    call _main  ; This function does not return

; void __stdcall main(short drive_number, )
_main:
    ; Setting stack frame
    push bp
    mov  bp, sp 

    hlt

times BOOT_SIG_OFFSET - ($ - $$) db 0   ; Padding with zero

signature dw BOOTLOADER_SIGNATURE  ; Boot code magic signature

times 0x400 - ($ - $$) nop
