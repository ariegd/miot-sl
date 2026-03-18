# buffer overflow y SHELLCODES

### Autores
* Gissela
* Ariel

### Usuarios de la VM
Usuario | Contraseña
root    | superrys
usuario | usuariorys

### Tutorial 1: 64-bit Stack-based Buffer Overflow
[link](https://www.ired.team/offensive-security/code-injection-process-injection/binary-exploitation/64-bit-stack-based-buffer-overflow)

* Deshabilitar el ASLR
```
echo 0 > /proc/sys/kernel/randomize_va_space
```
* Ahora ejecutemos el programa vulnerable, alimentémoslo con el archivo basura y observemos cómo falla.
```
gdb vulnerable
r < in.bin
```

### La solución: Desactivar KVM temporalmente
Para liberar el procesador y que VirtualBox pueda arrancar tu máquina lab8a, ejecuta estos comandos como root:
```
/usr/sbin/modprobe -r kvm_intel
/usr/sbin/modprobe -r kvm
```
