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
    push MAIN_SECTION_SIZE                 ; Size in bytes
    push BASE_ADDRESS + INIT_SECTION_SIZE  ; Source address
    push NEW_ADDRESS                       ; Destination address
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
    cmp  ax, ~0  ; Check if failed to find bootable partition
    je   .error

    ; Check for extended read
    push word [bp + 0x04]  ; drive_number
    call _check_extended_read

    push word [bp + 0x04]
    push parti1
    call _normal_read
    hlt
    
 .error:
    int 0x18

; void *__stdcall _find_bootable_partition(void *partition_table)
_find_bootable_partition:
    ; Setting stack frame
    push bp
    mov  bp, sp 

    push si  ; Save si register

    mov si, [bp + 0x04]  ; si = first partition_entry
    mov ax, ~0
    
 .loop:  ; Search for bootable partition
    cmp word [si], BOOTLOADER_SIGNATURE
    je  .not_found  ; Quit loop if boot signature encounterd

    test byte PE(si, boot_flag), BOOT_FLAG  ; Check if bootable partition
    jnz  .found

    add  si, PartitionEntry_size
    jmp .loop
 .found:
    mov ax, si
 .not_found:
    pop si  ; Restore si register

    ; Clear stack frame
    mov  sp, bp
    pop  bp
    ret  0x02

; bool __stdcall _check_extended_read(short drive_number)
_check_extended_read:
    ; Setting stack frame
    push bp
    mov  bp, sp

    ; Call the interrupt to check extention 
    mov ax, 0x4100
    mov dx, word [bp + 0x04]
    mov bx, 0x55AA
    int 0x13

    xor  ax, ax  ; Lets assume there isn't extended read
    jc   .skip
    cmp  bx, BOOTLOADER_SIGNATURE
    jne  .skip
    test cx, 0x01
    jz   .skip
    mov  ax, 0x01  ; There is extended read

 .skip:
    ; Clear stack frame
    mov  sp, bp
    pop  bp
    ret 0x02

; bool __stdcall _normal_read(void *partition, short drive_number)
_normal_read:
    ; Setting stack frame
    push bp
    mov  bp, sp 

    mov bx, [bp + 0x04]  ; partition

    ; Reset disk drive 
    mov dx, [bp + 0x06]
    xor ax, ax
    int 0x13

    ; 
    mov ax, 0x0201  ; ah = read function, al = 1 sector
    mov dh, PE(bx, starting_chs)  ; Head
    mov cl, PE(bx, starting_chs + 1)  ; sector
    mov ch, PE(bx, starting_chs + 2)  ; cylinder
    mov bx, BASE_ADDRESS  ; Address to load the sector into
    int 0x13
    
    ; setc  

    ; Clear stack frame
    mov  sp, bp
    pop  bp
    ret  0x04

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

times PARTITION_TABLE_OFFSET - INIT_SECTION_SIZE - ($ - $$) db 0x30  ; Padding with zero
parti1 istruc PartitionEntry
    at PartitionEntry.boot_flag,      db 0x80
    at PartitionEntry.starting_chs,    db 0x02, 0x03, 0x00 
iend
istruc PartitionEntry 
iend
istruc PartitionEntry 
iend
istruc PartitionEntry 
iend

signature dw BOOTLOADER_SIGNATURE  ; Boot code magic signature

MAIN_SECTION_SIZE       equ         ($ - _main)