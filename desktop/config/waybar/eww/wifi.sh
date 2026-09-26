#!/bin/bash
# Datos y acciones de wifi para el popup de eww (usa nmcli)
# Uso: wifi.sh list | autoconnect-state | toggle-radio | toggle-autoconnect | select <id> | connect <id> [password]

eww_config_dir="$(dirname "$(realpath "$0")")"
eww_command() { eww -c "$eww_config_dir" "$@"; }

# Las redes se identifican con base64 para no romper comandos con SSIDs raros
decode_network_id() { echo "$1" | base64 -d 2>/dev/null; }

active_connection_name() {
  nmcli -t -f NAME,TYPE connection show --active | grep ':802-11-wireless$' | head -n1 | sed 's/:802-11-wireless$//'
}

list_networks() {
  saved_networks=$(nmcli -t -f NAME,TYPE connection show | grep ':802-11-wireless$' | sed 's/:802-11-wireless$//')
  nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan no 2>/dev/null \
    | SAVED_NETWORKS="$saved_networks" python3 -c '
import sys, json, os, base64, re
saved = set(os.environ["SAVED_NETWORKS"].splitlines())
icons = ["\U000F092F", "\U000F091F", "\U000F0922", "\U000F0925", "\U000F0928"]
networks = {}
for line in sys.stdin:
    in_use, signal, security, ssid = re.split(r"(?<!\\):", line.rstrip("\n"), maxsplit=3)
    ssid = ssid.replace("\\:", ":")
    if not ssid:
        continue
    signal = int(signal or 0)
    network = {
        "id": base64.b64encode(ssid.encode()).decode(),
        "ssid": ssid,
        "signal": signal,
        "icon": icons[min(signal // 20, 4)],
        "secure": security not in ("", "--"),
        "saved": ssid in saved,
        "active": in_use == "*",
    }
    old = networks.get(ssid)
    if not old or network["active"] or (signal > old["signal"] and not old["active"]):
        networks[ssid] = network
ordered = sorted(networks.values(), key=lambda n: (not n["active"], -n["signal"]))
print(json.dumps(ordered[:12]))
'
}

autoconnect_state() {
  connection_name=$(active_connection_name)
  [ -z "$connection_name" ] && echo "none" && return
  nmcli -g connection.autoconnect connection show "$connection_name"
}

toggle_autoconnect() {
  connection_name=$(active_connection_name)
  [ -z "$connection_name" ] && return
  if [ "$(autoconnect_state)" = "yes" ]; then new_state="no"; else new_state="yes"; fi
  nmcli connection modify "$connection_name" connection.autoconnect "$new_state"
  eww_command update wifi_autoconnect="$new_state"
}

toggle_radio() {
  if [ "$(nmcli radio wifi)" = "enabled" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi
  eww_command update wifi_radio="$(nmcli radio wifi)"
}

# Click en una red: si ya es conocida o abierta se conecta, si no pide contraseña
select_network() {
  network_id="$1"
  ssid=$(decode_network_id "$network_id")
  network_data=$(eww_command get wifi_networks | jq -c --arg ssid "$ssid" '.[] | select(.ssid == $ssid)')
  if [ "$(echo "$network_data" | jq -r '.active')" = "true" ]; then
    return
  fi
  if [ "$(echo "$network_data" | jq -r '.saved')" = "true" ] || [ "$(echo "$network_data" | jq -r '.secure')" = "false" ]; then
    connect_network "$network_id" ""
  else
    eww_command update wifi_selected="$network_id" wifi_show_password=false
    # Cambiar a la version con teclado para poder escribir la contraseña
    if ! eww_command active-windows | grep -q ": wifi-popup-typing$"; then
      focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .id')
      eww_command open wifi-popup-typing --screen "$focused_monitor"
      eww_command close wifi-popup
      "$eww_config_dir/popup.sh" nudge-cursor
    fi
  fi
}

connect_network() {
  ssid=$(decode_network_id "$1")
  typed_password="$2"
  eww_command update wifi_connecting="$1"
  if [ -n "$typed_password" ]; then
    nmcli dev wifi connect "$ssid" password "$typed_password" >/dev/null 2>&1
  elif nmcli -t -f NAME connection show | grep -qxF "$ssid"; then
    nmcli connection up id "$ssid" >/dev/null 2>&1
  else
    nmcli dev wifi connect "$ssid" >/dev/null 2>&1
  fi
  connection_status=$?
  eww_command update wifi_connecting="" wifi_selected=""
  if [ "$connection_status" -eq 0 ]; then
    notify-send "Wi-Fi" "Conectado a $ssid"
  else
    # Si fallo con contraseña nueva, no guardar una conexion rota
    [ -n "$typed_password" ] && nmcli connection delete id "$ssid" >/dev/null 2>&1
    notify-send "Wi-Fi" "No se pudo conectar a $ssid. Revisá la contraseña."
  fi
  eww_command update wifi_networks="$(list_networks)"
}

# Las acciones cuentan como actividad para que el popup no se cierre solo
[[ "$1" =~ ^(toggle-radio|toggle-autoconnect|select|connect)$ ]] && touch "${XDG_RUNTIME_DIR:-/tmp}/waybar-popup-activity"

case "$1" in
  list) list_networks ;;
  autoconnect-state) autoconnect_state ;;
  toggle-radio) toggle_radio ;;
  toggle-autoconnect) toggle_autoconnect ;;
  select) select_network "$2" ;;
  connect) connect_network "$2" "$3" ;;
esac
