| Supported Targets | ESP32 | ESP32-C2 | ESP32-C3 | ESP32-C5 | ESP32-C6 | ESP32-C61 | ESP32-H2 | ESP32-H21 | ESP32-H4 | ESP32-P4 | ESP32-S2 | ESP32-S3 | Linux |
| ----------------- | ----- | -------- | -------- | -------- | -------- | --------- | -------- | --------- | -------- | -------- | -------- | -------- | ----- |

# **🛡️ Auditoría de Seguridad IoT: Vectores de Ataque sobre ESP32-C6**

Este repositorio contiene la documentación técnica, el código fuente y los scripts de ataque utilizados en la auditoría de seguridad real realizada sobre un ecosistema IoT basado en el microcontrolador **ESP32-C6** y la plataforma **ThingsBoard Cloud**.

**⚠️ AVISO LEGAL:** Todo el material contenido en este repositorio ha sido desarrollado con fines exclusivamente educativos y de auditoría ética dentro del marco de la asignatura **Seguridad y Legalidad (SyL)** de la Universidad Complutense de Madrid. El uso de estas herramientas contra infraestructuras ajenas sin autorización es ilegal.

---

**📂 Estructura del Proyecto**

A continuación se detalla la organización de los módulos del laboratorio:

Plaintext
```
.  
├── attacks/                  \# Módulos de explotación y auditoría inalámbrica  
│   ├── DoS/                  \# Ataques de Denegación de Servicio (Deauth)  
│   ├── MitM/                 \# Interceptación Man-in-the-Middle (Evil Twin)  
│   └── Sniffing/             \# Reconocimiento y descifrado de tráfico MQTT  
├── rssi_thingsboard/         \# Firmware del nodo IoT (ESP-IDF)  
│   ├── main/                 \# Lógica principal del sensor  
│   └── components/           \# Librerías personalizadas (WiFi/MQTTS)  
└── README.md                 \# Este archivo (Guía Central)
```

---

**🛠️ Entorno de Hardware**

Para replicar esta auditoría se utilizó el siguiente inventario:

1. **Atacante:** Laptop Debian \+ Dongle TP-Link (Modo Monitor).  
2. **Víctima IoT:** ESP32-C6 (MAC: 58:8C:81:20:63:E4).  
3. **Gateway:** Samsung Smartphone (Hotspot: Lab\_Movil).  
4. **Monitorización:** Laptop Windows (Dashboard de ThingsBoard).

---

**🚀 Módulos de Auditoría (Enlaces Directos)**

Cada ataque tiene su propia documentación detallada sobre cómo ejecutarlo y qué scripts intervienen:

### **📡 [1\. Módulo de Sniffing](https://www.google.com/search?q=./attacks/Sniffing/README.md)**

* **Scripts:** identificar\_esp32.sh, descifrar\_mqtt.sh  
* **Objetivo:** Identificación pasiva del dispositivo y extracción de telemetría MQTT en texto plano mediante el descifrado de la capa WPA2.

### **🚫 [2\. Módulo de Denegación de Servicio (DoS)](https://www.google.com/search?q=./attacks/DoS/README.md)**

* **Scripts:** ataque\_iot.sh  
* **Objetivo:** Interrupción de la disponibilidad del servicio IoT mediante tramas de desautenticación forjadas.

### **🎭 [3\. Módulo de Man-in-the-Middle (MitM)](https://www.google.com/search?q=./attacks/MitM/README.md)**

* **Scripts:** evil\_twin.sh, evil\_twin\_movil.conf  
* **Objetivo:** Suplantación del punto de acceso legítimo para la interceptación y manipulación total de los datos enviados a la nube.

---

**🔌 Implementación del Nodo IoT (Firmware)**

El código fuente del dispositivo auditado se encuentra en la carpeta [**rssi\_thingsboard**](https://www.google.com/search?q=./rssi_thingsboard/README.md). Está desarrollado bajo el framework **ESP-IDF v5.x** y utiliza un diseño basado en una Máquina de Estados Finitos (FSM) para la gestión de eventos de red.

### **⚠️ Vulnerabilidad Identificada**

En la versión inicial del proyecto, la telemetría se envía a través del **puerto 1883 (MQTT)** sin cifrado TLS, lo que permite el éxito de los ataques descritos anteriormente.

---

**📚 Bibliografía de Referencia**

Este proyecto se apoya en las guías de buenas prácticas de:

* **INCIBE-CERT:** Guías de seguridad en comunicaciones inalámbricas y SCI.  
* **Asistencia técnica:** Redacción y optimización de código asistida por Gemini 3.1 Pro.

---

