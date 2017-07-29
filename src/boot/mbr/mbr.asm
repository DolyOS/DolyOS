%include "mbr.inc"

bits 16  ; Running on real mode

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
    mov ss, ax
    mov sp, BASE_ADDRESS

    sti  ; Restore interrupts

    ; Relocate the .text section
    push TEXT_SECTION_SIZE                 ; Size in bytes
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

section .text vstart=NEW_ADDRESS align=SECTION_ALIGNMENT follows=.init
; void __stdcall main(short drive_number)
_main:
    ; Setting stack frame
    push bp
    mov  bp, sp 

    push PARTITION_TABLE
    call _find_bootable_partition
    cmp  ax, ~0  ; Check if failed to find bootable partition
    je   .error
    mov  si, ax  ; Save the adress of the bootable partition
                 ; Also needs to set ds:si because the standard says so

    ; ; Check for extended read
    ; push word [bp + 0x04]  ; drive_number
    ; call _check_extended_read

    push word [bp + 0x04]  ; drive_number
    push si  ; Pointer to bootable partition
    call _load_vbr
    and  ax, ax
    jz   .error  ; Check if failed to load VBR
    
    mov dx, word [bp + 0x04]  ; drive_number
                              ; Need to set dl to drive number because the standard says so
    jmp 0x0000:BASE_ADDRESS   ; Jump to VBR, make sure CS = 0, IP = 0x7c00

 .error:
    int 0x18

; void * __stdcall _find_bootable_partition(void *partition_table)
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

; bool __stdcall _load_vbr(void *partition, short drive_number)
_load_vbr:
    ; Setting stack frame
    push bp
    mov  bp, sp 

    ; Reset disk drive 
 .reset:
    mov dx, word [bp + 0x06]  ; driver_number
    xor ax, ax
    int 0x13
    jc  _epilogue

    ; Read VBR sector form the disk
    mov ax, 0x0201  ; ah = read function, al = 1 sector
    mov bx, [bp + 0x04]  ; partition
    mov dx, word [bp + 0x06]  ; driver_number
    mov dh, PE(bx, starting_chs)  ; Head
    mov cl, PE(bx, starting_chs + 1)  ; Sector
    mov ch, PE(bx, starting_chs + 2)  ; Cylinder
    mov bx, BASE_ADDRESS  ; Address to load the sector into
    int 0x13
    jc  _epilogue

    mov bx, word [BASE_ADDRESS + BOOT_SIG_OFFSET]
    cmp bx, BOOTLOADER_SIGNATURE
    jz  _epilogue  ; Check the boot signature
    stc  ; Set carry to signal failure
    
_epilogue:
    setnc al  ; ax = True if succeeded

    ; Clear stack frame
    mov  sp, bp
    pop  bp
    ret  0x04


times PARTITION_TABLE_OFFSET - INIT_SECTION_SIZE - ($ - $$) nop  ; Padding

PARTITION_TABLE: 
    times PartitionEntry_size * 4 db 0x00
    ; istruc PartitionEntry 
    ; iend
    ; istruc PartitionEntry 
    ; iend
    ; istruc PartitionEntry 
    ; iend
    ; istruc PartitionEntry 
    ; iend

signature dw BOOTLOADER_SIGNATURE  ; Boot code magic signature

TEXT_SECTION_SIZE       equ         ($ - _main)
