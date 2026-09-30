import Quickshell
import Quickshell.Io
import QtQuick

// Network state, only the icon. Click opens the wifi popup, wired in T7.
BarItem {
  id: root

  // "disabled" | "disconnected" | "ethernet" | "wifi <signal>:<essid>"
  property string state: "disconnected"
  readonly property bool connected: state.indexOf("wifi") === 0 || state === "ethernet"

  Text {
    text: root.icon()
    color: root.connected ? Theme.text : Theme.dim
    font.family: Theme.iconFont
    font.pixelSize: 16
  }

  Process {
    id: probe
    command: ["sh", "-c", "if [ \"$(nmcli radio wifi)\" = disabled ]; then echo disabled; exit 0; fi; w=$(nmcli -t -f ACTIVE,SIGNAL,SSID dev wifi 2>/dev/null | awk -F: '$1==\"yes\"{print $2\":\"$3; exit}'); if [ -n \"$w\" ]; then echo \"wifi $w\"; exit 0; fi; if nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -q '^ethernet:connected$'; then echo ethernet; exit 0; fi; echo disconnected"]
    stdout: StdioCollector {
      id: output
      onStreamFinished: root.state = output.text.trim()
    }
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: probe.running = true
  }

  function icon() {
    if (state === "disabled")
      return "󰖪";
    if (state.indexOf("wifi") === 0)
      return "";
    if (state === "ethernet")
      return "󰌘";
    return "󰤮";
  }
}
