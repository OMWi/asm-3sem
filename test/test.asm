.model small
.stack 100h

.data
    a dw 0
    b dw 0
    c dw 0
    d dw 0
    isNegative db 0
    errMsg db 10, 'Bad input$'
    zeroMsg db 10, 'Zero division$'
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
    cmp isNegative, 1
    jne finalRead
    neg bx
    mov isNegative, 0
    finalRead:
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

divide proc  ;in ax/bx out ax, dx
    cmp bx, 0
    jne notZero
    mov ah, 9h
    mov dx, offset zeroMsg
    int 21h
    mov ah, 4ch
    int 21h
    notZero:
    cmp ax, 32768    
    jc axPositive
    inc isNegative
    neg ax
    axPositive:
    cmp bx, 32768
    jc bxPositive
    inc isNegative
    neg bx
    bxPositive:
    div bx
    cmp isNegative, 1
    jne notNegative
    neg ax
    notNegative:
    mov isNegative, 0
    ret
divide endp
    
mult proc; in ax, bx out ax
    push dx
    cmp ax, 32768    
    jc axPositive2
    inc isNegative
    neg ax
    axPositive2:
    cmp bx, 32768
    jc bxPositive2
    inc isNegative
    neg bx
    bxPositive2:
    mul bx
    cmp isNegative, 1
    jne notNegative2
    neg ax
    notNegative2:
    mov isNegative, 0
    pop dx
    ret
mult endp  


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
    
    mov ax, a
    add ax, b
    mov bx, d
    sub bx, c
    cmp ax, bx
    jne els1
    ;print (a*b+c/d)
    mov ax, a
    mov bx, b
    call mult
    mov cx, ax
    mov ax, c
    mov bx, d
    call divide
    add ax, cx
    call printNum
    
    jmp finalMain
    els1:
    mov ax, a
    mov bx, b
    call divide
    mov ax, dx
    mov bx, c
    add bx, d
    cmp ax, bx
    jne els2
    ;print (b+a)/(c%d)
    mov ax, c
    mov bx, d
    call divide
    mov bx, dx
    mov ax, a
    add ax, b
    call divide
    call printNum
    jmp finalMain
    els2:
    ;print (a+d-(b+c))
    mov ax, a
    add ax, d
    mov bx, b
    add bx, c
    sub ax, bx
    call printNum
    
    
    
    
    
    finalMain:
    mov ah, 4ch
    int 21h
main endp
end main