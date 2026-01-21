#!/bin/bash
# Script de instalación CHARLY EL IMPARABLE

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'

echo -e "${CYAN}============================================================${RESET}"
echo -e "${YELLOW} INSTALADOR CHARLY EL IMPARABLE${RESET}"
echo -e "${CYAN}============================================================${RESET}"

# Actualizar sistema
apt update -y && apt upgrade -y

# Instalar Python3
apt install -y python3 python3-pip

# Crear carpeta y archivo proxy
mkdir -p /etc/ADMcgh
touch /etc/ADMcgh/PDirect.py
echo -e "${GREEN}>>> Archivo PDirect.py creado en /etc/ADMcgh${RESET}"

# Crear servicio systemd
tee /etc/systemd/system/proxy-charly.service > /dev/null << 'EOF'
[Unit]
Description=Proxy Python CHARLY EL IMPARABLE
After=network.target

[Service]
ExecStart=/usr/bin/python3 /etc/ADMcgh/PDirect.py
Restart=always
RestartSec=5
User=root
WorkingDirectory=/etc/ADMcgh

[Install]
WantedBy=multi-user.target
EOF
echo -e "${GREEN}>>> Servicio proxy-charly.service creado${RESET}"

# Activar servicio
systemctl daemon-reload
systemctl enable proxy-charly.service
systemctl start proxy-charly.service
echo -e "${GREEN}>>> Servicio proxy-charly activado${RESET}"

# Crear panel
tee /usr/local/bin/panel-charly.sh > /dev/null << 'EOF'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'
while true; do
    clear
    echo -e "${CYAN}============================================================${RESET}"
    echo -e "${YELLOW} PANEL CHARLY EL IMPARABLE${RESET}"
    echo -e "${CYAN}============================================================${RESET}"
    echo -e "${GREEN}1) Crear usuario${RESET}"
    echo -e "${GREEN}2) Eliminar usuario${RESET}"
    echo -e "${GREEN}3) Ver usuarios creados${RESET}"
    echo -e "${GREEN}4) Reiniciar proxy-charly.service${RESET}"
    echo -e "${GREEN}5) Ver logs del proxy${RESET}"
    echo -e "${GREEN}6) Ver clientes conectados al puerto 80${RESET}"
    echo -e "${RED}7) Salir${RESET}"
    read -p "Selecciona una opción: " opcion
    case $opcion in
        1) read -p "Usuario: " user; adduser "$user";;
        2) read -p "Usuario: " user; deluser "$user";;
        3) awk -F: '$3 >= 1000 {print $1}' /etc/passwd;;
        4) systemctl daemon-reload && systemctl restart proxy-charly.service;;
        5) journalctl -u proxy-charly.service -n 10 --no-pager;;
        6) ss -tnp | grep ':80' || echo "No hay clientes conectados";;
        7) exit 0;;
    esac
    read -p "Enter para continuar..."
done
EOF
chmod +x /usr/local/bin/panel-charly.sh
echo -e "${GREEN}>>> Panel CHARLY instalado en /usr/local/bin/panel-charly.sh${RESET}"

# Instalar Dropbear
apt install -y dropbear
sed -i 's/^NO_START=1/NO_START=0/' /etc/default/dropbear
echo 'DROPBEAR_PORT=445' | tee -a /etc/default/dropbear
systemctl restart dropbear
systemctl enable dropbear
echo -e "${GREEN}>>> Dropbear configurado en puerto 445${RESET}"

# Lanzar panel
/usr/local/bin/panel-charly.sh
