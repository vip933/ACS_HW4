; file.asm - использование файлов в NASM
extern printf
extern rand

extern BALL
extern PARALLELEPIPED
extern TETRAHEDRON


%include "mymacros.mac"

;----------------------------------------------
; // rnd.c - содержит генератор случайных чисел в диапазоне от 1 до 20
; int Random() {
;     return rand() % 20 + 1;
; }
global Random
Random:
section .data
    .i200     dq      200
    .rndNumFmt       db "Random number = %d",10,0
section .text
push rbp
mov rbp, rsp

    xor     rax, rax    ;
    call    rand        ; запуск генератора случайных чисел
    xor     rdx, rdx    ; обнуление перед делением
    idiv    qword[.i200]       ; (/%) -> остаток в rdx
    mov     rax, rdx
    inc     rax         ; должно сформироваться случайное число

    ;mov     rdi, .rndNumFmt
    ;mov     esi, eax
    ;xor     rax, rax
    ;call    printf


leave
ret

;----------------------------------------------
;// Случайный ввод параметров прямоугольника
;void InRndRectangle(void *r) {
;   int x = Random();
;   *((int*)r) = x;
;   int y = Random();
;   *((int*)(r+intSize)) = y;
;//     printf("    Rectangle %d %d\n", *((int*)r), *((int*)r+1));
;}
global InRndBall
InRndBall:
section .bss
    .pball  resq 1   ; адрес прямоугольника
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес прямоугольника
    mov     [.pball], rdi
    ; Генерация сторон прямоугольника
    call    Random
    mov     rbx, [.pball]
    mov     [rbx], eax

leave
ret

;----------------------------------------------
;// Случайный ввод параметров треугольника
;void InRndTriangle(void *t) {
    ;int a, b, c;
    ;a = *((int*)t) = Random();
    ;b = *((int*)(t+intSize)) = Random();
    ;do {
        ;c = *((int*)(t+2*intSize)) = Random();
    ;} while((c >= a + b) || (a >= c + b) || (b >= c + a));
;//     printf("    Triangle %d %d %d\n", *((int*)t), *((int*)t+1), *((int*)t+2));
;}
global InRndParallelepiped
InRndParallelepiped:
section .bss
    .pparal  resq 1   ; адрес треугольника
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес треугольника
    mov     [.pparal], rdi
    ; Генерация сторон треугольника
    call    Random
    mov     rbx, [.pparal]
    mov     [rbx], eax
    call    Random
    mov     rbx, [.pparal]
    mov     [rbx+4], eax
    call    Random
    mov     rbx, [.pparal]
    mov     [rbx+8], eax

leave
ret

global InRndTetrahedron
InRndTetrahedron:
section .bss
    .ptetr  resq 1
section .text
push rbp
mov rbp, rsp

    mov [.ptetr], rdi
    call Random
    mov rbx, [.ptetr]
    mov [rbx], eax

leave
ret

;----------------------------------------------
;// Случайный ввод обобщенной фигуры
;int InRndShape(void *s) {
    ;int k = rand() % 2 + 1;
    ;switch(k) {
        ;case 1:
            ;*((int*)s) = RECTANGLE;
            ;InRndRectangle(s+intSize);
            ;return 1;
        ;case 2:
            ;*((int*)s) = TRIANGLE;
            ;InRndTriangle(s+intSize);
            ;return 1;
        ;default:
            ;return 0;
    ;}
;}
global InRndShape
InRndShape:
section .data
    .i3     dq      3
    .rndNumFmt       db "Random number = %d",10,0
section .bss
    .pshape     resq    1   ; адрес фигуры
    .key        resd    1   ; ключ
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес фигуры
    mov [.pshape], rdi

    ; Формирование признака фигуры
    xor     rax, rax    ;
    call    rand        ; запуск генератора случайных чисел
    idiv    qword[.i3]  ; очистка результата кроме младшего разряда (0 или 1)
    inc     eax         ; фомирование признака фигуры (1 или 2)

    ;mov     [.key], eax
    ;mov     rdi, .rndNumFmt
    ;mov     esi, [.key]
    ;xor     rax, rax
    ;call    printf
    ;mov     eax, [.key]

    mov     rdi, [.pshape]
    mov     [rdi], eax      ; запись ключа в фигуру
    cmp eax, [BALL]
    je .ballInrnd
    cmp eax, [PARALLELEPIPED]
    je .parallInRnd
    cmp eax, [TETRAHEDRON]
    je .tetrInRnd
    xor eax, eax        ; код возврата = 0
    jmp     .return
.ballInrnd:
    ; Генерация прямоугольника
    add     rdi, 4
    call    InRndBall
    mov     eax, 1      ;код возврата = 1
    jmp     .return
.parallInRnd:
    ; Генерация треугольника
    add     rdi, 4
    call    InRndParallelepiped
    mov     eax, 1      ;код возврата = 1
    jmp     .return
.tetrInRnd:
    add     rdi, 4
    call    InRndTetrahedron
    mov     eax, 1
.return:
leave
ret

;----------------------------------------------
;// Случайный ввод содержимого контейнера
;void InRndContainer(void *c, int *len, int size) {
    ;void *tmp = c;
    ;while(*len < size) {
        ;if(InRndShape(tmp)) {
            ;tmp = tmp + shapeSize;
            ;(*len)++;
        ;}
    ;}
;}
global InRndContainer
InRndContainer:
section .bss
    .pcont  resq    1   ; адрес контейнера
    .plen   resq    1   ; адрес для сохранения числа введенных элементов
    .psize  resd    1   ; число порождаемых элементов
section .text
push rbp
mov rbp, rsp

    mov [.pcont], rdi   ; сохраняется указатель на контейнер
    mov [.plen], rsi    ; сохраняется указатель на длину
    mov [.psize], edx    ; сохраняется число порождаемых элементов
    ; В rdi адрес начала контейнера
    xor ebx, ebx        ; число фигур = 0
.loop:
    cmp ebx, edx
    jge     .return
    ; сохранение рабочих регистров
    push rdi
    push rbx
    push rdx

    call    InRndShape     ; ввод фигуры
    cmp rax, 0          ; проверка успешности ввода
    jle  .return        ; выход, если признак меньше или равен 0

    pop rdx
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
