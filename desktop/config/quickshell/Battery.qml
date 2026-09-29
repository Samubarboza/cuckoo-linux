import Quickshell
import Quickshell.Services.UPower
import QtQuick

// Battery level and charge state. Hidden on machines without a laptop battery.
BarItem {
  id: root

  readonly property var device: UPower.displayDevice
  readonly property bool present: device && device.isLaptopBattery && device.isPresent
  readonly property int level: present ? Math.round(device.percentage) : 0
  readonly property bool charging: present && device.state === UPowerDeviceState.Charging

  visible: present
  minWidth: 58

  Text {
    // charging shows the bolt, discharging shows the level icon
    text: root.level + "%  " + (root.charging ? "" : root.icon())
    color: root.charging ? Theme.text : (root.level <= 15 ? Theme.red : (root.level <= 30 ? Theme.amber : Theme.text))
    font.family: Theme.iconFont
    font.pixelSize: Theme.fontSize

    // Blink when the battery is critical
    SequentialAnimation on opacity {
      running: root.present && !root.charging && root.level <= 15
      loops: Animation.Infinite
      NumberAnimation {
        to: 0.4
        duration: 500
      }
      NumberAnimation {
        to: 1.0
        duration: 500
      }
    }
  }

  function icon() {
    if (level <= 20)
      return "";
    if (level <= 40)
      return "";
    if (level <= 60)
      return "";
    if (level <= 80)
      return "";
    return "";
  }
}
