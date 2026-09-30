import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Output volume. Click opens the popup, right click mutes, scroll changes it.
BarItem {
  id: root
  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var audio: sink ? sink.audio : null
  readonly property int level: audio ? Math.round(audio.volume * 100) : 0
  readonly property bool muted: audio ? audio.muted : false

  PwObjectTracker { objects: sink ? [sink] : [] }

  Text {
    text: root.iconGlyph()
    color: root.muted ? Theme.dim : Theme.text
    font.family: Theme.iconFont
    font.pixelSize: 16
  }

  onRightClicked: if (audio) audio.muted = !audio.muted
  onScrolled: function (step) { if (audio) audio.volume = Math.max(0, Math.min(1, audio.volume + step * 0.05)); }

  function iconGlyph() {
    if (muted) return String.fromCodePoint(0xf0581);
    if (level <= 33) return String.fromCodePoint(0xf057f);
    if (level <= 66) return String.fromCodePoint(0xf0580);
    return String.fromCodePoint(0xf057e);
  }
}
