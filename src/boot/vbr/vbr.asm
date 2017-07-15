%include "vbr.inc"

bits 16 ; Running on real mode

section .text vstart=BASE_ADDRESS align=SECTION_ALIGNMENT ; Base address of the program in memory
                                                          ; using 0x0000:0x7C00 (CS:IP)
jmp near _start  ; Only 3 byte space, so cant force CS=0 here
OemName                 db "MSDOS5.0"       ; 8 bytes long
; BIOS Parameters Block
BytesPerSector          dw 0x0200
SectorsPerCluster       db 0x01
ReservedSectors         dw 0x02             ; From start of the volume
NumberOfFats            db 0x02
NumberOfRootEntries     dw 0x0200           
TotalSectors16          dw 0xE800           ; Non zero for volume_size < 32Mb
MediaDescriptor         db 0xF8             ; Non removable media
SectorsPerFat           dw 0xE7             
SectorsPerTrack         dw 0x3F             ; Ignored
NumberOfHeads           dw 0xFF             ; Ignored
HiddenSectors           dd VBR_SECTOR_INDEX ; LBA of beginning of the partition
TotalSectors32          dd 0x00             ; Number of sectors in the volume
                                            ; volume_size > 32Mb
; FAT16 extra information
DriveNumber             db 0x80
Reserved2               db 0x00            ; Should be zero
Signature               db 0x29
SerialNumber            dd 0x30303030
VolumeLabel             db "DolyOS Boot"   ; 11 bytes long (default: "NO NAME    ")
FileSystem              db "FAT16   "      ; 8 bytes long

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

; void __stdcall main(short drive_number)
_main:
    ; Setting stack frame
    push bp
    mov  bp, sp 

    hlt

times 510 - ($ - $$) db 0   ; Padding with zero

signature dw BOOTLOADER_SIGNATURE  ; Boot code magic signature

times 0x200 nop
