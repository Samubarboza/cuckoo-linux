import Quickshell
import Quickshell.Io
import QtQuick

// Notification state from swaync. Click opens the panel, right click toggles do-not-disturb.
BarItem {
  id: root

  property int count: 0
  property bool dnd: false

  Text {
    text: root.icon()
    color: root.count > 0 && !root.dnd ? Theme.amber : Theme.text
    font.family: Theme.iconFont
    font.pixelSize: 16
  }

  onClicked: openPanel.running = true
  onRightClicked: toggleDnd.running = true

  Process {
    id: state
    command: ["sh", "-c", "printf '%s %s' \"$(swaync-client -c 2>/dev/null)\" \"$(swaync-client -D 2>/dev/null)\""]
    stdout: StdioCollector {
      id: output
      onStreamFinished: {
        var parts = output.text.trim().split(" ");
        root.count = parseInt(parts[0]) || 0;
        root.dnd = parts[1] === "true";
      }
    }
  }
  Process {
    id: openPanel
    command: ["swaync-client", "-t", "-sw"]
  }
  Process {
    id: toggleDnd
    command: ["swaync-client", "-d", "-sw"]
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: state.running = true
  }

  function icon() {
    if (dnd)
      return count > 0 ? "󰂛" : "󰪑";
    return count > 0 ? "󰂚" : "󰂜";
  }
}
