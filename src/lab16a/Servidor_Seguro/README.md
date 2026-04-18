## Para eliminar problemas de arranque de mv dentro de VirtualBox
*Nota: Esto desactiva KVM hasta el próximo reinicio. Una vez ejecutados, intenta arrancar la máquina Kali en VirtualBox de nuevo.*
```
sudo /sbin/rmmod kvm_intel
sudo /sbin/rmmod kvm
```
Nota de Ciberseguridad: Los comandos ip aplican los cambios al momento, pero si reinicias las máquinas virtuales, tendrás que volver a introducirlos. En entornos de auditoría rápida, esto es ideal para no alterar la configuración base del sistema operativo.

## Trabajo con mv en VirtualBox, pero por linea de comandos
```
# 1. Apaga la máquina actual
VBoxManage controlvm "Kali-Linux" acpipowerbutton

# 2. Lánzala en modo "sin cabeza" (Headless)
VBoxManage startvm "Kali-Linux" --type headless

# 3. Confirma que está funcionando
VBoxManage list runningvms

# 4. Obtener solo la dirección IPv4 específica:
VBoxManage guestproperty get "Kali-Linux" "/VirtualBox/GuestInfo/Net/0/V4/IP"

VBoxManage guestproperty enumerate "Kali-Linux" | grep IP

# ¿Cómo trabajar con ella ahora?
ssh usuario@<IP_DE_TU_NODO>
# Conectado a la red eduroam
ssh -p 2222 usuario@127.0.0.1
```

## Si se ha perdido la ip SERV
```
# 1. Asignar la ip manual
sudo ip addr add 192.168.1.20/24 dev enp0s8

# 2. Asegúrate de que la interfaz esté levantada
sudo ip link set enp0s8 up
```

## Nombre de vm
```
SERV
Kali-Linux

Prueba con estos comandos desde tu terminal:
ssh usuario@192.168.56.101
ssh kali@192.168.56.102

# Solución (dentro de la VM Kali) si no funciona:
sudo systemctl enable ssh --now
```

## Acceder al navegador con https
```
curl -Ik https://www.miserv.com

# NO FUNCINA CON SSH
# 1.Abrir Firefox (Navegador visual)
firefox-esr --insecure https://www.miserv.com

# 2. Navegadores de modo texto (Dentro de la terminal)
sudo apt update && sudo apt install lynx
lynx -accept_all_cookies https://miserv.com

```

##  El cliente DHCP no está activo
```
sudo dhclient -v
```

## Credenciales de Kali
```
kali / kali
```

1. Configurar IPs estáticas por terminal (Bash)
> En la máquina Kali (IP: 192.168.1.3 en eth1):
```
# 1. Levantar (encender) la interfaz de red
sudo ip link set eth1 up

# 2. Asignar la dirección IP estática con su máscara de subred (/24)
sudo ip addr add 192.168.1.3/24 dev eth1
```

## Credenciales de rys23_2
```
usuario / usuariorys
root -> superrys
```

# Parte 1 : Configuración del servidor LAMP
-------------------------------------------

1. En la máquina SERV (IP: 192.168.1.20 en enp0s8 con MTU 1500):
```
# 1. Configurar el MTU a 1500 (tamaño máximo del paquete)
sudo ip link set enp0s8 mtu 1500

# 2. Levantar la interfaz de red
sudo ip link set enp0s8 up

# 3. Asignar la dirección IP estática
sudo ip addr add 192.168.1.20/24 dev enp0s8
```

2. La distribución de Debian que estamos utilizando ya trae instalado el SW para un servidor apache2. Instala el software de php y el cortafuegos UFW (Uncomplicated Firewall):
```
sudo apt-get update
sudo apt-get install firewalld
sudo apt-get install php php-common (opcional)
```
Hay una inconsistencia importante en las instrucciones proporcionadas: el texto menciona instalar
UFW, pero el comando de ejemplo utiliza firewalld. En Debian, son dos gestores de cortafuegos distintos y no deben usarse simultáneamente para evitar conflictos.

