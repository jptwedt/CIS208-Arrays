

;
; file: array1.asm
; This program demonstrates arrays in assembly
;
; To create executable:
; nasm -f coff array1.asm
; gcc -o array1 array1.o array1c.c
;

%define MAX_ARRAY_SIZE 100
%define NEW_LINE 10

segment .data
SizePrompt      db   "Please enter the array size (< 100): ",0
ScalarPrompt    db   "Please enter a scalar: ",0
resultMsg       db   "All %i elements after multiplication: ", NEW_LINE, 0
Prompt          db   "Enter scalar to multiply array: ",0
SecondMsg       db   "Element %d is %d", NEW_LINE, 0
InputFormat     db   "%i", 0

segment .bss
array           resw MAX_ARRAY_SIZE
arraySize       resd 1
scalar          resw 1

 

segment .text
    extern  puts, printf, scanf, dump_line
    global  asm_main
asm_main:
    enter   4,0                         ; local dword variable at EBP - 4
    push    ebx                         ; pushes ebx onto stack
    push    esi                         ; pushes source index onto stack
    ; prompt user for array size
    Prompt_Arrloop:
        push    dword SizePrompt        ; push prompt onto stack
        call    printf                  ; call printf fxn
        pop     ecx                     ; pop prompt to ecx from stack
        lea     eax, [ebp-4]            ; eax = address of local dword
        push    eax                     ; push address onto stack
        push    dword InputFormat       ; push InputFormat onto stack
        call    scanf                   ; call scanf
                                        ;  input stored into local dword
        mov     edx, [ebp-4]            ; store  scanned value into edx
        mov     [arraySize],edx         ; store array size from dword
        add     esp, 8                  ; clear last two parameters from stack
        cmp     eax, 1                  ; eax = return value of scanf
                                        ;  scanf returns # of chars printed
        je      SizeOK
        call    dump_line               ; dump rest of line and start over
        jmp     Prompt_Arrloop          ; if input invalid
    ; if size is okay...
    SizeOK:
        mov     ecx, [arraySize]        ; stores max array size in ecx
        mov     ebx, array              ; stores address of array into ebx
;        mov     edx, [ebp-4]            ; store address of local dword
;        push    edx                     ; push that onto stack
;        call    clock_random            ; generates a random 0-9 int 
;        pop     edx                     ; pop result 
;        mov     [initRand],dx           ; store that into initRand
        init_loop:
            mov     ch,0                ; zero out ch
            mov     [ebx], cl           ; stores value of cl to array element
            add     ebx, 2              ; adds 2 bytes to ebx (address)
            loop    init_loop           ; repeat until ecx = 0
        push    dword array             ; push array address onto stack
        call    print_array             ; call print_arry
    ; prompt user for scalar
    Prompt_Scaloop:
        push    dword ScalarPrompt      ; push prompt onto stack
        call    printf                  ; call printf fxn
        add     esp,4                   ; clear prompt from stack
        lea     eax, [ebp-4]            ; eax = address of local dword
        push    eax                     ; push address onto stack
        push    dword InputFormat       ; push InputFormat onto stack
        call    scanf                   ; call scanf
                                        ;  input stored into local dword
        mov     edx, [ebp-4]            ; move local dword into edx
        mov     [scalar], edx           ; store local dword into scalar
        add     esp, 8                  ; clear last two parameters from stack
        cmp     eax, 1                  ; eax = return value of scanf
                                        ;  scanf returns # of chars printed
        je      ScalarOK                 ; jump if it printed 1 character
        call    dump_line               ; dump rest of line and start over
        jmp     Prompt_Scaloop          ; if input invalid
    ; if scalar is okay...
    ScalarOK:
        mov     ecx, [arraySize]        ; stores max array size in ecx
        mov     ebx, array              ; stores address of array into ebx
        cld                             ; clear direction flag
        mov     esi,array               ; move the array address to esi
        mov     edi,array               ; make the destination array the same
                                        ;  as the source array
        mov     dl,[scalar]             ; copy the scalar to dl
        push    edx                     ; push edx to stack, just in case
        mul_loop:
            lodsw                       ; load word into AX from array
            mul    dl                   ; multiply AX by DL, store in AX
            stosw                       ; store AX 
            loop    mul_loop            ; repeat until ecx = 0
        pop     edx                     ; return edx to pre-loop state
        add     esp, 8                  ; clears "array + 20*4", "10" off stack
        push    dword [arraySize]       ; pushes arraySize onto stack
        push    dword resultMsg         ; pushes input format ont stack
        call    printf
        add     esp,8                   ; clears arraySize from stack
        push    dword [arraySize]       ; pushes "arraySize" onto stack
        push    dword array             ; pushes address of array onto stack
        call    print_array             ; calls print_array fxn
        add     esp, 8                  ; clears 2 parameters off stack
    pop     esi                         ; pops stored esi to esi
    pop     ebx                         ; pops stored ebx to ebx
    mov     eax, 0                      ; return back to C
    leave                     
    ret


