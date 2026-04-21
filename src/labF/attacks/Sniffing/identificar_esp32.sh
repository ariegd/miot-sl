#!/bin/bash

# ==============================================================================
# Script de Auditoría IoT: Identificación de ESP32 en Red Externa (Lab_Movil)
# ==============================================================================

INTERFACE="wlxccbabd6179b5"
SSID_OBJETIVO="Lab_Movil"

echo "🛡️ Iniciando Auditoría de Seguridad para el SSID: $SSID_OBJETIVO"

# 1. Asegurar que la tarjeta está administrada por el sistema y encendida
echo "[*] Preparando interfaz para escaneo de redes..."
sudo nmcli device set $INTERFACE managed yes
sudo ip link set $INTERFACE up

# Forzar un escaneo nuevo para no usar datos antiguos en caché
echo "[*] Forzando escaneo del espectro Wi-Fi (esto tomará unos segundos)..."
sudo nmcli dev wifi rescan ifname $INTERFACE
sleep 4 # Damos tiempo a que se rellene la lista de redes

# 2. Localizar el Canal de la red usando NetworkManager
echo "[*] Localizando canal de $SSID_OBJETIVO..."
# Extraemos el SSID y el Canal, filtramos por tu red y sacamos solo el número
CANAL=$(nmcli -t -f SSID,CHAN dev wifi list ifname $INTERFACE | grep "^$SSID_OBJETIVO:" | cut -d: -f2 | head -n 1)

if [ -z "$CANAL" ]; then
    echo "❌ Error: No se encontró la red $SSID_OBJETIVO. "
    echo "🔍 Comprobación manual: Ejecuta 'nmcli dev wifi list ifname $INTERFACE' para ver si tu PC detecta la red del móvil."
    exit 1
fi
echo "✅ Red detectada en el CANAL: $CANAL."

# 3. Pasar la tarjeta a Modo Monitor de forma segura
echo "[*] Aislando la interfaz y cambiando a Modo Monitor..."
sudo nmcli device set $INTERFACE managed no
sudo ip link set $INTERFACE down
sudo iw dev $INTERFACE set type monitor
sudo ip link set $INTERFACE up

# 4. Sintonizar el canal detectado
echo "[*] Sintonizando adaptador en el canal $CANAL..."
sudo iw dev $INTERFACE set channel $CANAL

# 5. Iniciar Sniffing de Tramas de Datos (Capa 2)
echo "--------------------------------------------------------------------------"
echo "[*] Iniciando Sniffing de tramas de datos Wi-Fi..."
echo "TIP: Tu ESP32 será la MAC en 'wlan.ta' (Transmisor) que envíe datos constantemente."
echo "Presiona Ctrl+C para detener."
echo "--------------------------------------------------------------------------"

# Usamos filtros de Wireshark (-Y) para ver solo tramas de datos (type == 2)
# wlan.ta = MAC origen (Transmisor) | wlan.ra = MAC destino (Receptor/Móvil)
sudo tshark -i $INTERFACE -Y "wlan.fc.type == 2" \
    -T fields -e wlan.ta -e wlan.ra -e frame.len -e radiotap.dbm_antsignal \
    -E header=y -E separator=,
