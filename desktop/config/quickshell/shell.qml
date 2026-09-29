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
        Network {
          id: network
          onClicked: {
            var pos = network.mapToItem(null, 0, 0);
            wifiPopup.anchorX = Math.max(4, pos.x + network.width - wifiPopup.implicitWidth);
            wifiPopup.toggle();
          }
        }
        Volume {}
        VolumeSlider {}
        Control {
          id: control
          onClicked: {
            var pos = control.mapToItem(null, 0, 0);
            systemPopup.anchorX = Math.max(4, pos.x + control.width - systemPopup.implicitWidth);
            systemPopup.toggle();
          }
        }
        Battery {}
        Clock {}
      }

      // Music popup, dropped under the left side of the bar
      MusicPopup {
        id: musicPopup
        barWindow: bar
        anchorX: 130
      }

      // System popup, dropped under the control switch
      SystemPopup {
        id: systemPopup
        barWindow: bar
      }

      // Wifi popup, dropped under the network icon
      WifiPopup {
        id: wifiPopup
        barWindow: bar
      }
    }
  }
}
