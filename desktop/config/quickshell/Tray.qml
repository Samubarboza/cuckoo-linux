import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

// System tray. The arrow reveals the icons. Left click activates, right click is the secondary action.
Row {
  id: root

  property bool expanded: false
  spacing: 0

  // Tray icons, revealed to the left of the arrow
  Row {
    id: items
    height: Theme.barHeight
    spacing: 10
    clip: true
    width: root.expanded ? implicitWidth : 0

    Behavior on width {
      NumberAnimation {
        duration: 400
        easing.type: Easing.OutCubic
      }
    }

    Repeater {
      model: SystemTray.items

      Item {
        required property var modelData
        width: 16
        height: Theme.barHeight

        Image {
          anchors.centerIn: parent
          width: 16
          height: 16
          source: modelData.icon
          fillMode: Image.PreserveAspectFit
        }

        TapHandler {
          acceptedButtons: Qt.LeftButton
          onTapped: modelData.activate()
        }
        TapHandler {
          acceptedButtons: Qt.RightButton
          onTapped: modelData.secondaryActivate()
        }
      }
    }
  }

  BarItem {
    Text {
      text: "󰅁"
      color: Theme.text
      font.family: Theme.iconFont
      font.pixelSize: 16
    }
    onClicked: root.expanded = !root.expanded
  }
}