El propio sistema te está chivando la solución en el mensaje de error. Para arreglar esto y poder instalar tu cortafuegos y PHP, sigue estos pasos en orden:
```
# Paso 1: Reparar las dependencias rotas
sudo apt --fix-broken install

# Paso 2: Sincronizar y actualizar el sistema
sudo apt update
sudo apt upgrade -y

# Paso 3: Reintentar la instalación
sudo apt install firewalld php php-common -y
```

3. Comprobar la configuración de red asignada
```
ip addr show eth1
ip addr show enp0s8
```

4. Comprobar la conectividad bidireccional (Ping)
```
ping -c 4 192.168.1.20
ping -c 4 192.168.1.3
```

5. Pasos para configurar la IP de forma persistente en Kali
```
# 1. Crear un perfil de conexión llamado "Red1" para la interfaz eth1 con la IP estática
sudo nmcli connection add type ethernet ifname eth1 con-name "Red1" ipv4.addresses 192.168.1.3/24 ipv4.method manual

# 2. Levantar (activar) la conexión que acabamos de crear
sudo nmcli connection up "Red1"
```

6. Cómo colocar el nombre de servidor? 
```
# 1. Abre el archivo con un editor de texto (como nano):
sudo nano /etc/apache2/apache2.conf

# 2. Añade la directiva ServerName:
ServerName www.miserv.com

# 3. Comprueba que no hay errores y aplica los cambios:
sudo apache2ctl configtest
sudo systemctl reload apache2
```

7. Ejecuta esto en la terminal de Kali para añadir la línea directamente al final del archivo de hosts:
```
echo "192.168.1.20 www.miserv.com" | sudo tee -a /etc/hosts

# ping -c 2 www.miserv.com
```

8. ¿Cuál es el problema entonces? (El Cortafuegos)
```
# 0. Chequear si el cortafuegos los tiene activado?
sudo firewall-cmd --permanent --query-service=https

# 1. Permite el tráfico HTTP (puerto 80)
sudo firewall-cmd --add-service=http --permanent

# 2. Permite el tráfico HTTPS (puerto 443)
sudo firewall-cmd --add-service=https --permanent

# 3. Recarga para aplicar los cambios
sudo firewall-cmd --reload
```

9. Cambiar el nombre del HTML viejo y crear el nuevo PHP:
```
cd /var/www/html
sudo mv index.html iold.html
echo "<?php phpinfo(); ?>" | sudo tee info.php
```

10. Editar el archivo de configuración (el cambio del punto 2):
```
sudo nano /etc/apache2/mods-enabled/dir.conf

<IfModule mod_dir.c>
    DirectoryIndex info.php index.html index.cgi index.pl index.php index.xhtml index.htm
</IfModule>
```

11. Reiniciar Apache (punto 3):
```
sudo nano /etc/apache2/mods-enabled/dir.conf
```

12. Cómo completar este Ejercicio 4 (Desactivar PHP)
```
#Verificación: Ejecuta 
dpkg -l | grep libapache2-mod-php

# 0. Para activar el php, si está instalado
sudo a2enmod php7.4
sudo systemctl restart apache2

# 1. Descubre qué versión exacta de PHP tienes activa:
ls /etc/apache2/mods-enabled/ | grep php

# 2. Desactiva el módulo (Sustituye X.X por tu versión, ej: php7.4 o php8.2):
sudo a2dismod phpX.X

# 3. Reinicia Apache para aplicar el corte:
sudo systemctl restart apache2
```

# Parte 2: Configuración de un servidor web seguro: habilitar HTTPS
-------------------------------------------------------------------

13.0. Rectificar si tenemos certificado instalado
```
sudo ls -l /etc/ssl/private/servkey.pem /etc/ssl/certs/servcert.pem
```

