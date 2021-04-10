.model small
.stack 100h
.data
    a dw 0
    b dw 0
    c dw 0
    d dw 0
.code  

main proc
    mov ax,@data
    mov ds,ax
    ;<readABCD>
    
    mov ax, a
    add ax, b
    xor ax, c 
    cmp ax, d
    je i1
    mov ax, d
    and ax, c
    add ax, b
    ;<print>
    jmp stop
    
    i1:
    mov ax, d
    sub ax, b
    mov bx, a
    sub bx, c
    cmp ax, bx
    je i2
    mov ax, b
    add ax, c
    add ax, d
    ;<print>
    jmp stop
    i2:
    mov ax, a
    add ax, b
    add ax, c
    ;<print>
    stop:
    mov ah,4ch
    int 21h
main endp
end main