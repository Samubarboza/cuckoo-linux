import QtQuick

// A row of colors to pick, with a ring on the chosen one.
// It only tells the color picked: the parent saves it.
Row {
  id: root

  readonly property int swatchSize: 28
  property var colors: []
  property color chosenColor
  signal picked(string color)

  spacing: 8

  Repeater {
    model: root.colors
    delegate: Rectangle {
      required property string modelData
      readonly property bool chosen: Qt.colorEqual(root.chosenColor, modelData)
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
      TapHandler { onTapped: if (!chosen) root.picked(modelData) }
    }
  }
}
