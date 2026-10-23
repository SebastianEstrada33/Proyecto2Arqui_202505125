.global _start

.section .data
prompt:      .ascii "MiniShell> "
prompt_len = . - prompt
cmd_exit:    .ascii "exit\n"        // Comando exit con salto de línea

.section .bss
buffer:      .space 256             // Espacio para guardar el comando del usuario

.section .text
_start:
shell_loop:
    // 1. Imprimir el prompt (syscall write)
    mov x0, 1                       // File descriptor 1 (stdout)
    ldr x1, =prompt                 // Dirección del texto del prompt
    ldr x2, =prompt_len             // Tamaño exacto del texto
    mov x8, 64                      // Syscall 'write' en Linux ARM64
    svc 0                           // Interrupción al kernel

    // 2. Leer comando del usuario (syscall read)
    mov x0, 0                       // File descriptor 0 (stdin)
    ldr x1, =buffer                 // Dirección del buffer
    mov x2, 256                     // Cantidad máxima a leer
    mov x8, 63                      // Syscall 'read' en Linux ARM64
    svc 0                           // Interrupción al kernel

    // 3. Comparar entrada con "exit"
    ldr x0, =buffer                 // Primer argumento: entrada del usuario
    ldr x1, =cmd_exit               // Segundo argumento: palabra "exit\n"
    bl strcmp                       // Llamar a la función modular

    cbz x0, exit_shell              // Si X0 es 0 (son iguales), saltar a salir

    b shell_loop                    // Si no son iguales, volver a mostrar prompt

// Rutina de salida: Syscall exit (93)
exit_shell:
    mov x0, 0                       // Código de estado 0 (éxito)
    mov x8, 93                      // Syscall 'exit'
    svc 0

// Función: strcmp (Comparar dos cadenas)
// Argumentos: X0 = cadena 1, X1 = cadena 2
// Retorno: X0 = 0 si son iguales, 1 si son diferentes
strcmp:
    stp x29, x30, [sp, -16]!        // Preservar registros en el stack
strcmp_loop:
    ldrb w2, [x0], 1                // Cargar byte de la cadena 1 y avanzar
    ldrb w3, [x1], 1                // Cargar byte de la cadena 2 y avanzar
    cmp w2, w3                      // Comparar los caracteres
    bne strcmp_diff                 // Si son diferentes, saltar a diff
    cmp w2, 10                      // Si llega a '\n' (salto de línea ASCII 10)
    beq strcmp_eq                   // y son iguales, terminar con éxito
    b strcmp_loop                   // Repetir para el siguiente caracter
strcmp_diff:
    mov x0, 1                       // Retornar 1 (Diferentes)
    b strcmp_end
strcmp_eq:
    mov x0, 0                       // Retornar 0 (Iguales)
strcmp_end:
    ldp x29, x30, [sp], 16          // Restaurar el stack y balancearlo
    ret
