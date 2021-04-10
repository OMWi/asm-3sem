.model small
.stack 100h
.data
    a dw 0
    b dw 0
    c dw 0
    d dw 0
    errMsg db 10, 'Bad input$'
.code

;read number by digits
readNum proc
    xor bx, bx
    startRead:
    mov ah, 1
    int 21h
    cmp al, 10
    je endRead
    cmp al, 8
    jne notBackSpace
    mov dl, ' '
    mov ah, 2
    int 21h
    mov dl, 8
    int 21h
    mov ax, bx
    mov bx, 10
    xor dx, dx
    div bx
    mov bx, ax
    jmp startRead
    notBackSpace:
    cmp al, '9'+1
    jnc wrongInput
    cmp al, '0'-1
    jc wrongInput
    ;adding digit
    push ax
    xor ax, ax
    mov al, 10
    mul bx
    mov bx, ax
    pop ax
    xor ah, ah
    sub al, '0'
    add bx, ax    
    jmp startRead
    wrongInput:
    mov ah, 9
    mov dx, offset errMsg
    int 21h
    mov ah, 4ch
    int 21h
    
    endRead:
    ret
readNum endp
;print 1 symb(DL)
printCh proc
    push ax
    mov ah, 2
    int 21h
    pop ax
    ret
printCh endp
;print number    
printNum proc
    push ax
    mov ah, 2
    mov dl, 13
    int 21h
    pop ax   
    xor cx, cx
    mov bx, 10
    toStack:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    je print
    jmp toStack
    print:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop print
    ret
printNum endp

main proc
    mov ax, @data
    mov ds, ax
    
    call readNum
    mov a, bx
    call readNum
    mov b, bx
    call readNum
    mov c, bx
    call readNum
    mov d, bx
    mov ah, 2
    mov dl, 13
    int 21h
    
    mov ax, b
    add ax, a
    mov bx, d
    add bx, c
    cmp ax, bx
    jne mark1
    mov ax, a
    xor ax, b
    mov bx, c
    and bx, d
    add ax, bx
    call printNum
    jmp stop
    mark1:
    mov ax, a
    or ax, b
    mov bx, c
    and bx, d
    cmp ax, bx
    jne mark2
    mov ax, a
    add ax, b
    mov bx, c
    xor bx, d
    and ax, bx
    call printNum
    jmp stop
    mark2:
    mov ax, a
    add ax, d
    mov bx, b
    add bx, c
    or ax, bx
    call printNum
    stop:
    mov ah, 4ch
    int 21h
main endp
end main