; routine print_array
; C-callable routine that prints out elements of a double word array as
; signed integers.
; C prototype:
; void print_array( const int * a, int n);
; Parameters:
;   a - pointer to array to print out (at ebp+8 on stack)
;   n - number of integers to print out (at ebp+12 on stack)

segment .data
OutputFormat    db   "%-5i %5i", NEW_LINE, 0

segment .text
    global  print_array
print_array:
    enter   0,0
    push    esi                         ; store esi value on stack
    push    ebx                         ; store ebx value on stack (should be
                                        ;  last entered array value)
    cld                                 ; make sure increment +1
    xor     esi, esi                    ; esi = 0
                                        ; by the C protocol, ebp = esp by this
                                        ;  time, so both point to top of the
                                        ;  stack
    mov     ecx, [arraySize]            ; ecx = n
    mov     ebx, array                  ; ebx = address of array
                                        ; note: ebp+4 should have return addy
    print_loop:
        push    ecx                     ; printf might change ecx!
        mov     cl, [ebx + 2*esi]       ; ecx = value in (array + 2*index)
        movzx   ecx,cl                  ; signed extension into ECX
        push    ecx                     ; push ecx onto stack for printf
        push    esi                     ; push esi onto stack for count
        push    dword OutputFormat      ; push OutputFormat onto stack
        call    printf
        add     esp, 12                 ; remove parameters (leave ecx!)
                                        ;  (removes OutputFormat,esi, and
                                        ;  array[esi])
        inc     esi                     ; increment esi
        pop     ecx                     ; pop stored ecx value back to ecx
        loop    print_loop              ; loop if ecx > 0
    pop     ebx                         ; pop stored ebx value to ebx
    pop     esi                         ; pop stored esi value to esi
    leave                               ; performs subprogram epilogue
    ret                                 ; jump back to instruction after call

; routine clock_random
; generates a number based off of the system clock
; based off of code found here: https://stackoverflow.com/questions/17855817/generating-a-random-number-within-range-of-0-9-in-x86-8086-assembly
;

;segment .data
;
;segment .text
;    global clock_random
;clock_random:
;    enter   0,0
;    lea     ebx,[ebp-4]             ; ebx = address of local dword
;b1:
;    mov     ah,00h                  ; interrupts to get system time
;b2:
;    int     1Ah                    ; cx:dx stores ticks since midnight
;b3:
;    mov     ax,dx                   ; stores the dx part into ax
;    xor     dx,dx                   ; zero out dx
;    mov     cx,10                   ; store operator into cx
;    div     cx                      ; divide ax by cx, remainder in dx
;    movsx   edx,dx                  ; extend dx into edx
;    mov     ebx,edx                 ; put dx into local variable
;    leave
;    ret
