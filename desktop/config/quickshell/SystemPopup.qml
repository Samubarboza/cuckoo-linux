import Quickshell
import Quickshell.Io
import QtQuick

// System card: CPU and RAM usage, plus a screen brightness slider.
BarPopup {
  id: root

  // Usage, read from /proc while the popup is open
  property real cpuPercent: 0
  property real ramPercent: 0
  property real ramUsedGb: 0
  property real ramTotalGb: 0
  property int prevActive: 0
  property int prevTotal: 0

  // Brightness, read and set with brightnessctl. Never below the floor, so the
  // screen is never fully dark.
  readonly property int minBrightness: 5
  property int brightnessPercent: minBrightness
  property int brightnessMax: 0
  readonly property bool hasBrightness: brightnessMax > 0

  implicitWidth: 220
  implicitHeight: column.implicitHeight + 26

  Column {
    id: column
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.leftMargin: 14
    anchors.rightMargin: 14
    anchors.topMargin: 12
    spacing: 12

    UsageRow {
      icon: "󰍛"
      name: "CPU"
      value: root.cpuPercent
      detail: ""
    }
    UsageRow {
      icon: "󰢮"
      name: "RAM"
      value: root.ramPercent
      detail: root.ramUsedGb.toFixed(1) + " / " + root.ramTotalGb.toFixed(0) + " GB"
    }

    // Brightness row, only when the machine can change it
    Column {
      anchors.left: parent.left
      anchors.right: parent.right
      spacing: 6
      visible: root.hasBrightness

      Row {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10

        Text {
          text: "󰃟"
          font.family: Theme.iconFont
          font.pixelSize: 17
          color: Theme.text
        }
        Text {
          text: "Brillo"
          width: parent.width - 34 - 40
          font.family: Theme.fontFamily
          font.pixelSize: 13
          font.weight: Font.DemiBold
          color: Theme.text
        }
        Text {
          text: root.brightnessPercent + "%"
          horizontalAlignment: Text.AlignRight
          font.family: Theme.fontFamily
          font.pixelSize: 12
          font.weight: Font.DemiBold
          color: Theme.soft
        }
      }

      Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 12

        Rectangle {
          id: brightnessTrack
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          height: 3
          radius: 3
          color: Qt.rgba(1, 1, 1, 0.20)

          Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * (root.brightnessPercent - root.minBrightness) / (100 - root.minBrightness)
            height: 3
            radius: 3
            color: "#ffffff"
          }
        }

        MouseArea {
          anchors.fill: parent
          onPressed: root.setBrightnessFromMouse(mouse.x)
          onPositionChanged: if (pressed)
            root.setBrightnessFromMouse(mouse.x)
        }
      }
    }
  }

  // CPU and RAM
  Process {
    id: usage
    command: ["cat", "/proc/stat", "/proc/meminfo"]
    stdout: StdioCollector {
      id: usageOut
      onStreamFinished: root.parseUsage(usageOut.text)
    }
  }

  // Current brightness and its maximum
  Process {
    id: brightnessRead
    command: ["brightnessctl", "-m"]
    stdout: StdioCollector {
      id: brightnessOut
      onStreamFinished: root.parseBrightness(brightnessOut.text)
    }
  }

  Process {
    id: brightnessSet
  }

  // Only poll while the popup is open
  Timer {
    interval: 1500
    running: root.shown
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      usage.running = true;
      brightnessRead.running = true;
    }
  }

  component UsageRow: Column {
    property string icon: ""
    property string name: ""
    property string detail: ""
    property real value: 0

    anchors.left: parent ? parent.left : undefined
    anchors.right: parent ? parent.right : undefined
    spacing: 6

    Row {
      anchors.left: parent.left
      anchors.right: parent.right
      spacing: 10

      Text {
        text: icon
        font.family: Theme.iconFont
        font.pixelSize: 17
        color: Theme.text
      }
      Text {
        text: name
        width: parent.width - 34 - detailText.implicitWidth - valueText.implicitWidth - 20
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: Theme.text
      }
      Text {
        id: detailText
        text: detail
        font.family: Theme.fontFamily
        font.pixelSize: 11
        color: Theme.subtitle
      }
      Text {
        id: valueText
        text: Math.round(value) + "%"
        horizontalAlignment: Text.AlignRight
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.weight: Font.DemiBold
        color: Theme.soft
      }
    }

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      height: 3
      radius: 3
      color: Qt.rgba(1, 1, 1, 0.20)

      Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * Math.max(0, Math.min(1, value / 100))
        height: 3
        radius: 3
        color: "#ffffff"
      }
    }
  }

  function parseUsage(text) {
    var lines = text.split("\n");
    var memTotal = 0;
    var memAvailable = 0;
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (line.indexOf("cpu ") === 0) {
        var f = line.trim().split(/\s+/);
        var total = 0;
        for (var j = 1; j < f.length; j++)
          total += parseInt(f[j]);
        var active = total - parseInt(f[4]) - parseInt(f[5]);
        var dTotal = total - prevTotal;
        var dActive = active - prevActive;
        if (prevTotal > 0 && dTotal > 0)
          cpuPercent = 100 * dActive / dTotal;
        prevTotal = total;
        prevActive = active;
      } else if (line.indexOf("MemTotal:") === 0) {
        memTotal = parseInt(line.replace(/\D+/g, ""));
      } else if (line.indexOf("MemAvailable:") === 0) {
        memAvailable = parseInt(line.replace(/\D+/g, ""));
      }
    }
    if (memTotal > 0) {
      var used = memTotal - memAvailable;
      ramPercent = 100 * used / memTotal;
      ramUsedGb = used / 1048576;
      ramTotalGb = memTotal / 1048576;
    }
  }

  function parseBrightness(text) {
    // Format: name,type,current,percent%,max
    var f = text.trim().split(",");
    if (f.length < 5)
      return;
    brightnessMax = parseInt(f[4]) || 0;
    brightnessPercent = Math.max(minBrightness, parseInt(f[3]) || 0);
  }

  function setBrightnessFromMouse(mouseX) {
    if (!hasBrightness)
      return;
    var ratio = Math.max(0, Math.min(1, mouseX / brightnessTrack.width));
    var target = Math.round(minBrightness + ratio * (100 - minBrightness));
    if (target === brightnessPercent)
      return;
    brightnessPercent = target;
    brightnessSet.command = ["brightnessctl", "s", target + "%"];
    brightnessSet.running = true;
  }
}
