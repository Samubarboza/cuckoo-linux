import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// A thin volume slider. Click or drag on the track to set the level.
Item {
  id: root

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var audio: sink ? sink.audio : null

  implicitWidth: 70
  implicitHeight: Theme.barHeight

  PwObjectTracker {
    objects: sink ? [sink] : []
  }

  // Track
  Rectangle {
    id: track
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.rightMargin: 8
    height: 3
    radius: 3
    color: Qt.rgba(1, 1, 1, 0.25)

    Rectangle {
      id: fill
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width * (root.audio ? root.audio.volume : 0)
      height: 3
      radius: 3
      color: "#ffffff"
    }

    Rectangle {
      width: 10
      height: 10
      radius: 5
      color: "#ffffff"
      anchors.verticalCenter: parent.verticalCenter
      x: fill.width - width / 2
    }
  }

  MouseArea {
    anchors.fill: parent
    onPressed: root.setFromMouse(mouse.x)
    onPositionChanged: if (pressed)
      root.setFromMouse(mouse.x)
  }

  function setFromMouse(mouseX) {
    if (!audio)
      return;
    var ratio = Math.max(0, Math.min(1, (mouseX) / track.width));
    audio.volume = ratio;
  }
}