13. Generación de certificado en la máquina SERV
```
sudo openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/servkey.pem -out /etc/ssl/certs/servcert.pem
```
`req -x509`: Le indica a OpenSSL que queremos generar directamente un certificado autofirmado (formato X.509), en lugar de generar una "petición" (CSR) para enviarla a una autoridad externa.

`-nodes`: Significa No DES. Le dice a OpenSSL que no proteja la clave privada con una contraseña. Esto es vital en servidores web; si le pusiéramos contraseña, Apache te la pediría a mano cada vez que reinicies la máquina.

`-newkey rsa:2048`: Crea una clave privada nueva utilizando el algoritmo RSA con una longitud segura de 2048 bits.

`-keyout` y `-out`: Las rutas donde se guardarán tu llave privada (servkey.pem, que nadie debe ver nunca) y tu certificado público (servcert.pem, que es el que se envía a los clientes).

14. Primero debes confirmar en tu terminal que los archivos están ahí y qué permisos tienen.
```
ls -l /etc/ssl/certs/servcert.pem /etc/ssl/private/servkey.pem
```

15. Ver el contenido del certificado y los algoritmos.
```
sudo openssl x509 -in /etc/ssl/certs/servcert.pem -noout -text
```

## Ejercicio 4. Completar la configuración https
1. Paso 1: Habilitar el módulo SSL (Si ahora hicieses un netstat -tan, verías que Apache ya empieza a escuchar por el puerto 443)
```
sudo a2enmod ssl
sudo systemctl restart apache2
```
2. Paso 2: Habilitar el sitio seguro por defecto
```
sudo a2ensite default-ssl
sudo systemctl reload apache2
```
3. Paso 3: Configurar tus propios certificados (¡Cuidado aquí!)
```
sudo nano /etc/apache2/sites-enabled/default-ssl.conf

SSLCertificateFile      /etc/ssl/certs/servcert.pem
SSLCertificateKeyFile   /etc/ssl/private/servkey.pem
```
4. Paso 4: Aplicar todos los cambios
```
sudo systemctl reload apache2
sudo systemctl restart apache2
```
5. Vete a tu máquina Kali, abre el navegador y escribe:
https://www.miserv.com
```
# Ver el navegador se Conectado
curl -Ik https://www.miserv.com

# Ver el certificado en bruto
openssl s_client -connect www.miserv.com:443

# Ver certificado bonito
echo | openssl s_client -connect www.miserv.com:443 2>/dev/null | openssl x509 -text -noout
```

## Ejercicio 6. Configuración del firewall para que solamente permita conexiones https.
## Parte 3: Auditar y mejorar la seguridad del servidor.
```
# 1. acceder
cd testssl.sh

# 2. Volver a lanzar la auditoría
./testssl.sh 192.168.1.20
```

# Parte 3: Auditar y mejorar la seguridad del servidor.
-------------------------------------------------------
Tres vulnerabilidades y como eliminarlas
```
1. Eliminación de Cifrados CBC (LUCKY13) Debes configurar Apache para que prefiera cifrados GCM (Galois/Counter Mode).
/etc/apache2/conf-available/security.conf

SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
SSLHonorCipherOrder on

4. Ocultar el Banner del Servidor
Tu reporte muestra Apache/2.4.66 (Debian). Esto da pistas a un atacante sobre qué vulnerabilidades específicas buscar para esa versión.
/etc/apache2/conf-enabled/security.conf

ServerTokens Prod
ServerSignature Off

5. Mejora ante LOGJAM
Aunque usas un grupo DH de 2048 bits (lo cual es bueno), el reporte menciona el uso de un "common prime".
1. En la terminal: openssl dhparam -out /etc/apache2/dhparams.pem 2048
2. En Apache (dentro del VirtualHost):
SSLOpenSSLConfCmd DHParameters "/etc/apache2/dhparams.pem"
```
