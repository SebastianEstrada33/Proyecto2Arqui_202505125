// main.s - MiniShell en ARM-64
.global _start

.section .data
prompt:         .ascii "MiniShell> "
prompt_len = . - prompt

cmd_exit:       .ascii "exit\n"
cmd_help:       .ascii "help\n"
cmd_clear:      .ascii "clear\n"
cmd_ls:         .ascii "ls\n"
cmd_echo:       .ascii "echo "

msg_help:       .ascii "Comandos: help, clear, exit, echo [texto], ls\n"
msg_help_len = . - msg_help
msg_clear:      .ascii "\033[H\033[2J"
msg_clear_len = . - msg_clear
msg_err:        .ascii "Error: Comando desconocido\n"
msg_err_len = . - msg_err

path_ls:        .asciz "/bin/ls"
argv_ls:        .quad path_ls, 0    // Arreglo de argumentos para execve
envp:           .quad 0             // Entorno vacío

.section .bss
buffer:         .space 256

.section .text
_start:
shell_loop:
    // 1. Prompt
    mov x0, 1
    ldr x1, =prompt
    ldr x2, =prompt_len
    mov x8, 64
    svc 0

    // 2. Leer entrada
    mov x0, 0
    ldr x1, =buffer
    mov x2, 256
    mov x8, 63
    svc 0
    mov x19, x0                     // Guardar longitud leída

    // 3. Validar "exit"
    ldr x0, =buffer
    ldr x1, =cmd_exit
    bl strcmp
    cbz x0, exit_shell

    // 4. Validar "help"
    ldr x0, =buffer
    ldr x1, =cmd_help
    bl strcmp
    cbz x0, run_help

    // 5. Validar "clear"
    ldr x0, =buffer
    ldr x1, =cmd_clear
    bl strcmp
    cbz x0, run_clear

    // 6. Validar "ls" (Comando externo con fork/execve)
    ldr x0, =buffer
    ldr x1, =cmd_ls
    bl strcmp
    cbz x0, run_external

    // 7. Validar "echo " (Compara los primeros 5 bytes)
    ldr x0, =buffer
    ldr x1, =cmd_echo
    mov x2, 5
    bl strncmp
    cbz x0, run_echo

    // Error si no coincide nada
    bl print_error
    b shell_loop

// --- Ejecución de comandos ---
run_help:
    bl print_help
    b shell_loop

run_clear:
    bl print_clear
    b shell_loop

run_echo:
    // Imprimir desde el byte 5 del buffer
    mov x0, 1
    ldr x1, =buffer
    add x1, x1, 5
    sub x2, x19, 5                  // Longitud total menos "echo "
    mov x8, 64
    svc 0
    b shell_loop

// --- Comando Externo (fork y execve) ---
run_external:
    stp x29, x30, [sp, -16]!
    
    // Syscall clone (equivalente a fork en ARM64, syscall 220)
    mov x8, 220
    mov x0, 17                      // SIGCHLD
    mov x1, 0
    mov x2, 0
    mov x3, 0
    mov x4, 0
    svc 0

    cbnz x0, parent_wait            // Si X0 != 0, es el padre

    // Proceso Hijo: execve (syscall 221)
    ldr x0, =path_ls
    ldr x1, =argv_ls
    ldr x2, =envp
    mov x8, 221
    svc 0
    // Si execve falla, salir
    mov x0, 1
    mov x8, 93
    svc 0

parent_wait:
    // Proceso Padre: wait4 (syscall 260)
    mov x0, -1                      // Esperar a cualquier hijo
    mov x1, 0                       // status
    mov x2, 0                       // options
    mov x3, 0                       // rusage
    mov x8, 260
    svc 0
    
    ldp x29, x30, [sp], 16
    b shell_loop

exit_shell:
    mov x0, 0
    mov x8, 93
    svc 0

// --- Funciones de Impresión ---
print_help:
    stp x29, x30, [sp, -16]!
    mov x0, 1
    ldr x1, =msg_help
    ldr x2, =msg_help_len
    mov x8, 64
    svc 0
    ldp x29, x30, [sp], 16
    ret

print_clear:
    stp x29, x30, [sp, -16]!
    mov x0, 1
    ldr x1, =msg_clear
    ldr x2, =msg_clear_len
    mov x8, 64
    svc 0
    ldp x29, x30, [sp], 16
    ret

print_error:
    stp x29, x30, [sp, -16]!
    mov x0, 1
    ldr x1, =msg_err
    ldr x2, =msg_err_len
    mov x8, 64
    svc 0
    ldp x29, x30, [sp], 16
    ret

// --- Funciones de Comparación ---
strcmp:
    stp x29, x30, [sp, -16]!
strcmp_loop:
    ldrb w2, [x0], 1
    ldrb w3, [x1], 1
    cmp w2, w3
    bne strcmp_diff
    cmp w2, 10
    beq strcmp_eq
    b strcmp_loop
strcmp_diff:
    mov x0, 1
    b strcmp_end
strcmp_eq:
    mov x0, 0
strcmp_end:
    ldp x29, x30, [sp], 16
    ret

strncmp:
    stp x29, x30, [sp, -16]!
strncmp_loop:
    cbz x2, strncmp_eq              // Si el contador llega a 0, son iguales
    ldrb w3, [x0], 1
    ldrb w4, [x1], 1
    cmp w3, w4
    bne strncmp_diff
    sub x2, x2, 1
    b strncmp_loop
strncmp_diff:
    mov x0, 1
    b strncmp_end
strncmp_eq:
    mov x0, 0
strncmp_end:
    ldp x29, x30, [sp], 16
    ret
    