# Proyecto 2: MiniShell en ARM-64
**Estudiante:** Sebastián Estrada (202505125)

Este es mi proyecto de intérprete de comandos (shell) hecho completamente en ensamblador ARM-64 para el curso de Arquitectura de Computadores y Ensambladores 1.

## ¿Qué necesitas para correrlo?
Como el código es de arquitectura ARM-64 puro, necesitas correrlo en Linux (yo usé WSL en Windows) y tener instalado el compilador cruzado y el emulador QEMU. Si no los tienes, instálalos con este comando:
`sudo apt install binutils-aarch64-linux-gnu qemu-user -y`

## ¿Cómo compilarlo?
Súper fácil, gracias al Makefile. Solo abre tu terminal en la carpeta del proyecto y escribe:
`make`

## ¿Cómo ejecutarlo?
Una vez compilado, arranca el MiniShell corriendo el emulador con este comando:
`qemu-aarch64 ./minishell`

## Comandos que puedes probar:
* `help`: Te muestra los comandos disponibles.
* `clear`: Limpia la pantalla.
* `echo [texto]`: Repite en pantalla lo que escribas a la par.
* `ls`: Crea un proceso hijo y ejecuta el comando real del sistema para listar archivos.
* `exit`: Cierra el programa de forma limpia.
