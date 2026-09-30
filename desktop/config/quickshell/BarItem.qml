import Quickshell
import QtQuick

// A hoverable rounded slot on the bar, shared by the right-side modules.
Item {
  id: root

  default property alias content: inner.data
  property int minWidth: 0
  property int hpad: 8

  signal clicked
  signal rightClicked
  signal scrolled(int step) // +1 up, -1 down

  implicitWidth: Math.max(minWidth, inner.implicitWidth + hpad * 2)
  implicitHeight: Theme.barHeight

  Rectangle {
    anchors.fill: parent
    anchors.topMargin: 3
    anchors.bottomMargin: 3
    anchors.leftMargin: 1
    anchors.rightMargin: 1
    radius: Theme.cornerRadius
    color: hover.hovered ? Theme.hover : "transparent"
  }

  Row {
    id: inner
    anchors.centerIn: parent
    spacing: 6
  }

  HoverHandler {
    id: hover
  }
  TapHandler {
    acceptedButtons: Qt.LeftButton
    onTapped: root.clicked()
  }
  TapHandler {
    acceptedButtons: Qt.RightButton
    onTapped: root.rightClicked()
  }
  WheelHandler {
    onWheel: function (event) {
      root.scrolled(event.angleDelta.y > 0 ? 1 : -1);
    }
  }
}
