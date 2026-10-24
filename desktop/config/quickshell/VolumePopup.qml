import Quickshell
import Quickshell.Io
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
  // On many laptops the HDMI is hidden in the sound card, it only shows after a profile change
  property var hiddenOutputs: []
  readonly property var choices: outputs.map(node => ({ name: node.description || node.name, node: node })).concat(hiddenOutputs)

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
          height: 3; radius: 3; color: Theme.glass
          Rectangle { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; width: parent.width * (root.audio ? root.audio.volume : 0); height: 3; radius: 3; color: Theme.text }
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
      visible: root.choices.length < 2
      anchors.left: parent.left; anchors.right: parent.right
      text: root.sink ? root.sink.description : ""
      color: Theme.dim; font.family: Theme.fontFamily; font.pixelSize: 11
      elide: Text.ElideRight
    }

    // With more than one output, like an HDMI screen, the user picks one here
    Column {
      visible: root.choices.length > 1
      anchors.left: parent.left; anchors.right: parent.right
      spacing: 6
      Rectangle { width: parent.width; height: 1; color: Theme.hover }
      Text { text: "Output"; color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 12 }
      Repeater {
        model: root.choices
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
      text: modelData.node && modelData.node === root.sink ? "●" : "○"
      color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 12
    }
    Text {
      anchors.left: mark.right; anchors.leftMargin: 8; anchors.right: parent.right; anchors.rightMargin: 6
      anchors.verticalCenter: parent.verticalCenter
      text: modelData.name
      color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 12
      elide: Text.ElideRight
    }
    HoverHandler { id: rowHover }
    TapHandler { onTapped: root.pickOutput(modelData) }
  }

  // The sound cards with their profiles, to find the hidden outputs
  Process {
    id: cardsDump
    command: ["pw-dump"]
    stdout: StdioCollector {
      id: cardsOut
      onStreamFinished: root.findHiddenOutputs(cardsOut.text)
    }
  }
  Process { id: profileChange }
  onShownChanged: if (shown) cardsDump.running = true
  onOutputsChanged: if (shown) cardsDump.running = true

  component ToggleSwitch: Rectangle {
    property bool active: false
    signal toggled
    width: 30; height: 18; radius: 999
    color: active ? Theme.soft : Theme.glass
    Rectangle {
      width: 14; height: 14; radius: 999
      color: parent.active ? Theme.background : Theme.text
      anchors.verticalCenter: parent.verticalCenter
      x: parent.active ? parent.width - width - 2 : 2
      Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }
    TapHandler { onTapped: parent.toggled() }
  }

  function setVol(x) { if (audio) audio.volume = Math.max(0, Math.min(1, x / track.width)); }

  function pickOutput(choice) {
    if (choice.node) {
      Pipewire.preferredDefaultAudioSink = choice.node;
      return;
    }
    profileChange.command = ["wpctl", "set-profile", String(choice.cardId), String(choice.profileIndex)];
    profileChange.running = true;
  }

  // For each card, offer the HDMI when it is plugged in, or the way back when the HDMI is on
  function findHiddenOutputs(text) {
    var objects;
    try { objects = JSON.parse(text); } catch (error) { objects = []; }
    var found = [];
    objects.forEach(object => {
      var params = object.info && object.info.params;
      if (object.type !== "PipeWire:Interface:Device" || !params || !params.EnumProfile || !params.Profile || !params.Profile.length) return;
      var isOnHdmi = isHdmiProfile(params.Profile[0]);
      var profiles = params.EnumProfile.filter(profile => profile.name.startsWith("output:") && isHdmiProfile(profile) !== isOnHdmi && (isOnHdmi ? profile.available !== "no" : profile.available === "yes"));
      if (!profiles.length) return;
      var best = profiles.reduce((first, second) => second.priority > first.priority ? second : first);
      var cardName = object.info.props["device.description"] || object.info.props["device.name"];
      found.push({ name: isOnHdmi ? cardName : "HDMI", cardId: object.id, profileIndex: best.index });
    });
    hiddenOutputs = found;
  }

  function isHdmiProfile(profile) { return profile.name.startsWith("output:hdmi"); }
}
