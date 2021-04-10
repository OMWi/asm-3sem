.model small
.stack 100h

.data
    arrSize dw 0
    n dw 0
    errMsg db 10, 'Bad input$'
    sizeMsg db 10, 'Wrong size$'
    arr db 100 dup(?)
    tempArr db 100 dup(?)
.code

;read number by digits to bx(without backsp)
readNum proc
    push ax
    xor bx, bx
    startRead:
    mov ah, 1
    int 21h
    cmp al, ' '
    je endRead
    cmp al, 10
    je endRead
    cmp al, 13
    je endRead
    cmp al, '9'+1
    jnc wrongInput
    cmp al, '0'-1
    jc wrongInput
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
    pop ax
    ret
readNum endp

;print number(ax)    
printNum proc
    push ax
    push bx
    push cx
    push dx
    cmp ax, 32768
    jc notNeg
    neg ax
    push ax
    mov ah, 2
    push dx
    mov dl, '-'
    int 21h
    pop dx
    pop ax
    notNeg:
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
    pop dx
    pop cx
    pop bx
    pop ax
    ret
printNum endp


readArray proc
    call readNum
    cmp bx, 10
    ja wrongSize
    cmp bx, 0 
    je wrongSize
    mov n, bx
    mov ax, bx
    mul bl
    mov arrSize, ax
    xor si, si; si - elem index
    
    readElem:
    call readNum
    mov arr[si], bl
    inc si
    cmp si, arrSize
    jne readElem
    
    jmp endReadArr
    wrongSize:
    mov ah, 9
    mov dx, offset sizeMsg
    int 21h
    mov ah, 4ch
    int 21h
    endReadArr:
    ret
readArray endp

printArray proc
    mov ah, 2
    mov dl, 10
    int 21h
    xor si, si
    printString:
    mov cx, n
    printElem:
    xor ah, ah
    mov al, arr[si]
    call printNum
    mov ah, 2
    mov dl, ' '
    int 21h
    inc si
    loop printElem
    mov ah, 2
    mov dl, 10
    int 21h
    cmp si, arrSize
    jne printString
    ret
printArray endp

rotateArray proc
    push ax
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, n
    copyString:
    xor cl, cl; cl - col ind
    copyElem:
    xor ah, ah
    mov al, bl
    mul cl
    add al, ch
    mov di, ax
    mov al, bl
    mul ch
    add al, cl
    mov si, ax
    mov bh, arr[si]
    mov tempArr[di], bh
    inc cl
    cmp cl, bl
    jne copyElem
    inc ch; ch - str ind
    cmp ch, bl
    jne copyString
    
    xor cx, cx
    xor si, si
    xor ah, ah
    ;cl - str ind   
    shakeString:
    mov al, cl
    mul bl
    mov si, ax
    mov di, si
    add di, n
    dec di
    swapCols:
    mov dh, tempArr[di]
    mov dl, tempArr[si]
    mov arr[si], dh
    mov arr[di], dl
    inc si
    dec di
    cmp si, di
    jle swapCols
    inc cl
    cmp cl, bl
    jne shakeString
    pop dx
    pop cx
    pop bx
    pop ax
    ret
rotateArray endp

main proc
    mov ax, @data
    mov ds, ax
    
    
    call readArray
    call rotateArray
    call printArray
    
    mov ah, 4ch
    int 21h
main endp
end main