.model small
.stack 100h
.data
    shift db 0
    oldHandler dw ?, ?
    flagExit db 0
    scanTableLetters db 30, 48, 46, 32, 18, 33, 34, 35, 23, 36, 37, 38, 50, 49, 24, 25, 16, 19, 31, 20, 22, 47, 17, 45, 21, 44
    scanTableDigits db 11, 2, 3, 4, 5, 6, 7, 8, 9, 10
    escScanCode db 1
    lShiftScanCode db 42
    rShiftScanCode db 54
    lShiftScanCodeRelease db 170
    rShiftScanCodeRelease db 182
    shiftIsPressed db 0
    backspaceScanCode db 14
    errMsg db 10, 'Bad input$'
.code

readNum proc
    xor bx, bx
    startRead:
    mov ah, 1
    int 21h
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
    ret
readNum endp

shiftAL proc
    push bx cx dx
    xor cx, cx
    
    cmp al, 'a'
    jl @@NotSmall
    cmp al, 'z'
    ja @@NotSmall
    mov bl, 'a'
    sub al, 'a'
    mov cx, 26
@@NotSmall:
    cmp al, 'A'
    jl @@NotBig
    cmp al, 'Z'
    ja @@NotBig
    mov bl, 'A'
    sub al, 'A'
    mov cx, 26
@@NotBig:
    
    cmp al, '0'
    jl @@NotNumber
    cmp al, '9'
    ja @@NotNumber
    mov bl, '0'
    sub al, '0'
    mov cx, 10
@@NotNumber:
    
    cmp cx, 0
    je @@FinalShift
    xor ah, ah
    xor dx, dx
    add al, shift
    div cx
    mov al, dl
    add al, bl
@@FinalShift:
    pop dx cx bx
    ret
shiftAL endp

PrintCharDL proc
    push ax
    mov ah, 2
    int 21h
    pop ax
    ret
PrintCharDL endp

ScanCodeALToAsciiAX proc
    push bx cx dx di
    push es ds
    pop es
    cmp al, lShiftScanCode
    je @@ShiftPressed
    cmp al, rShiftScanCode
    je @@ShiftPressed
    jmp @@ShiftNotPressed1
@@ShiftPressed:
    mov shiftIsPressed, 1
@@ShiftNotPressed1:
    cmp al, lShiftScanCodeRelease
    je @@ShiftReleased
    cmp al, rShiftScanCodeRelease
    je @@ShiftReleased
    jmp @@ShiftNotReleased
@@ShiftReleased:
    mov shiftIsPressed, 0
@@ShiftNotReleased:
    mov cx, 27
    lea di, scanTableLetters
    repne scasb
    dec si
    sub di, offset scanTableLetters
    cmp di, 26
    jl LetterFound
    
    mov cx, 11
    lea di, scanTableDigits
    repne scasb
    dec di
    sub di, offset scanTableDigits
    cmp di, 10
    jl DigitFound
    
    mov al, 0
    jmp ExitProc
LetterFound:
    mov ax, di
    cmp shiftIsPressed, 1
    jne @@ShiftNotPressed2
    add al, 'A'
    jmp ExitProc
    
@@ShiftNotPressed2:
    add al, 'a'
    jmp ExitProc
DigitFound:
    mov ax, di
    add al, '0'
ExitProc:
    pop es
    pop di dx cx bx
    ret
ScanCodeALToAsciiAX endp

newHandler proc
    push ax bx cx dx es ds si di
    cli
    xor ah, ah
    in al, 60h
    
    cmp al, escScanCode
    jne @@NotEsc
    or flagExit, 1
    jmp @@FinalHandler
    
@@NotEsc:
    cmp al, backspaceScanCode
    jne @@NotBackspace
    mov dl, 8
    call PrintCharDL
    mov dl, 32
    call PrintCharDL
    mov dl, 8
    call PrintCharDL
    jmp @@FinalHandler
    
@@NotBackspace:
    call ScanCodeALToAsciiAX
    cmp al, 0
    je @@FinalHandler
    call shiftAL
    mov dl, al
    call PrintCharDL
    
@@FinalHandler:
    mov al, 100000b;
    out 100000b, al
    pop di si ds es dx cx bx ax
    iret
NewHandler endp

initNewHandler proc
    mov ax, 3509h
    int 21h
    mov word ptr oldHandler, bx
    mov word ptr oldHandler+2, es
    
    push ds
    mov ax, 2509h
    mov dx, @code
    mov ds, dx
    lea dx, NewHandler
    int 21h
    pop ds
    ret
initNewHandler endp

initOldHandler proc
    push ds
    mov ax, 2509h
    mov dx, word ptr oldHandler
    mov bx, word ptr oldHandler+2
    mov ds, bx
    int 21h
    pop ds
    ret
initOldHandler endp

main:
    mov dx, @data
    mov ds, dx
    mov es, dx
    
    call readNum
    mov shift, bl
    call initNewHandler
    
@@cycle:
    cmp flagExit, 1
    jne @@cycle
    
    call initOldHandler
    mov ah, 4ch
    int 21h
end main