#!/bin/bash
# Instalador CHARLY EL IMPARABLE

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'

echo -e "${CYAN}=============================================================${RESET}"
echo -e "${YELLOW} INSTALADOR CHARLY EL IMPARABLE${RESET}"
echo -e "${CYAN}=============================================================${RESET}"

# Actualizar sistema
apt update -y && apt upgrade -y

# Instalar Python3
apt install -y python3 python3-pip

# Crear carpeta y archivo proxy con contenido
mkdir -p /etc/ADMcgh
cat << 'EOF' > /etc/ADMcgh/PDirect.py
#!/usr/bin/env python3
import socket, threading, time

BUFFER = 65536
SSH_TARGET_HOST = "127.0.0.1"
SSH_TARGET_PORT = 22

def forward(source, destination, tag):
    try:
        while True:
            data = source.recv(BUFFER)
            if not data:
                break
            destination.sendall(data)
            time.sleep(0.001)
    except Exception as e:
        print(f"[FORWARD {tag} ERROR] {e}")
    finally:
        try: source.shutdown(socket.SHUT_RD)
        except: pass
        try: destination.shutdown(socket.SHUT_WR)
        except: pass

def handle_client(c, addr):
    try:
        text = c.recv(BUFFER).decode(errors="ignore")
        low = text.lower()
        print(f"[CLIENT] {addr} -> {text.splitlines()[0] if text else 'NO DATA'}")

        if ("upgrade: websocket" in low) or text.startswith("HTTP/2.0") or ("content-length:" in low):
            c.sendall(b"HTTP/1.1 200 Connection established charli\r\n\r\n")
            print(">>> Respuesta: 200 Connection established charli")

            target = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            target.connect((SSH_TARGET_HOST, SSH_TARGET_PORT))
            print(f"[FORWARD] -> {SSH_TARGET_HOST}:{SSH_TARGET_PORT}")

            t1 = threading.Thread(target=forward, args=(c, target, "C->S"), daemon=True)
            t2 = threading.Thread(target=forward, args=(target, c, "S->C"), daemon=True)
            t1.start(); t2.start()
            t1.join(); t2.join()
        else:
            c.sendall(b"HTTP/1.1 400 Bad Request\r\n\r\n")
            print(">>> Respuesta: 400 Bad Request")
    except Exception as e:
        print(f"[CLIENT ERROR] {e}")
    finally:
        try: c.close()
        except: pass

def main():
    print("^^^^^^^^^^^^^^^^ PROXY PYTHON WEBSOCKET ^^^^^^^^^^^^^^^^")
    print(f"IP: 0.0.0.0\nPORTA: 80")
    print("^^^^^^^^^^^^^^^^ CHARLY EL IMPARABLE ^^^^^^^^^^^^^^^^^^^")

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("0.0.0.0", 80))
    s.listen(100)
    print("[OK] Listening on 0.0.0.0:80")

    while True:
        c, addr = s.accept()
        threading.Thread(target=handle_client, args=(c, addr), daemon=True).start()

if __name__ == "__main__":
    main()
EOF

echo -e "${GREEN}>>> Archivo PDirect.py creado con lógica del proxy${RESET}"

# Crear servicio systemd
cat << 'EOF' > /etc/systemd/system/proxy-charly.service
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

# Recargar systemd y habilitar servicio
systemctl daemon-reload
systemctl enable proxy-charly.service
systemctl start proxy-charly.service

echo -e "${GREEN}>>> Servicio proxy-charly.service instalado y activo${RESET}"

# Crear panel interactivo con estilo ASCII
cat << 'EOF' > /usr/local/bin/panel-charly.sh
#!/bin/bash
# ╔════════════════════════════════════════════════════════════╗
# ║   🔥 PANEL CHARLY EL IMPARABLE 🔥                          ║
# ╚════════════════════════════════════════════════════════════╝

while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║   🔥 PANEL CHARLY EL IMPARABLE 🔥                          ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "1) Crear usuario"
    echo "2) Eliminar usuario"
    echo "3) Ver usuarios creados"
    echo "4) Reiniciar proxy-charly.service"
    echo "5) Ver logs del proxy"
    echo "6) Ver clientes conectados al puerto 80"
    echo "7) Salir"
    echo ""
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1)
        
    read -p "Ingrese nombre de usuario: " user
    useradd -m -s /bin/bash "$user"
    echo ">>> Usuario $user creado. Ahora configure la contraseña:"
    passwd "$user"
    read -p "Presiona Enter para continuar..."
    ;;

        2)
            read -p "Ingrese nombre de usuario a eliminar: " user
            deluser "$user"
            echo ">>> Usuario $user eliminado."
            read -p "Presiona Enter para continuar..."
            ;;
        3)
            echo ">>> Usuarios creados en el sistema:"
            awk -F: '$3 >= 1000 {print $1}' /etc/passwd
            read -p "Presiona Enter para continuar..."
            ;;
        4)
            echo ">>> Reiniciando servicio proxy-charly.service..."
            systemctl restart proxy-charly.service
            systemctl is-active proxy-charly.service
            read -p "Presiona Enter para continuar..."
            ;;
        5)
            echo ">>> Últimos 10 logs del proxy:"
            journalctl -u proxy-charly.service -n 10 --no-pager
            read -p "Presiona Enter para continuar..."
            ;;
        6)
            echo ">>> Clientes conectados al proxy (puerto 80):"
            ss -tnp | grep ':80' || echo "No hay clientes conectados en :80"
            read -p "Presiona Enter para continuar..."
            ;;
        7)
            echo "Saliendo del Panel Charly..."
            exit 0
            ;;
        *)
            echo "Opción inválida."
            read -p "Presiona Enter para continuar..."
            ;;
    esac
done
EOF

chmod +x /usr/local/bin/panel-charly.sh
echo -e "${GREEN}>>> Panel de usuario instalado en /usr/local/bin/panel-charly.sh${RESET}"

# Lanzar el panel automáticamente al terminar la instalación
/usr/local/bin/panel-charly.sh
