import Quickshell
import Quickshell.Io
import QtQuick

// Screen brightness icon. Click opens the popup. Hidden if there is no backlight.
BarItem {
  id: root
  property bool available: false
  visible: available

  Text {
    text: String.fromCodePoint(0xf00df)
    color: Theme.text
    font.family: Theme.iconFont
    font.pixelSize: 16
  }

  Process {
    id: probe
    command: ["sh", "-c", "brightnessctl -m 2>/dev/null | cut -d, -f5"]
    running: true
    stdout: StdioCollector { id: out; onStreamFinished: root.available = (parseInt(out.text) || 0) > 0 }
  }
}
