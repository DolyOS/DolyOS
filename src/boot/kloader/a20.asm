bits 16

section .text16
; bool __stdcall check_a20(void)
_check_a20:
    hlt

; bool __stdcall enable_a20(void)
_enable_a20:
    hlt
