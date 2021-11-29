; file.asm - использование файлов в NASM
extern printf
extern fscanf

extern BALL
extern PARALLELEPIPED
extern TETRAHEDRON

;----------------------------------------------
; // Ввод параметров прямоугольника из файла
; void InRectangle(void *r, FILE *ifst) {
;     fscanf(ifst, "%d%d", (int*)r, (int*)(r+intSize));
; }
global InBall
InBall:
section .data
    .infmt db "%d",0
section .bss
    .FILE   resq    1   ; временное хранение указателя на файл
    .pball  resq    1   ; адрес прямоугольника
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.pball], rdi          ; сохраняется адрес прямоугольника
    mov     [.FILE], rsi          ; сохраняется указатель на файл

    ; Ввод прямоугольника из файла
    mov     rdi, [.FILE]
    mov     rsi, .infmt         ; Формат - 1-й аргумент
    mov     rdx, [.pball]       ; &x
    mov     rax, 0              ; нет чисел с плавающей точкой
    call    fscanf

leave
ret

; // Ввод параметров треугольника из файла
; void InTriangle(void *t, FILE *ifst) {
;     fscanf(ifst, "%d%d%d", (int*)t,
;            (int*)(t+intSize), (int*)(t+2*intSize));
; }
global InParallelepiped
InParallelepiped:
section .data
    .infmt db "%d%d%d",0
section .bss
    .FILE   resq    1   ; временное хранение указателя на файл
    .pparal  resq    1   ; адрес треугольника
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.pparal], rdi          ; сохраняется адрес треугольника
    mov     [.FILE], rsi          ; сохраняется указатель на файл

    ; Ввод треугольника из файла
    mov     rdi, [.FILE]
    mov     rsi, .infmt         ; Формат - 1-й аргумент
    mov     rdx, [.pparal]       ; &a
    mov     rcx, [.pparal]
    add     rcx, 4              ; &b = &a + 4
    mov     r8, [.pparal]
    add     r8, 8               ; &c = &x + 8
    mov     rax, 0              ; нет чисел с плавающей точкой
    call    fscanf

leave
ret

global InTetrahedron
InTetrahedron:
section .data
    .infmt db "%d",0
section .bss
    .FILE   resq    1
    .ptetr  resq    1
section .text
push rbp
mov rbp, rsp

    mov     [.ptetr], rdi
    mov     [.FILE], rsi
    mov     rdi, [.FILE]
    mov     rsi, .infmt
    mov     rdx, [.ptetr]
    mov     rax, 0
    call    fscanf

leave
ret
    

; // Ввод параметров обобщенной фигуры из файла
; int InShape(void *s, FILE *ifst) {
;     int k;
;     fscanf(ifst, "%d", &k);
;     switch(k) {
;         case 1:
;             *((int*)s) = RECTANGLE;
;             InRectangle(s+intSize, ifst);
;             return 1;
;         case 2:
;             *((int*)s) = TRIANGLE;
;             InTriangle(s+intSize, ifst);
;             return 1;
;         default:
;             return 0;
;     }
; }
global InShape
InShape:
section .data
    .tagFormat   db      "%d",0
    .tagOutFmt   db     "Tag is: %d",10,0
section .bss
    .FILE       resq    1   ; временное хранение указателя на файл
    .pshape     resq    1   ; адрес фигуры
    .shapeTag   resd    1   ; признак фигуры
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.pshape], rdi          ; сохраняется адрес фигуры
    mov     [.FILE], rsi            ; сохраняется указатель на файл

    ; чтение признака фигуры и его обработка
    mov     rdi, [.FILE]
    mov     rsi, .tagFormat
    mov     rdx, [.pshape]      ; адрес начала фигуры (ее признак)
    xor     rax, rax            ; нет чисел с плавающей точкой
    call    fscanf

    ; Тестовый вывод признака фигуры
;     mov     rdi, .tagOutFmt
;     mov     rax, [.pshape]
;     mov     esi, [rax]
;     call    printf

    mov rcx, [.pshape]          ; загрузка адреса начала фигуры
    mov eax, [rcx]              ; и получение прочитанного признака
    cmp eax, [BALL]
    je .ballIn
    cmp eax, [PARALLELEPIPED]
    je .paralIn
    cmp eax, [TETRAHEDRON]
    je .tetrIn
    xor eax, eax    ; Некорректный признак - обнуление кода возврата
    jmp     .return
.ballIn:
    ; Ввод прямоугольника
    mov     rdi, [.pshape]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    InBall
    mov     rax, 1  ; Код возврата - true
    jmp     .return
.paralIn:
    ; Ввод треугольника
    mov     rdi, [.pshape]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    InParallelepiped
    mov     rax, 1  ; Код возврата - true
    jmp     .return
.tetrIn:
    mov     rdi, [.pshape]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    InTetrahedron
    mov     rax, 1
.return:

leave
ret

; // Ввод содержимого контейнера из указанного файла
; void InContainer(void *c, int *len, FILE *ifst) {
;     void *tmp = c;
;     while(!feof(ifst)) {
;         if(InShape(tmp, ifst)) {
;             tmp = tmp + shapeSize;
;             (*len)++;
;         }
;     }
; }
global InContainer
InContainer:
section .bss
    .pcont  resq    1   ; адрес контейнера
    .plen   resq    1   ; адрес для сохранения числа введенных элементов
    .FILE   resq    1   ; указатель на файл
section .text
push rbp
mov rbp, rsp

    mov [.pcont], rdi   ; сохраняется указатель на контейнер
    mov [.plen], rsi    ; сохраняется указатель на длину
    mov [.FILE], rdx    ; сохраняется указатель на файл
    ; В rdi адрес начала контейнера
    xor rbx, rbx        ; число фигур = 0
    mov rsi, rdx        ; перенос указателя на файл
.loop:
    ; сохранение рабочих регистров
    push rdi
    push rbx

    mov     rsi, [.FILE]
    mov     rax, 0      ; нет чисел с плавающей точкой
    call    InShape     ; ввод фигуры
    cmp rax, 0          ; проверка успешности ввода
    jle  .return        ; выход, если признак меньше или равен 0

    pop rbx
    inc rbx

    pop rdi
    add rdi, 16             ; адрес следующей фигуры

    jmp .loop
.return:
    mov rax, [.plen]    ; перенос указателя на длину
    mov [rax], ebx      ; занесение длины
leave
ret

