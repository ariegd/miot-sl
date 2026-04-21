 ---

**📡 Módulo de Sniffing e Interceptación (Capa 2 y Capa 4\)**

Este módulo se enfoca en la fase de **Reconocimiento** y **Explotación de Confidencialidad**. A través de estos scripts, el auditor puede identificar la presencia del dispositivo IoT en el espectro radioeléctrico y, posteriormente, romper el cifrado Wi-Fi para visualizar la telemetría enviada a la nube.

**⚠️ ADVERTENCIA:** El descifrado de tráfico requiere la captura previa de un "4-Way Handshake". Es imperativo que el dispositivo objetivo se reconecte mientras el sniffer está activo.

 ---

**🛠️ Instalación de Herramientas**

Para ejecutar estos scripts en **Debian/Kali Linux**, es necesario instalar las siguientes dependencias de red y análisis de protocolos:

```
Bash

\# Actualizar repositorios  
sudo apt update

\# Instalar herramientas de auditoría inalámbrica y análisis  
sudo apt install \-y aircrack-ng tshark network-manager wireless-tools
```

* **Aircrack-ng:** Suite para gestión de interfaces en modo monitor.  
* **Tshark:** Versión de terminal de Wireshark para la captura y descifrado de paquetes.  
* **NetworkManager (nmcli):** Utilizado para el escaneo inicial de canales.  
* **Wireless-tools (iw):** Para la sintonización precisa de la frecuencia del adaptador.

 ---

**📂 Scripts del Módulo**

### **1\. identificar\_esp32.sh (Sniffing Pasivo \- Capa 2\)**

Este script realiza un escaneo silencioso. No necesita la contraseña de la red para detectar al objetivo.

* **Funcionamiento:** Sintoniza el canal de Lab\_Movil y filtra por tramas de datos (type 2).  
* **Uso:** 
```
bash  
  chmod \+x identificar\_esp32.sh  
  sudo ./identificar\_esp32.sh  
```
* **Resultado esperado:** Visualización de la dirección MAC 58:8C:81:20:63:E4 enviando paquetes de forma constante (cada 5 segundos).

### **2\. descifrar\_mqtt.sh (Interceptación Activa \- Capa 4\)**

Este script utiliza la clave WPA2 (hogz7998) para "abrir" los paquetes cifrados.

* **Funcionamiento:** Inyecta la clave en el motor de descifrado de tshark. Captura el tráfico y lo traduce de hexadecimal a ASCII en tiempo real.  
* **Uso:**  
```
  Bash  
  chmod \+x descifrar\_mqtt.sh  
  sudo ./descifrar\_mqtt.sh
```
* **Acción Crítica:** Cuando el script indique "Buscando Handshake", se debe reiniciar el ESP32 para capturar las llaves de sesión.

 ---

**📊 Análisis de Riesgos (SyL)**

Al ejecutar estas herramientas, se han validado los siguientes hallazgos:

1. **Exposición de Telemetría:** Se confirma que el payload MQTT es visible: {"rssi":-26,"intervalo":5000}.  
2. **Falta de TLS:** El uso del puerto **1883** es el vector principal de fallo. Toda la lógica de negocio del sensor queda expuesta.  
3. **Huella Digital:** El dispositivo es fácilmente identificable mediante el análisis del intervalo de transmisión, incluso sin descifrar el contenido.

 ---

**🛡️ Medidas de Mitigación**

Para neutralizar este módulo de ataque, se recomienda:

* **Implementar MQTTS (Puerto 8883):** El uso de TLS 1.2/1.3 haría que el script descifrar\_mqtt.sh solo mostrara datos cifrados e ilegibles.  
* **Ocultación de SSID:** Aunque no es una medida definitiva, dificulta el escaneo inicial automatizado.

 ---

**📝 Referencias**

* *Asistido por Gemini 3.1 Pro para la optimización de filtros tshark.*  
* *Basado en la Guía de Reconocimiento de INCIBE-CERT (2023).*

---

