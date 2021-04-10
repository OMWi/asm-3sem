.model tiny
.code
.186
org 100h
start proc near
    mov ax, 3509h
    int 21h
    mov word ptr oldHandler, bx
    mov word ptr oldHandler+2,es
    mov ax, 2509h
    mov dx, offset newHandler
    int 21h
    mov cx, 0
    cycle:
    mov ah, 2
    int 21h
    loop cycle
    
    ret
    
oldHandler dd ?
start endp

newHandler proc far
    pushf
    pusha
    push es
    push ds
    push cs
    pop ds
    call dword ptr cs:oldHandler
    push ax
    mov ah,2 
    push dx
    mov dl, 1
    int 21h
    pop dx
    pop ax
    
    
    
    iret
newHandler endp
end start