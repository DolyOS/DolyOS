; Used for debugging
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