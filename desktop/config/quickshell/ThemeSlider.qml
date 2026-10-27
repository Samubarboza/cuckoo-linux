import QtQuick

// A slider for the theme panel, with the same look as the brightness popup.
// It moves in steps and only tells the new step: the parent sets the value back.
Row {
  id: root

  property int from: 0
  property int to: 100
  property int stepSize: 1
  property int value: from
  property string valueText: value
  signal moved(int newValue)
  signal released

  spacing: 10

  Item {
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width - valueLabel.width - parent.spacing
    height: 14

    Rectangle {
      id: track
      anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
      height: 3; radius: 3; color: Theme.glass
      Rectangle {
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        width: parent.width * (root.value - root.from) / (root.to - root.from)
        height: 3; radius: 3; color: Theme.accent
      }
    }
    MouseArea {
      anchors.fill: parent
      onPressed: mouse => root.moveTo(mouse.x)
      onPositionChanged: mouse => root.moveTo(mouse.x)
      onReleased: root.released()
    }
  }
  // A fixed width, so the slider does not move when the text gets longer
  Text {
    id: valueLabel
    anchors.verticalCenter: parent.verticalCenter
    width: 36
    horizontalAlignment: Text.AlignRight
    text: root.valueText
    color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold
  }

  function moveTo(x) {
    var ratio = Math.max(0, Math.min(1, x / track.width));
    var target = from + Math.round(ratio * (to - from) / stepSize) * stepSize;
    if (target !== value) moved(target);
  }
}
