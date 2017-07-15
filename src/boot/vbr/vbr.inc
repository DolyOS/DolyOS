%define END_STRING 13, 10, 0

; Constants declarations
BOOTLOADER_SIGNATURE    equ         0xAA55
BASE_ADDRESS            equ         0x7C00
SECTION_ALIGNMENT       equ         0x01
VBR_SECTOR_INDEX        equ         0x80

struc DiskAddressPacket
    .size           resb 1
    .resv           resb 1
    .num_of_sectors resb 2
    .offset         resb 2
    .segment        resb 2
    .lba_start      resb 8
endstruc
%define DAP(obj, member) [obj + DiskAddressPacket. %+ member]
