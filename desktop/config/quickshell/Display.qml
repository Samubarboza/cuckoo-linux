import Quickshell
import QtQuick

// Screen icon. Click opens the popup to pick the scale of each screen.
BarItem {
  id: root

  Text {
    text: String.fromCodePoint(0xf0379)
    color: Theme.text
    font.family: Theme.iconFont
    font.pixelSize: 16
  }
}
