/**
 * cpuid.S -- печатает сведения о подсистемах процессора
 *
 * Copyright (c) 2022 Petrozavodsk State University
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 */

.include "my-macro"

/* Секция данных */

.data

errmess:
        .string "CPUID is not supported\n"

/* Секция команд процессора */

.text

    .global _start                      # точка входа - глобальная метка
_start:

    /* Подготавливаем стек к работе с локальными переменными */
        pushl %ebp                      # сохраняем текущий контекст стека
        movl  %esp, %ebp
        subl  $16, %esp                 # резервируем 16 байт для локального
                                        # буфера

    /* Анализируем, доступна ли инструкция cpuid */
        pushfl                          # получаем содержимое регистра флагов
        popl %eax                       # в регистре eax
        movl %eax, %ebx                 # сохраняем копию регистра флагов
        xorl $0x00200000, %eax          # меняем бит 21 на противоположный
        pushl %eax                      # сохраняем измененное значение
        popfl                           # в регистре флагов
        pushfl                          # снова получаем регистр флагов
        popl %eax
        xorl %ebx, %eax                 # если бит не сохранился
        je no_cpuid                     # cpuid не поддерживается

    /* Получим идентификатор производителя процессора */
        movl $0, %eax                  # загружаем код функции регистр eax
        cpuid                          # получаем строку производителя
        movl %ebx, -16(%ebp)           # в регистрах ebx, edx, ecx
        movl %edx, -12(%ebp)           # сохранаем в буфер
        movl %ecx, -8(%ebp)
        movb $10, -4(%ebp)             # помещаем символ перевода строки в
                                       # в конец буфера
	movl %eax, %esi

    /* Выводим идентификационную строку производителя ЦП на экран */
        movl $4, %eax                  # помещаем номер системного вызова
                                       # write в регистр eax
        movl $1, %ebx                  # помещаем номер стандартного потока 
                                       # вывода (stdout) в ebx
        movl %ebp, %ecx                # помещаем адрес начала буфера выводе
        subl $16, %ecx                 # в ecx
        movl $13, %edx                 # помещаем длину строки в edx
        int $0x80                      # обращаемся к ОС для выполнения
                                       # системного вызова (вывода строки)

    /*** Дополнительные проверки - РЕАЛИЗУЙТЕ САМОСТОЯТЕЛЬНО ПО ЗАДАНИЮ */

	cmpl $1, %esi
	jl cpuid_function_1_not_supported

    /*** Проверка наличия математического сопроцессора (x87 FPU on Chip) и подсистемы MMX */

check_FPU:
	movl $1, %eax
	cpuid

	test $0x00000001, %edx
	jnz FPU

    Puts "ERROR"
	jmp done

check_MMX:
    movl $1, %eax
	cpuid

	test $0x00800000, %edx
	jnz MMX

	Puts "ERROR"
	jmp done

    /*** */

FPU:
	Puts "FPU"
	jmp check_MMX

MMX:
	Puts "MMX"
	jmp done

    /* Обработка ситуации, если cpuid отсутствует (80386) */
no_cpuid:
        movl $4, %eax                  # помещаем номер системного вызова
                                       # write в регистр eax
        movl $1, %ebx                  # помещаем номер стандартного потока 
                                       # вывода (stdout) в ebx
        leal errmess, %ecx             # помещаем адрес начала буфера вывода
        movl $24, %edx                 # помещаем длину строки в edx
        int $0x80                      # обращаемся к ОС для выполнения
                                       # системного вызова (вывода строки)
cpuid_function_1_not_supported:
	Puts "Function '1' of the CPUID is not supporter by your processor!"


    /* Организуем корректное завершение программы */
done:
        mov %ebp, %esp                  # восстанавливаем контекст стека
        popl %ebp

        movl $1, %eax                   # загружаем в eax номер вызова exit
        movl $0, %ebx                   # загружаем в ebx код возврата 0
        int $0x80                       # выполняем обращение к ОС для
                                        # выполнения системного вызова

	.end                            # последняя строка исходного текста  

