import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

// Output volume. Click opens the mixer, right click mutes, scroll changes it.
BarItem {
  id: root

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var audio: sink ? sink.audio : null
  readonly property int level: audio ? Math.round(audio.volume * 100) : 0
  readonly property bool muted: audio ? audio.muted : false

  minWidth: 50

  // Keep the sink bound so volume and mute stay live
  PwObjectTracker {
    objects: sink ? [sink] : []
  }

  Row {
    spacing: 6
    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.icon()
      color: root.muted ? Theme.dim : Theme.text
      font.family: Theme.iconFont
      font.pixelSize: 16
    }
    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.level + "%"
      color: root.muted ? Theme.dim : Theme.text
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
  }

  onClicked: mixer.running = true
  onRightClicked: if (audio)
    audio.muted = !audio.muted
  onScrolled: function (step) {
    if (audio)
      audio.volume = Math.max(0, Math.min(1, audio.volume + step * 0.05));
  }

  Process {
    id: mixer
    command: ["pavucontrol"]
  }

  function icon() {
    if (muted)
      return "󰖁";
    if (level <= 33)
      return "󰕿";
    if (level <= 66)
      return "󰖀";
    return "󰕾";
  }
}
