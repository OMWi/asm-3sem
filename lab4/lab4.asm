.model small
.stack 100h

.data
    T db, 0
    string db 101 dup (?)
    errMsg db 10, 'Bad input$'
    len db, 0
    
.code

readString proc
    push ax
    mov si, offset string 
    readStart:
    mov ah, 1
    int 21h
    cmp al, 10
    je readEnd
    cmp al, 13
    je readEnd
    cmp al, 'a' - 1
    jc wrongInput
    cmp al, 'z' + 1
    jnc wrongInput
    mov [si], al
    inc si
    inc len
    cmp len, 101
    je wrongInput
    jmp readStart
    
    wrongInput:
    mov ah, 9
    mov dx, offset errMsg
    int 21h
    mov ah, 4ch
    int 21h
    readEnd:
    cmp len, 0
    je wrongInput
    mov byte ptr [si], '$'    
    pop ax
    ret
readString endp

getStringPeriod proc
    push ax
    push bx
    push dx
    
    mov dl, 1; dl - period
    findingT:
    cmp dl, len
    je foundT
    
    xor ah, ah
    mov al, len
    div dl
    cmp ah, 0
    jne incT
    
    xor al, al; al - current pos
    checkCPs:
    mov ah, al; ah - next pos
    add ah, dl
    checkCP:
    
    mov si, offset string
    xor cl, cl
    char1:
    cmp al, cl
    je char1end
    inc cl
    inc si
    jmp char1
    char1end:
    mov bl, [si]
    mov si, offset string
    xor cl, cl
    char2:
    cmp ah, cl
    je char2end
    inc cl
    inc si
    jmp char2
    char2end:
    mov bh, [si]
    
    cmp bl, bh
    jne incT
    add ah, dl
    cmp ah, len
    jae incCP
    jmp checkCP
    incCP:
    inc al
    cmp al, dl
    je foundT
    
    jmp checkCPs
    
    incT:
    inc dl
    jmp findingT
    foundT:
    mov T, dl
    pop dx
    pop bx
    pop ax
    ret
getStringPeriod endp

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
    
    call readString
    
    call getStringPeriod
    xor ah, ah
    mov al, T
    call printNum
    
    
    mov ah, 4ch
    int 21h
main endp
end main