%define END_STRING 13, 10, 0

; Constants declarations
BOOTLOADER_SIGNATURE    equ         0xAA55
BASE_ADDRESS            equ         0x7C00
NEW_ADDRESS             equ         0x0600
SECTION_ALIGNMENT       equ         0x01
PARTITION_TABLE_OFFSET  equ         0x01BE
BOOT_FLAG               equ         0x80

struc PartitionEntry
    .boot_flag      resb 1
    .starting_chs   resb 3
    .system_id      resb 1
    .ending_chs     resb 3
    .starting_lba   resb 4
    .num_of_sectors resb 4
endstruc
%define PE(obj, member) [obj + PartitionEntry. %+ member]

struc DiskAddressPacket
    .size           resb 1
    .resv           resb 1
    .num_of_sectors resb 2
    .offset         resb 2
    .segment        resb 2
    .lba_start      resb 8
endstruc
%define DAP(obj, member) [obj + DiskAddressPacket. %+ member]
