import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

BarPopup {
  id: root
  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var audio: sink ? sink.audio : null
  readonly property int level: audio ? Math.round(audio.volume * 100) : 0
  readonly property bool muted: audio ? audio.muted : false
  // Sound outputs of the computer, not of the apps
  readonly property var outputs: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream && node.audio)

  implicitWidth: 260
  implicitHeight: column.implicitHeight + 26

  PwObjectTracker { objects: sink ? [sink] : [] }

  Column {
    id: column
    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
    anchors.leftMargin: 14; anchors.rightMargin: 14; anchors.topMargin: 12
    spacing: 12

    Row {
      anchors.left: parent.left; anchors.right: parent.right
      spacing: 10
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: String.fromCodePoint(root.muted ? 0xf0581 : 0xf057e)
        color: Theme.text; font.family: Theme.iconFont; font.pixelSize: 17
        TapHandler { onTapped: if (root.audio) root.audio.muted = !root.audio.muted }
      }
      Item {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 17 - pct.implicitWidth - 20
        height: 14
        Rectangle {
          id: track
          anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
          height: 3; radius: 3; color: Qt.rgba(1, 1, 1, 0.25)
          Rectangle { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; width: parent.width * (root.audio ? root.audio.volume : 0); height: 3; radius: 3; color: "#ffffff" }
        }
        MouseArea { anchors.fill: parent; onPressed: root.setVol(mouse.x); onPositionChanged: if (pressed) root.setVol(mouse.x) }
      }
      Text { id: pct; anchors.verticalCenter: parent.verticalCenter; text: root.level + "%"; color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold }
    }

    Row {
      anchors.left: parent.left; anchors.right: parent.right
      Text {
        width: parent.width - muteSwitch.width
        anchors.verticalCenter: parent.verticalCenter
        text: "Mute"
        color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 12
      }
      ToggleSwitch { id: muteSwitch; active: root.muted; onToggled: if (root.audio) root.audio.muted = !root.audio.muted }
    }

    Text {
      visible: root.outputs.length < 2
      anchors.left: parent.left; anchors.right: parent.right
      text: root.sink ? root.sink.description : ""
      color: Theme.subtitle; font.family: Theme.fontFamily; font.pixelSize: 11
      elide: Text.ElideRight
    }

    // With more than one output, like an HDMI screen, the user picks one here
    Column {
      visible: root.outputs.length > 1
      anchors.left: parent.left; anchors.right: parent.right
      spacing: 6
      Rectangle { width: parent.width; height: 1; color: Theme.hover }
      Text { text: "Output"; color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 12 }
      Repeater {
        model: root.outputs
        OutputRow {}
      }
    }
  }

  component OutputRow: Rectangle {
    required property var modelData
    width: parent ? parent.width : 0
    height: 28; radius: Theme.cornerRadius
    color: rowHover.hovered ? Theme.hover : "transparent"
    Text {
      id: mark
      anchors.left: parent.left; anchors.leftMargin: 6; anchors.verticalCenter: parent.verticalCenter
      text: modelData === root.sink ? "●" : "○"
      color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 12
    }
    Text {
      anchors.left: mark.right; anchors.leftMargin: 8; anchors.right: parent.right; anchors.rightMargin: 6
      anchors.verticalCenter: parent.verticalCenter
      text: modelData.description || modelData.name
      color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 12
      elide: Text.ElideRight
    }
    HoverHandler { id: rowHover }
    TapHandler { onTapped: Pipewire.preferredDefaultAudioSink = modelData }
  }

  component ToggleSwitch: Rectangle {
    property bool active: false
    signal toggled
    width: 30; height: 18; radius: 999
    color: active ? Qt.rgba(1, 1, 1, 0.85) : Qt.rgba(1, 1, 1, 0.22)
    Rectangle {
      width: 14; height: 14; radius: 999
      color: parent.active ? "#1c1c1e" : "#ffffff"
      anchors.verticalCenter: parent.verticalCenter
      x: parent.active ? parent.width - width - 2 : 2
      Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }
    TapHandler { onTapped: parent.toggled() }
  }

  function setVol(x) { if (audio) audio.volume = Math.max(0, Math.min(1, x / track.width)); }
}
