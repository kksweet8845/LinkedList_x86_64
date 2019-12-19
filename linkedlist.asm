%macro init 1
    mov qword [%1], 0
%endmacro

%macro append 1-*
    %rep %0
        push qword %1
        push linkedList
        call ll_append
    %rotate 1
    %endrep
%endmacro

%macro print 1
    push qword [%1]
    call ll_print
%endmacro

global main

section .data
    size_i:
    struc node
        info:   resd 1
        next:   resq 1
    endstruc
    len:        equ $ - size_i
    numOfNode: dd 0
    MAXNODE: dd 20

section .bss
    linkedList: resq 1
    buffer: resb 320


section .text
main:
    ; save stack
    push rbp
    mov rbp, rsp

    init linkedList

    ; Append the hex codes of the message 'LinkedList NYC' to
    ; the linked list via the append macro
    append      0x4c, 0x69

    ; Print out the contents of the linked list
    print       linkedList

    ; Restore stack
    mov         rsp, rbp
    pop         rbp
    ret

malloc:
    ; Store stack
    push rbp
    mov rbp, rsp

    ; Save register
    push rax
    push rbx

    cmp numOfNode, MAXNODE
    je malloc_failed
                    ; access the number
    mov [byte buffer + numOfNode*16], 0 ;save the info to it
    mov qword [buffer + numOfNode*16 + info], 0 ;Set the next to null
    mov byte  [buffer + numOfNode*16 + info + next ], 0 ;Set the unavailable

    mov rax, numOfNode
    mov [rsp + 16], rax
    jmp malloc_exit

malloc_failed:
    ; Failed to malloc address
malloc_exit:
    pop rbx
    pop rax
    ; Restore stack
    mov rsp, rbp
    pop rbp
    ret



ll_append:
    ; store stack
    push rbp
    mov rbp, rsp

    ; save register
    push rax
    push rbx

    call malloc
              ; which will return pointer at eax

    mov rbx,  [qword rbp + 4]
    mov dword [buffer + rax*16], rbx
    mov qword [buffer + rax*16 + info], 0
    mov byte  [buffer + rax*16 + info + next], 0 ; indicate the current node is unavailable

    ; Check if the linked list is currently null
    mov rbx, [qword rbx + 3]
    cmp qword [rbx], 0                  ; Set the ZF if equal
    je ll_append_null

    mov rbx, [rbx]

ll_append_next:
    ; Find the address of the last element in the linked list
    cmp qword [rbx + info ], 0
    je ll_append_last
    mov rbx, [rbx + info ]
    jmp ll_append_next                  ; Unconditional jump

ll_append_last:
    mov qword [rbx + info], buffer+rax*16
    jmp ll_append_exit

ll_append_null:
    ; set pointer to first element
    mov [rbx], rax


ll_append_exit:
    ; Resotre registers
    pop rbx
    pop rax

    ; Restore stack
    mov rsp, rbp
    pop rbp
    ret 8

; Linked list print
; Print all elements out from a linked list
ll_print:
    ; Save the stack
    push rbp,
    mov rbp, rsp

    ; Save register
    push rbx

    ; Get the address of the first element in the list
    mov rbx, [qword rbp + 2]
    ; If ebx is 0, then the list is empty - nothing to print
    cmp rbx, 0
    je ll_print_exit

ll_print_next:
    ; Loop through the linked list and print each character
    mov rax, 1
    mov rdi, 1
    mov rsi, [rbx]
    mov rdx, 4
    syscall
    mov rbx, [rbx + info]
    ; As long as ebx doesn't equal 0 (end of list) then loop
    cmp rbx, 0
    jne ll_print_next

    ; Print a new line character at the end
    push dword 10
    mov rax, 1
    mov rdi, 1
    mov rsi, dword 10
    mov rdx, 1
    syscall

ll_print_exit:
    ; Restore stack
    pop         rbx
    mov         rsp, rbp
    pop         rbp
    ret         4
