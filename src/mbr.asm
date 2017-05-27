%include "mbr.inc"

bits 16

section .init vstart=BASE_ADDRESS align=SECTION_ALIGNMENT
_start:
    jmp 0x0000:_init  ; Make sure that CS = 0
    
_init:
    cli  ; Cancel interrupts

    ; Set up segments registers
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; Set up stack
    mov ax, 0x07C0
    mov ss, ax
    xor sp, sp

    ; Relocate the .MAIN section
    push MAIN_SECTION_SIZE                ; Size in bytes
    push BASE_ADDRESS                     ; Source address
    push NEW_ADDRESS - INIT_SECTION_SIZE  ; Destination address
    call _memcpy

    push dx     ; Drive number
    call _main  ; This function does not return

; void __stdcall memcpy(void *dest, void *src, size_t size);
_memcpy:
    ; Setting stack frame
    push bp
    mov  bp, sp 

    pusha  ; Save all registers

    cld                    ; Clear direction flag (increase si)
    mov   di, [bp + 0x04]  ; Destination address
    mov   si, [bp + 0x06]  ; Source address 
    mov   cx, [bp + 0x08]  ; Count of dwords of program
    repnz movsb            ; Copy the memory

    popa  ; Restore all registers

    ; Clear stack frame
    mov  sp, bp
    pop  bp
    ret  0x06

INIT_SECTION_SIZE       equ         ($ - _start)

section .main vstart=NEW_ADDRESS align=SECTION_ALIGNMENT
; void __stdcall main(short drive_number)
_main:
    ; Setting stack frame
    push bp
    mov  bp, sp 

    push parti1
    call _find_bootable_partition

    push t
    call _print_string

    hlt
    
; void __stdcall _print_string(void *str)
_print_string:
    ; Setting stack frame
    push bp
    mov  bp, sp 

    pusha  ; Save all registers

    mov ax, 0x0E00 ; Print char function of int 0x10
    cld            ; Clear direction flag (increase si) 
    mov si, [bp + 0x04]

 .loop:
    lodsb           ; load first char to al
    test  al, al    ; Will set zero flag if zero
    jz    .loop_out ; Break loop if NULL char

    int 0x10      ; Print the char to the screen
    jmp .loop     ; Loop as long the char isn't NULL
 .loop_out:

    popa  ; Restore all registers

    ; Clear stack frame
    mov  sp, bp
    pop  bp
    ret  0x02

; short __stdcall _find_bootalbe_partition(void *partition_table)
_find_bootalbe_partition:
    ; Setting stack frame
    push bp
    mov  bp, sp 

    pusha  ; Save all registers

    mov si, [bp + 0x04]  ; si = first partition_entry

 .loop: ; Search for bootable partition
    cmp word [si], BOOTLOADER_SIGNATURE
    je  .not_found ; Quit loop if boot signature encounterd

    test byte PE(si, boot_flag), BOOT_FLAG ; Check if bootable partition
    jz   .not_bootable

    ; Bootable partition was found
    ret

 .not_bootable: ; Continue to next partition entry
    add si, PartitionEntry_size
    jmp .loop

 .not_found: ; Reached the end of partition table
    mov  si, AdjustAddress(parti_error)
    call PrintString
    int  0x18

t: db "TEST", END_STRING
times PARTITION_TABLE_OFFSET - INIT_SECTION_SIZE - ($ - $$) db 0x30  ; Padding with zero
parti1 istruc PartitionEntry 
iend
istruc PartitionEntry 
iend
istruc PartitionEntry 
iend
istruc PartitionEntry 
iend

signature dw BOOTLOADER_SIGNATURE  ; Boot code magic signature

MAIN_SECTION_SIZE       equ         ($ - _main)