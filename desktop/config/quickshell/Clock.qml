import Quickshell
import QtQuick

// Date and time. Click switches between the two formats.
BarItem {
  id: root

  property bool showDate: false
  minWidth: 124
  hpad: 12

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  Text {
    text: root.showDate ? root.format("dd/MM/yyyy  HH:mm") : root.format("ddd MMM d  HH:mm")
    color: Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Font.DemiBold
  }

  onClicked: showDate = !showDate

  // English names, like the old C locale in Waybar
  function format(pattern) {
    return clock.date.toLocaleString(Qt.locale("en_US"), pattern);
  }
}
