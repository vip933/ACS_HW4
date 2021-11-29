;------------------------------------------------------------------------------
; perimeter.asm - единица компиляции, вбирающая функции вычисления периметра
;------------------------------------------------------------------------------

extern BALL
extern PARALLELEPIPED
extern TETRAHEDRON


;----------------------------------------------
; Вычисление периметра прямоугольника
;double PerimeterRectangle(void *r) {
;    return 2.0 * (*((int*)r)
;           + *((int*)(r+intSize)));
;}
global SquareParallelepiped
SquareParallelepiped:
section .text
section .data
push rbp
mov rbp, rsp

    ; В rdi адрес прямоугольника
    xor ecx, ecx
    mov eax, [rdi]
    mov edx, [rdi+4]
    mul edx
    shr edx, 1
    mov ecx, edx

    mov eax, [rdi]
    mov edx, [rdi+8]
    mul edx
    shr edx, 1
    add ecx, edx

    mov eax, [rdi+4]
    mov edx, [rdi+8]
    mul edx
    shr edx, 1
    add ecx, edx

    cvtsi2sd    xmm0, ecx

leave
ret

;----------------------------------------------
; double PerimeterTriangle(void *t) {
;    return (double)(*((int*)t)
;       + *((int*)(t+intSize))
;       + *((int*)(t+2*intSize)));
;}
global SquareBall
SquareBall:
section .text
section .data
    .pi     dq      3.14
push rbp
mov rbp, rsp

    ; В rdi адрес треугольника
    mov eax, [rdi]
    mov ecx, [.pi]
    mul ecx
    mov eax, 4
    mul eax
    mov ecx, [rdi]
    mul ecx
    cvtsi2sd    xmm0, ecx

leave
ret

global SquareTetrahedron
SquareTetrahedron:
section .text
section .data
    .sqrt   dq      1.73
push rbp
mov rbp, rsp

    mov eax, [rdi]
    mov ecx, [rdi]
    mul ecx
    mov eax, [.sqrt]
    mul eax

    cvtsi2sd    xmm0, eax

leave
ret

;----------------------------------------------
; Вычисление периметра фигуры
;double PerimeterShape(void *s) {
;    int k = *((int*)s);
;    if(k == RECTANGLE) {
;        return PerimeterRectangle(s+intSize);
;    }
;    else if(k == TRIANGLE) {
;        return PerimeterTriangle(s+intSize);
;    }
;    else {
;        return 0.0;
;    }
;}
global SquareShape
SquareShape:
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес фигуры
    mov eax, [rdi]
    cmp eax, [TETRAHEDRON]
    je tetrSquare
    cmp eax, [PARALLELEPIPED]
    je parallSquare
    cmp eax, [BALL]
    je ballSquare
    xor eax, eax
    cvtsi2sd    xmm0, eax
    jmp     return
tetrSquare:
    ; Вычисление периметра прямоугольника
    add     rdi, 4
    call    SquareTetrahedron
    jmp     return
parallSquare:
    ; Вычисление периметра треугольника
    add     rdi, 4
    call    SquareParallelepiped
ballSquare:
    add     rdi, 4
    call    SquareBall
return:
leave
ret

;----------------------------------------------
;// Вычисление суммы периметров всех фигур в контейнере
;double PerimeterSumContainer(void *c, int len) {
;    double sum = 0.0;
;    void *tmp = c;
;    for(int i = 0; i < len; i++) {
;        sum += PerimeterShape(tmp);
;        tmp = tmp + shapeSize;
;    }
;    return sum;
;}
global AverageMeanContainer
AverageMeanContainer:
section .data
    .sum    dq  0.0
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес начала контейнера
    mov ebx, esi            ; число фигур
    xor ecx, ecx            ; счетчик фигур
    movsd xmm1, [.sum]      ; перенос накопителя суммы в регистр 1                          todo
.loop:
    cmp ecx, ebx            ; проверка на окончание цикла
    jge .return             ; Перебрали все фигуры

    mov r10, rdi            ; сохранение начала фигуры
    call SquareShape        ; Получение периметра первой фигуры
    addsd xmm1, xmm0        ; накопление суммы
    inc rcx                 ; индекс следующей фигуры
    add r10, 16             ; адрес следующей фигуры
    mov rdi, r10            ; восстановление для передачи параметра
    jmp .loop
.return:
    movsd xmm0, xmm1
leave
ret
