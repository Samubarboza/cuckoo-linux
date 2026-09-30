import Quickshell
import QtQuick

ShellRoot {
  Variants {
    model: Quickshell.screens
    PanelWindow {
      id: bar
      required property var modelData
      screen: modelData
      color: "transparent"
      implicitHeight: Theme.barHeight
      anchors { top: true; left: true; right: true }

      Rectangle {
        anchors.fill: parent
        gradient: Gradient {
          GradientStop { position: 0.0; color: Theme.barTop }
          GradientStop { position: 1.0; color: Theme.barBottom }
        }
      }

      Row {
        id: leftZone
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        ActiveWindow { screen: modelData }
        Music { onActivated: musicPopup.toggle() }
      }

      Row {
        id: centerZone
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        Workspaces { screen: modelData }
      }

      Row {
        id: rightZone
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        Tray {}
        Notifications {}
        Weather {}
        Network { id: network; onClicked: { var p = network.mapToItem(null, 0, 0); wifiPopup.anchorX = Math.max(4, p.x + network.width - wifiPopup.implicitWidth); wifiPopup.toggle(); } }
        Volume { id: volume; onClicked: { var p = volume.mapToItem(null, 0, 0); volumePopup.anchorX = Math.max(4, p.x + volume.width - volumePopup.implicitWidth); volumePopup.toggle(); } }
        Brightness { id: brightness; onClicked: { var p = brightness.mapToItem(null, 0, 0); brightnessPopup.anchorX = Math.max(4, p.x + brightness.width - brightnessPopup.implicitWidth); brightnessPopup.toggle(); } }
        Control { id: control; onClicked: { var p = control.mapToItem(null, 0, 0); systemPopup.anchorX = Math.max(4, p.x + control.width - systemPopup.implicitWidth); systemPopup.toggle(); } }
        Battery {}
        Clock {}
      }

      MusicPopup { id: musicPopup; barWindow: bar; anchorX: 130 }
      SystemPopup { id: systemPopup; barWindow: bar }
      WifiPopup { id: wifiPopup; barWindow: bar }
      VolumePopup { id: volumePopup; barWindow: bar }
      BrightnessPopup { id: brightnessPopup; barWindow: bar }
    }
  }
}
