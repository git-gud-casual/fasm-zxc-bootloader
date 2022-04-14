use16
org 0x7c00


; Set video bios video mode
init:
        ; Обнуление регистров
        cli
                xor ax, ax
                mov ss, ax
                mov es, ax
                mov ds, ax

                mov sp, 0x7c00 ; Вершина стека
        sti
        call setTextMode



jmp start


setTextMode:
        mov ax, 0003h
        int 10h
        ret



printFromStack:
      ; SET CURSOR POS ;
        mov ah, 02h
        int 10h
        add dl, 01h
        ; 80x25 MONITOR ;
        cmp dl, 4fh
        jbe .posSet
            mov dl, 00h
            add dh, 01h

        .posSet:


      ; GET AX FROM STACK. 3FFF - stack end mark ;
        pop ax
        cmp ax, 3fffh
        je start.exitPrintFromStack

      ; MOVE REMAINDER FROM AH TO AL
        mov al, ah


      ; PRINT REMAINDER (SEE ASCII TABLE) ;
        mov ah, 0ah
        add al, 30h
        mov cx, 0001h
        int 10h

        jmp printFromStack



toDecimal:
      ; SAVE CX ;
        push cx
      ; PUSH STACK END MARK ;
        mov cx, 3fffh
        push cx

      ; PUSH REMAINDERS WHILE AL (quotient) is not 00 ;
        .loop:
                div bl
                push ax
                xor ah, ah
                cmp al, 00h
                jne .loop

        jmp start.exitToDecimal

msg db "DEAD INSIDE 1000-7=ZXC",0

start:

        mov dx, 0000h
        mov bx, 000ah

        mov cx, 03e8h
        mov ax, cx



        .loop:
                jmp toDecimal
                .exitToDecimal:
                jmp printFromStack
                .exitPrintFromStack:

              ; PRINT "-" ;
                mov ah, 0ah
                mov al, 2dh
                mov cx, 0001h
                int 10h
              ; SET CURSOR POS ;
                mov ah, 02h
                int 10h
                add dl, 01h
                ; 80x25 MONITOR ;
                cmp dl, 4fh
                jbe .posSet1
                  mov dl, 00h
                  add dh, 01h
                .posSet1:
              ; PRINT "7" ;
                mov ah, 0ah
                mov al, 37h
                mov cx, 0001h
                int 10h
             ; SET CURSOR POS ;
                mov ah, 02h
                int 10h
                add dl, 01h
                ; 80x25 MONITOR ;
                cmp dl, 4fh
                jbe .posSet2
                  mov dl, 00h
                  add dh, 01h

               .posSet2:
             ; PRINT "?" ;
                mov ah, 0ah
                mov al, 3fh
                mov cx, 0001h
                int 10h
             ; SET CURSOR POS ;
                mov ah, 02h
                int 10h
                add dl, 02h
                ; 80x25 MONITOR ;
                cmp dl, 4fh
                jbe .posSet3
                  mov dl, 00h
                  add dh, 01h

               .posSet3:



              ; POP CX AND MOVE TO AX ;
                pop cx
                sub cx, 0007h
                mov ax, cx



                cmp cx, 03e8h
                jae .loopexit
                jmp .loop
        .loopexit:
        mov bp, msg
        mov cx, 17h
        add dh, 01h
        mov dl, 00h
        mov ax, 1301h
        int 10h

        jmp $


times 510-($-$$) db 0
dw 0xAA55
