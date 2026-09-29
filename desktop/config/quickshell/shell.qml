import Quickshell
import QtQuick

// The Cuckoo bar. One copy per screen. Empty for now: only the background
// and the three zones where the modules will go later.
ShellRoot {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar
      required property var modelData
      screen: modelData

      color: "transparent"
      implicitHeight: Theme.barHeight

      anchors {
        top: true
        left: true
        right: true
      }

      // Background gradient
      Rectangle {
        anchors.fill: parent
        gradient: Gradient {
          GradientStop { position: 0.0; color: Theme.barTop }
          GradientStop { position: 1.0; color: Theme.barBottom }
        }
      }

      // Left: active app and music
      Row {
        id: leftZone
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        ActiveWindow {
          screen: modelData
        }
        Music {
          onActivated: musicPopup.toggle()
        }
      }

      // Center: workspaces
      Row {
        id: centerZone
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Workspaces {
          screen: modelData
        }
      }

      // Right: system icons, date and time
      Row {
        id: rightZone
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Tray {}
        Notifications {}
        Weather {}
        Network {}
        Volume {}
        VolumeSlider {}
        Control {}
        Battery {}
        Clock {}
      }

      // Music popup, dropped under the left side of the bar
      MusicPopup {
        id: musicPopup
        barWindow: bar
        anchorX: 130
      }
    }
  }
}
