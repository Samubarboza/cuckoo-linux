#!/bin/bash
# Abre, cierra y controla los popups de eww (musica, sistema y wifi) desde waybar
# Uso: popup.sh toggle media|system|wifi | close | activity | nudge-cursor | previous|play-pause|next|quit

eww_config_dir="$(dirname "$(realpath "$0")")"
eww_command() { eww -c "$eww_config_dir" "$@"; }

# Cada accion dentro de un popup actualiza este archivo; sin actividad, el vigilante cierra todo
activity_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-popup-activity"
max_seconds_without_activity=30

# Ancho del popup de sistema, se ubica segun el click. El mismo de eww.yuck
system_popup_width=220

# El que esta sonando. Si nada suena (ej. pausaste Spotify), el ultimo que sono,
# asi los botones no saltan a otro reproductor como el navegador
last_player_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-last-player"
find_active_player() {
  playing_player=$(playerctl -l 2>/dev/null | while read -r name; do
    [[ "$(playerctl -p "$name" status 2>/dev/null)" = "Playing" ]] && echo "$name" && break
  done)
  if [[ -n "$playing_player" ]]; then
    echo "$playing_player" >"$last_player_file"
    echo "$playing_player"
    return
  fi
  last_player=$(cat "$last_player_file" 2>/dev/null)
  if [[ -n "$last_player" ]] && playerctl -l 2>/dev/null | grep -qxF "$last_player"; then
    echo "$last_player"
  else
    playerctl -l 2>/dev/null | head -n1
  fi
}

# Al abrir, la ventanita queda fija en un reproductor: botones e icono controlan siempre ese
popup_player_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-popup-player"
popup_player() {
  locked_player=$(cat "$popup_player_file" 2>/dev/null)
  if [[ -n "$locked_player" ]] && playerctl -l 2>/dev/null | grep -qxF "$locked_player"; then
    echo "$locked_player"
  else
    find_active_player
  fi
}

window_is_open() {
  eww_command active-windows 2>/dev/null | grep -q ": $1$"
}

# Cierra popup y fondo. Si algo queda abierto, apaga eww para no bloquear nunca la pantalla
close_all_popups() {
  eww_command update media_reveal=false system_reveal=false wifi_reveal=false 2>/dev/null
  sleep 0.22
  eww_command close-all 2>/dev/null
  if [[ -n "$(eww_command active-windows 2>/dev/null)" ]]; then
    eww_command kill 2>/dev/null
  fi
}

# Vigilante: cierra si el popup desaparece o si no hay actividad por un rato
watch_open_popup() {
  popup_name="$1"
  while sleep 1; do
    [[ -n "$(eww_command active-windows 2>/dev/null)" ]] || exit 0
    seconds_without_activity=$(($(date +%s) - $(stat -c %Y "$activity_file" 2>/dev/null || echo 0)))
    popup_still_open=false
    window_is_open "$popup_name-popup" && popup_still_open=true
    window_is_open "$popup_name-popup-typing" && popup_still_open=true
    if [[ "$popup_still_open" = false ]] || [[ "$seconds_without_activity" -gt "$max_seconds_without_activity" ]]; then
      close_all_popups
      exit 0
    fi
  done
}

# Hyprland no avisa a una ventana nueva que el puntero esta encima hasta que se mueve.
# Sin esto, un click sin mover el mouse (ej. en el mismo boton) no llega al fondo
nudge_cursor() {
  read -r cursor_x cursor_y <<<"$(hyprctl cursorpos | tr -d ',')"
  hyprctl dispatch movecursor $((cursor_x + 1)) "$cursor_y" >/dev/null
  hyprctl dispatch movecursor "$cursor_x" "$cursor_y" >/dev/null
}

