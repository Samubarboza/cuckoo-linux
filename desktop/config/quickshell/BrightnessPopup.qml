import Quickshell
import Quickshell.Io
import QtQuick

BarPopup {
  id: root
  readonly property int minBrightness: 5
  property int percent: minBrightness
  property int maxRaw: 0

  implicitWidth: 260
  implicitHeight: row.implicitHeight + 28

  Row {
    id: row
    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
    anchors.leftMargin: 14; anchors.rightMargin: 14; anchors.topMargin: 14
    spacing: 10

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: String.fromCodePoint(0xf00df)
      color: Theme.text; font.family: Theme.iconFont; font.pixelSize: 17
    }
    Item {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - 17 - pct.implicitWidth - 20
      height: 14
      Rectangle {
        id: track
        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        height: 3; radius: 3; color: Qt.rgba(1, 1, 1, 0.25)
        Rectangle {
          anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
          width: parent.width * (root.percent - root.minBrightness) / (100 - root.minBrightness)
          height: 3; radius: 3; color: "#ffffff"
        }
      }
      MouseArea {
        anchors.fill: parent
        onPressed: root.setBri(mouse.x)
        onPositionChanged: if (pressed) root.setBri(mouse.x)
      }
    }
    Text {
      id: pct
      anchors.verticalCenter: parent.verticalCenter
      text: root.percent + "%"
      color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold
    }
  }

  Process { id: readProc; command: ["brightnessctl", "-m"]; stdout: StdioCollector { id: rout; onStreamFinished: root.parse(rout.text) } }
  Process { id: setProc }
  Timer { interval: 1500; running: root.shown; repeat: true; triggeredOnStart: true; onTriggered: readProc.running = true }

  function parse(t) {
    var f = t.trim().split(",");
    if (f.length < 5) return;
    maxRaw = parseInt(f[4]) || 0;
    percent = Math.max(minBrightness, parseInt(f[3]) || 0);
  }
  function setBri(x) {
    if (maxRaw <= 0) return;
    var ratio = Math.max(0, Math.min(1, x / track.width));
    var target = Math.round(minBrightness + ratio * (100 - minBrightness));
    if (target === percent) return;
    percent = target;
    setProc.command = ["brightnessctl", "s", target + "%"];
    setProc.running = true;
  }
}
