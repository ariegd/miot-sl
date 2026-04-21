 ---

**🚫 Módulo de Denegación de Servicio (DoS)**

Este módulo tiene como objetivo evaluar la disponibilidad del dispositivo IoT mediante la ejecución de un ataque de **desautenticación Wi-Fi**. Este ataque explota una debilidad inherente en el estándar IEEE 802.11 (versiones anteriores a WPA3), donde las tramas de gestión (management frames) viajan sin cifrar.

**⚠️ ADVERTENCIA:** Este ataque interrumpe la conectividad del dispositivo. En un entorno real, esto podría impedir el envío de alertas críticas o el control remoto del hardware.

 ---

**🛠️ Instalación de Herramientas**

Para ejecutar el script de ataque en **Debian**, necesitas las utilidades de la suite aircrack-ng y las herramientas de gestión de red inalámbrica:
```
Bash

# Actualizar los índices de paquetes  
sudo apt update

# Instalar las herramientas necesarias  
sudo apt install -y aircrack-ng network-manager wireless-tools
```

* **aireplay-ng:** La herramienta principal para la inyección de tramas de desautenticación.  
* **nmcli / network-manager:** Utilizado para escanear y localizar el canal de la red objetivo de forma automática.  
* **iw / wireless-tools:** Permite configurar la interfaz física en Modo Monitor y sintonizar la frecuencia.

 ---

**📂 Script del Módulo: ataque\_iot.sh**

El script automatiza todo el proceso de "derribo" de la conexión del ESP32-C6.

### **Funcionamiento lógico:**

1. **Localización:** Escanea el entorno buscando el SSID Lab\_Movil.  
2. **Sintonización:** Configura el Dongle USB TP-Link en el mismo canal que el punto de acceso.  
3. **Inyección:** Envía ráfagas de paquetes "Deauth" suplantando la identidad del router (BSSID Samsung) hacia la dirección MAC específica del ESP32.

### **Instrucciones de uso:**
```
Bash

# 1. Dar permisos de ejecución  
chmod +x ataque_iot.sh

# 2. Ejecutar con privilegios de root (necesario para inyección de tráfico)  
sudo ./ataque_iot.sh
```
 ---

**📊 Hallazgos de la Auditoría**

Tras la ejecución de este módulo, se confirmaron los siguientes puntos críticos:

* **Efectividad Inmediata:** El ESP32 pierde la conexión en menos de 2 segundos tras iniciar el ataque.  
* **Reintento Infinito:** El firmware del dispositivo entra en un bucle de reconexión que consume recursos y batería, sin éxito mientras el ataque persista.  
* **Falta de Protección de Tramas:** Se confirma que ni el Gateway ni el dispositivo están utilizando **PMF (Protected Management Frames)**.

 ---

**🛡️ Medidas de Protección (Mitigación)**

Para proteger el entorno contra este tipo de ataques de denegación de servicio, se proponen las siguientes mejoras en la configuración:

1. **Activar PMF (802.11w):** Es la solución definitiva. Al cifrar las tramas de gestión, el ESP32 ignorará las órdenes de desconexión que no vengan firmadas criptográficamente por el router real.  
2. **Uso de WPA3:** El estándar WPA3 obliga al uso de PMF.  
3. **Detección de Anomalías:** Configurar alertas en la plataforma (ThingsBoard) para avisar si el dispositivo deja de enviar telemetría por más de un intervalo de tiempo definido (LWT \- Last Will and Testament).

 ---

**📝 Referencias**

* *Metodología basada en la Guía de Comunicaciones Inalámbricas de INCIBE-CERT.*  
* *Asistencia técnica para la automatización del script: Gemini 3.1 Pro.*

---