# Posicion x del popup en el monitor con foco, segun el mouse. Usa medidas con zoom y
# nunca se sale de la pantalla. Con "right" su borde derecho va con el del boton (16px)
find_popup_x_position() {
  popup_width="$1"
  alignment="${2:-center}"
  read -r cursor_x _ <<<"$(hyprctl cursorpos 2>/dev/null | tr -d ',')"
  popup_x=$(hyprctl monitors -j 2>/dev/null | jq -r \
    --argjson cursor_x "${cursor_x:-0}" --argjson popup_width "$popup_width" --arg alignment "$alignment" '
        first(.[] | select(.focused)) as $monitor
        | ((if $monitor.transform % 2 == 1 then $monitor.height else $monitor.width end) / $monitor.scale) as $screen_width
        | ($cursor_x - $monitor.x) as $mouse_x
        | (if $alignment == "right" then $mouse_x + 16 - $popup_width else $mouse_x - $popup_width / 2 end) as $x
        | [[$x, $screen_width - $popup_width] | min, 0] | max | floor' 2>/dev/null)
  echo "${popup_x:-0}"
}

open_popup() {
  if [[ "$1" = "media" ]]; then
    active_player=$(find_active_player)
    if [[ -z "$active_player" ]]; then
      notify-send "Música" "No hay ningún reproductor activo"
      exit 0
    fi
    echo "$active_player" >"$popup_player_file"
  fi
  # La primera vez eww tarda en arrancar: esperar a que responda
  if ! eww_command ping >/dev/null 2>&1; then
    eww_command daemon >/dev/null 2>&1
    for _ in $(seq 20); do
      eww_command ping >/dev/null 2>&1 && break
      sleep 0.1
    done
  fi
  eww_command close-all 2>/dev/null
  touch "$activity_file"
  [[ "$1" = "media" ]] && eww_command update media_status="$(playerctl -p "$(popup_player)" status 2>/dev/null)"
  focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .id')
  if [[ "$1" = "wifi" ]]; then
    eww_command update wifi_selected="" wifi_password="" wifi_show_password=false wifi_connecting=""
    nmcli dev wifi rescan >/dev/null 2>&1 &
  fi
  # Primero los fondos que detectan el click afuera (uno por monitor), despues el popup encima.
  # El popup de wifi trae su propio fondo en su monitor
  for monitor_id in $(hyprctl monitors -j | jq -r '.[].id'); do
    if [[ "$monitor_id" != "$focused_monitor" ]] || [[ "$1" != "wifi" ]]; then
      eww_command open popup-backdrop --id "backdrop-$monitor_id" --screen "$monitor_id"
    fi
  done
  if [[ "$1" = "system" ]]; then
    system_popup_x=$(find_popup_x_position "$system_popup_width" right)
    eww_command open system-popup --screen "$focused_monitor" --pos "${system_popup_x}x0"
  else
    eww_command open "$1-popup" --screen "$focused_monitor"
  fi
  eww_command update "$1_reveal=true"
  nudge_cursor
  watch_open_popup "$1" </dev/null >/dev/null 2>&1 &
}

# Estado del mismo reproductor que controlan los botones. Se recalcula cada vez que
# cualquier reproductor cambia (playerctl -F solo sigue a uno y puede no ser el activo)
follow_active_player_status() {
  playerctl -a -F status 2>/dev/null | while read -r _; do
    playerctl -p "$(popup_player)" status 2>/dev/null
  done
}

quit_active_player() {
  active_player=$(popup_player)
  # En navegadores solo se detiene, para no cerrar todas las pestañas
  if [[ "$active_player" =~ firefox|chromium|chrome|brave|vivaldi|opera|edge|zen|librewolf ]]; then
    playerctl -p "$active_player" stop
  else
    dbus-send --session --type=method_call --dest="org.mpris.MediaPlayer2.$active_player" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Quit
  fi
}

case "$1" in
  toggle) if window_is_open "$2-popup" || window_is_open "$2-popup-typing"; then close_all_popups; else open_popup "$2"; fi ;;
  close) close_all_popups ;;
  activity) touch "$activity_file" ;;
  nudge-cursor) nudge_cursor ;;
  follow-status) follow_active_player_status ;;
  previous | play-pause | next)
    touch "$activity_file"
    playerctl -p "$(popup_player)" "$1"
    ;;
  quit)
    quit_active_player
    close_all_popups
    ;;
esac
