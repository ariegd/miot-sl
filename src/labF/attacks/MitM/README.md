 ---

🎭 Módulo de Man-in-the-Middle (Evil Twin)

Este módulo describe la ejecución de un ataque de **Gemelo Malvado (Evil Twin)**. El objetivo es crear un punto de acceso falso con el mismo nombre (SSID) que el original (Lab\_Movil) para forzar al ESP32 a conectarse a la estación del auditor en lugar de al smartphone legítimo.

**⚠️ ADVERTENCIA:** Este ataque permite la interceptación completa, modificación y redirección del tráfico. Es una violación crítica de la integridad y confidencialidad de los datos.

 ---

**🛠️ Instalación de Herramientas**

Para levantar el punto de acceso falso y gestionar el enrutamiento de red en **Debian**, se requieren herramientas de gestión de AP, servidores de red y utilidades de firewall:
```
Bash

# Actualizar los índices de paquetes  
sudo apt update

# Instalar las herramientas necesarias  
sudo apt install -y hostapd dnsmasq iptables wireless-tools
```
* **hostapd:** Permite transformar la tarjeta Wi-Fi USB en un punto de acceso de grado industrial.  
* **dnsmasq:** Proporciona los servicios de DHCP (asignación de IP) y DNS al dispositivo víctima.  
* **iptables:** Utilizado para configurar el NAT (Network Address Translation) y permitir que el tráfico de la víctima salga a Internet a través de la interfaz cableada/interna del atacante.

 ---

**📂 Scripts y Configuración**

### **1\. evil\_twin\_movil.conf**

Es el archivo de parámetros para hostapd. Define que la red se llamará Lab\_Movil, usará el canal 1 y la tecnología WPA2.

* **Nota:** Se ha configurado para clonar las características físicas detectadas en la fase de reconocimiento.

### **2\. evil\_twin.sh**

El script de orquestación que realiza las siguientes acciones:

1. **Limpieza:** Mata procesos que puedan bloquear la tarjeta (como NetworkManager).  
2. **Red:** Configura la interfaz virtual 10.0.0.1 para la red de ataque.  
3. **Puente:** Activa el reenvío de IP (ip\_forward) y las reglas de NAT para que el ESP32 siga teniendo acceso a ThingsBoard (evitando sospechas).  
4. **Lanzamiento:** Inicia hostapd y dnsmasq simultáneamente.

### **Instrucciones de uso:**
```
Bash

# 1. Dar permisos  
chmod +x evil_twin.sh

# 2. Ejecutar (requiere privilegios de root para gestionar interfaces y firewall)  
sudo ./evil_twin.sh
```
 ---

**📊 Hallazgos de la Auditoría**

Tras la ejecución de este módulo, se validó lo siguiente:

* **Transparencia:** El ESP32 se asocia al AP falso automáticamente debido a que el atacante ofrece una señal más fuerte (proximidad).  
* **Control de Tráfico:** Al ser el "router", el atacante puede ver todas las peticiones DNS y capturar el tráfico MQTT sin necesidad de estar en modo monitor una vez establecida la conexión.  
* **Persistencia:** Incluso si el hotspot original vuelve, el dispositivo tiende a quedarse en el "Gemelo Malvado" si no hay validaciones adicionales.

 ---

**🛡️ Medidas de Protección (Mitigación)**

Como se detalló en el informe de Seguridad y Legalidad, la protección contra este ataque se basa en:

1. **Verificación de BSSID (MAC Pinning):** Configurar el firmware del ESP32 para que solo se conecte si el SSID es Lab\_Movil **Y** la dirección MAC es la del Samsung original.  
2. **MQTTS con Validación de Certificado:** Aunque el atacante intercepte el tráfico, si se usa TLS con validación de CA, el atacante no podrá suplantar al servidor de ThingsBoard, ya que no posee la clave privada del certificado legítimo.

 ---

**📝 Referencias**

* *Configuración basada en la Guía de Acceso Seguro a Dispositivos de Campo de INCIBE-CERT.*  
* *Asistencia en el enrutamiento de red y NAT: Gemini 3.1 Pro.*

---

