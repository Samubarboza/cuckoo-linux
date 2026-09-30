import Quickshell
import Quickshell.Services.UPower
import QtQuick

BarItem {
  id: root
  readonly property var device: UPower.displayDevice
  readonly property bool present: device && device.isLaptopBattery && device.isPresent
  readonly property int level: present ? Math.round(device.percentage) : 0
  readonly property bool charging: present && device.state === UPowerDeviceState.Charging
  visible: present
  minWidth: 58

  Row {
    spacing: 4
    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.level + "%"
      color: root.iconColor()
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.charging ? String.fromCodePoint(0xf0e7) + " " + String.fromCodePoint(0xf240) : root.iconGlyph()
      color: root.iconColor()
      font.family: Theme.iconFont
      font.pixelSize: Theme.fontSize + 3
      SequentialAnimation on opacity {
        running: root.present && !root.charging && root.level <= 15
        loops: Animation.Infinite
        NumberAnimation { to: 0.4; duration: 500 }
        NumberAnimation { to: 1.0; duration: 500 }
      }
    }
  }

  function iconColor() {
    if (charging) return Theme.text;
    if (level <= 15) return Theme.red;
    if (level <= 30) return Theme.amber;
    return Theme.text;
  }
  function iconGlyph() {
    if (level <= 20) return String.fromCodePoint(0xf244);
    if (level <= 40) return String.fromCodePoint(0xf243);
    if (level <= 60) return String.fromCodePoint(0xf242);
    if (level <= 80) return String.fromCodePoint(0xf241);
    return String.fromCodePoint(0xf240);
  }
}
