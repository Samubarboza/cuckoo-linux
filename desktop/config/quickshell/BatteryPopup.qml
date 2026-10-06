import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick

// Battery level and power mode. The modes show only when power-profiles-daemon runs.
BarPopup {
  id: root
  readonly property var device: UPower.displayDevice
  readonly property int level: device ? Math.round(device.percentage) : 0
  readonly property bool charging: device && device.state === UPowerDeviceState.Charging
  property bool profilesRunning: false

  implicitWidth: 260
  implicitHeight: column.implicitHeight + 26

  Column {
    id: column
    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
    anchors.leftMargin: 14; anchors.rightMargin: 14; anchors.topMargin: 12
    spacing: 12

    Column {
      width: parent.width
      spacing: 6
      Row {
        width: parent.width
        spacing: 10
        Text { id: pct; text: root.level + "%"; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; color: Theme.text }
        Text { width: parent.width - pct.implicitWidth - 10; horizontalAlignment: Text.AlignRight; text: root.statusText(); font.family: Theme.fontFamily; font.pixelSize: 11; color: Theme.subtitle }
      }
      Rectangle {
        width: parent.width; height: 3; radius: 3; color: Qt.rgba(1, 1, 1, 0.20)
        Rectangle { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; width: parent.width * root.level / 100; height: 3; radius: 3; color: "#ffffff" }
      }
    }

    Column {
      width: parent.width
      spacing: 4
      visible: root.profilesRunning
      ProfileRow { icon: 0xf032a; label: "Power saver"; profile: PowerProfile.PowerSaver }
      ProfileRow { icon: 0xf05d1; label: "Balanced"; profile: PowerProfile.Balanced }
      ProfileRow { icon: 0xf04c5; label: "Performance"; profile: PowerProfile.Performance; visible: PowerProfiles.hasPerformanceProfile }
    }
  }

  component ProfileRow: Rectangle {
    property int icon: 0
    property string label: ""
    property int profile: PowerProfile.Balanced
    readonly property bool active: PowerProfiles.profile === profile
    width: parent ? parent.width : 0
    height: 30
    radius: Theme.cornerRadius
    color: active ? Theme.glass : (hover.hovered ? Theme.hover : "transparent")

    Row {
      anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter
      spacing: 10
      Text { anchors.verticalCenter: parent.verticalCenter; text: String.fromCodePoint(icon); font.family: Theme.iconFont; font.pixelSize: 16; color: Theme.text }
      Text { anchors.verticalCenter: parent.verticalCenter; text: label; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.text }
    }
    Text {
      anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter
      visible: active
      text: String.fromCodePoint(0xf012c)
      font.family: Theme.iconFont; font.pixelSize: 14; color: Theme.text
    }
    HoverHandler { id: hover }
    TapHandler { onTapped: PowerProfiles.profile = profile }
  }

  // Older installs may have the package without the service, so check it each time it opens
  Process {
    id: profilesCheck
    command: ["systemctl", "is-active", "--quiet", "power-profiles-daemon"]
    onExited: function (exitCode) { root.profilesRunning = exitCode === 0; }
  }
  onShownChanged: if (shown) profilesCheck.running = true

  function statusText() {
    if (charging) return "Charging";
    if (UPower.onBattery) return "On battery";
    return "Plugged in";
  }
}
