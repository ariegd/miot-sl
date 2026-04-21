#!/bin/bash

# ==============================================================================
# Script de Auditoría IoT: Interceptación y Descifrado WPA2 (MQTT/MQTTS)
# ==============================================================================

INTERFACE="wlxccbabd6179b5"
SSID_OBJETIVO="Lab_Movil"
CLAVE_WIFI="hogz7998"

echo "🛡️ Iniciando Módulo de Descifrado para: $SSID_OBJETIVO"

# 1. Preparación y Búsqueda de Canal
echo "[*] Escaneando red para sintonizar el canal..."
sudo nmcli device set $INTERFACE managed yes
sudo ip link set $INTERFACE up
sudo nmcli dev wifi rescan ifname $INTERFACE
sleep 4 

CANAL=$(nmcli -t -f SSID,CHAN dev wifi list ifname $INTERFACE | grep "^$SSID_OBJETIVO:" | cut -d: -f2 | head -n 1)

if [ -z "$CANAL" ]; then
    echo "❌ Error: Red no encontrada."
    exit 1
fi

echo "✅ Red en CANAL $CANAL. Preparando Modo Monitor..."

# 2. Pasar a Modo Monitor
sudo nmcli device set $INTERFACE managed no
sudo ip link set $INTERFACE down
sudo iw dev $INTERFACE set type monitor
sudo ip link set $INTERFACE up
sudo iw dev $INTERFACE set channel $CANAL

# 3. Iniciar Captura con Descifrado y depuración de Handshake
echo "--------------------------------------------------------------------------"
echo "🚨 ACCIÓN REQUERIDA: Reinicia el ESP32 AHORA."
echo "[*] Buscando Handshake (EAPOL) y puertos 1883/8883..."
echo "--------------------------------------------------------------------------"

# Hemos añadido 'eapol' al filtro -Y y 'eapol.type' a las columnas.
sudo tshark -i $INTERFACE \
    -o wlan.enable_decryption:TRUE \
    -o "uat:80211_keys:\"wpa-pwd\",\"$CLAVE_WIFI:$SSID_OBJETIVO\"" \
    -Y "eapol or tcp.port == 1883 or tcp.port == 8883" \
    -T fields -e wlan.ta -e ip.src -e ip.dst -e eapol.type -e tcp.port -e mqtt.msg \
    -E header=y -E separator=,
