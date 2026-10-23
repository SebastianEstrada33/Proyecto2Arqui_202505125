.global _start
.section .data
prompt:      .ascii "MiniShell> "
prompt_len = . - prompt

.section .text
_start:
shell_loop:
    mov x0, 1                   // File descriptor 1 (stdout)
    ldr x1, =prompt             // Dirección del texto
    ldr x2, =prompt_len         // Longitud del texto
    mov x8, 64                  // Syscall 'write' en Linux ARM64
    svc 0                       // Llamada al sistema

    // Bucle temporal para que no falle al ejecutar
    b shell_loop