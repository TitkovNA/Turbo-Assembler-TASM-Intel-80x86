
; - 15. Написать программу, удаляющую из исходной строки многократные вхождения  заданного символа, заменяя их однократными, Z-string
; - 15. Несколько точек входа в процедуру (вызов процедуры "с середины").
.model small
.stack 100h

.data
    sourceString    db "aabbbccdddeeebbbbbbbbbbbff",13,10, 0   ; Исходная строка с завершающим нулевым символом
    resultString    db 255 dup (?)                             ; Новая строка объявлена с максимальной длиной 255 символов
	charToDelete    db 'b'                                     ; Заданный Символ, который нужно удалить при многократном вхождении
	
	str1 db "Start string: ",13,10,"$"
	str2 db "Result string: ",13,10,"$"
.code

main:
;============================================================================================================
;Макрос для процедуры вывода
print macro sectionType, outstr
	push offset str2
	push offset str1
	push outstr
    push sectionType                  ; помещаем sectionType в стек
    call PrintString                  ; вызываем процедуру
endm
;============================================================================================================
;Основнвя часть
    mov ax, @data
    mov ds, ax
	CLD
	mov di, offset resultString       ; Устанавливаем приемник данных (новая строка для результата)
    mov si, offset sourceString       ; Устанавливаем источник данных для вывода (исходная строка)
	mov bl, charToDelete              ; Загружаем символ, который нужно удалять в BL
	
	print 1,si                        ; Вызов процедуры PrintString для вывода начальной строки
	call calculation
	print 2,di                        ; Вызов процедуры PrintString для вывода результирующей строки
;============================================================================================================
;Выход из программы	
    mov ax , 4C00h                    ; Функция завершения программы 
    int 21h                           ; Вызов прерывания для завершения программы

;============================================================================================================
;Процедура для вывода строки
PrintString proc
	ARG Types, outstr1, str11, str22
	
    ; получаем параметр (sectionType) из стека
	push 	bp
	mov 	bp, sp
    
	push 	ax						   ; сохранение регистров 
	push	dx
	push    si
; проверяем значение sectionType и выбираем какую часть процедуры выполнять
    cmp Types, 1
    je section1
    cmp Types, 2
    je section2
    
section1:
	mov ah, 09h						  ; Вывод строки
	mov dx, str11				      
	int 21h	

	mov ah, 0Eh                       ; Установка функции вывода одного символа
	mov si, outstr1
	print_loop:
		lodsb                         ; Загрузка символа из строки, инкремент si
		cmp al, 0                     ; Проверка на нулевой символ (конец строки)
		jz done                       ; Если нулевой символ, завершаем вывод

		int 10h                       ; Вывод символа
		jmp print_loop                ; Переход на следующий символ

section2:
	mov ah, 09h						  ; Вывод строки
	mov dx, str22					  
	int 21h	
	mov ah, 0Eh                       ; Установка функции вывода одного символа
	mov si, outstr1
	print_loop1:
		lodsb                         ; Загрузка символа из строки, инкремент si
		cmp al, 0                     ; Проверка на нулевой символ (конец строки)
		jz done                       ; Если нулевой символ, завершаем вывод

		int 10h                       ; Вывод символа
		jmp print_loop1               ; Переход на следующий символ


done:
    pop     si
	pop 	dx                        ; восстановление регистров
	pop 	ax
	pop 	bp
    ret 8                             ; Возврат из процедуры

PrintString endp
;============================================================================================================
;Процедура для решения задачи
calculation proc near

	push 	ax					  ; сохранение регистров 
	push	dx
	push    si
	push    di
	
	xor cx,cx                     ; Обнуляем регистр для подсчета кол-во повторов
replace_duplicates:

    mov al, [si]                  ; Загружаем текущий символ из исходной строки в AL
    cmp al, 0                     ; Проверяем, достигли ли конца строки (нулевого символа)
    je end_of_string              ; Если достигли конца строки, завершаем цикл
    cmp al, bl                    ; Сравниваем текущий символ с символом для удаления
    je skip_char                  ; Если символ совпадает, проверяем его на повтор
	xor cx,cx                     ; Обнуляем регистр для подсчета кол-во повторов, т.к встретился другой символ
    mov [di], al                  ; Копируем символ в приемник (новая строка для результата)
	inc si						  ; Увеличиваем указатель
	inc di                        ; Увеличиваем указатель
	jmp replace_duplicates

skip_char:

	cmp cx, 0                     ; Проверяем встречался ли символ до этого
	jnz next                      ; Если да то не выводим
	mov [di], al                  ; Если нет то выводим
    inc di	                      ; Увеличиваем указатель
	
next:	

    inc cx                        ; Увеличиваем указатель источника
    inc si                        ; Переходим к следующему символу
    jmp replace_duplicates        ; Переходим к следующему символу

end_of_string:

    mov byte ptr [di], 0          ; Устанавливаем нулевой символ в конце новой строки для результата
	pop     di    
	pop     si
	pop 	dx                    ; восстановление регистров
	pop 	ax
	                             
	ret
	
calculation endp
;============================================================================================================
end main
