import Quickshell
import QtQuick

// System switch. Click opens the CPU and RAM popup, wired in T6.
BarItem {
  id: root

  hpad: 9

  Text {
    text: ""
    color: Theme.text
    font.family: Theme.iconFont
    font.pixelSize: 15
  }
}
