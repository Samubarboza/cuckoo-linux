import Quickshell
import Quickshell.Io
import QtQuick

BarPopup {
  id: root
  property real cpuPercent: 0
  property real ramPercent: 0
  property real ramUsedGb: 0
  property real ramTotalGb: 0
  property int prevActive: 0
  property int prevTotal: 0

  implicitWidth: 220
  implicitHeight: column.implicitHeight + 26

  Column {
    id: column
    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
    anchors.leftMargin: 14; anchors.rightMargin: 14; anchors.topMargin: 12
    spacing: 12
    UsageRow { icon: String.fromCodePoint(0xf035b); label: "CPU"; value: root.cpuPercent; detail: "" }
    UsageRow { icon: String.fromCodePoint(0xf08ae); label: "RAM"; value: root.ramPercent; detail: root.ramUsedGb.toFixed(1) + " / " + root.ramTotalGb.toFixed(0) + " GB" }
  }

  component UsageRow: Column {
    property string icon: ""
    property string label: ""
    property string detail: ""
    property real value: 0
    anchors.left: parent ? parent.left : undefined
    anchors.right: parent ? parent.right : undefined
    spacing: 6
    Row {
      anchors.left: parent.left; anchors.right: parent.right; spacing: 10
      Text { text: icon; font.family: Theme.iconFont; font.pixelSize: 17; color: Theme.text }
      Text { text: label; width: parent.width - 34 - d.implicitWidth - v.implicitWidth - 20; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; color: Theme.text }
      Text { id: d; text: detail; font.family: Theme.fontFamily; font.pixelSize: 11; color: Theme.subtitle }
      Text { id: v; text: Math.round(value) + "%"; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.soft }
    }
    Rectangle {
      anchors.left: parent.left; anchors.right: parent.right; height: 3; radius: 3; color: Qt.rgba(1, 1, 1, 0.20)
      Rectangle { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; width: parent.width * Math.max(0, Math.min(1, value / 100)); height: 3; radius: 3; color: "#ffffff" }
    }
  }

  Process { id: usage; command: ["cat", "/proc/stat", "/proc/meminfo"]; stdout: StdioCollector { id: uout; onStreamFinished: root.parseUsage(uout.text) } }
  Timer { interval: 1500; running: root.shown; repeat: true; triggeredOnStart: true; onTriggered: usage.running = true }

  function parseUsage(text) {
    var lines = text.split("\n"); var memTotal = 0, memAvailable = 0;
    for (var i = 0; i < lines.length; i++) { var line = lines[i];
      if (line.indexOf("cpu ") === 0) { var f = line.trim().split(/\s+/); var total = 0; for (var j = 1; j < f.length; j++) total += parseInt(f[j]); var active = total - parseInt(f[4]) - parseInt(f[5]); var dT = total - prevTotal; var dA = active - prevActive; if (prevTotal > 0 && dT > 0) cpuPercent = 100 * dA / dT; prevTotal = total; prevActive = active; }
      else if (line.indexOf("MemTotal:") === 0) memTotal = parseInt(line.replace(/\D+/g, ""));
      else if (line.indexOf("MemAvailable:") === 0) memAvailable = parseInt(line.replace(/\D+/g, ""));
    }
    if (memTotal > 0) { var used = memTotal - memAvailable; ramPercent = 100 * used / memTotal; ramUsedGb = used / 1048576; ramTotalGb = memTotal / 1048576; }
  }
}
