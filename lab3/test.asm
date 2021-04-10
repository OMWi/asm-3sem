.model small
.stack 100h

.data
    a dw 0
    b dw 0
    isNegative db 0
    errMsg db 10, 'Bad input$'
.code

;read number by digits(bx)
readNum proc
    xor bx, bx
    startRead:
    mov ah, 1
    int 21h
    cmp al, '-'
    jne notNeg
    cmp isNegative, 1
    je wrongInput
    mov isNegative, 1
    jmp startRead
    notNeg:
    cmp al, 13
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
    cmp isNegative, 1
    jne final
    neg bx
    mov isNegative, 0
    final:
    ret
readNum endp

;print number(ax)    
printNum proc
    cmp ax, 32768
    jc notNeg1
    mov isNegative, 1
    neg ax
    notNeg1:
    push ax
    mov ah, 2
    mov dl, 13
    int 21h 
    cmp isNegative, 1
    jne notNeg2
    mov dl, '-'
    int 21h
    mov isNegative, 0
    notNeg2:    
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
    mov ax, a
    add ax, b
    call printNum

    mov ah, 4ch
    int 21h
main endp
end main