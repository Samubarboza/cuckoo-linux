import Quickshell
import QtQuick

// The colors section of the theme panel: the theme color, from the Catppuccin Mocha colors.
Column {
  id: root

  readonly property int swatchSize: 28
  // Red and yellow are left out, they are the alert colors
  readonly property var accentColors: ["#89b4fa", "#74c7ec", "#94e2d5", "#a6e3a1", "#fab387", "#f5c2e7", "#cba6f7", "#b4befe"]

  spacing: 12

  Text {
    text: Language.text("accent")
    color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.Medium
  }

  Row {
    spacing: 8

    Repeater {
      model: root.accentColors
      delegate: Rectangle {
        required property string modelData
        readonly property bool chosen: Qt.colorEqual(Theme.accent, modelData)
        // A ring around the color, with a 2 px gap
        width: root.swatchSize + 8; height: width
        radius: width / 2
        color: "transparent"
        border.width: 2
        border.color: chosen ? Theme.text : swatchHover.hovered ? Theme.glass : "transparent"

        Rectangle {
          anchors.centerIn: parent
          width: root.swatchSize; height: width
          radius: width / 2
          color: modelData
        }

        HoverHandler { id: swatchHover }
        TapHandler { onTapped: if (!chosen) Quickshell.execDetached(["cuckoo-theme", "set", "accent", modelData]) }
      }
    }
  }
}
