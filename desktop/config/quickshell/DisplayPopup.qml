import Quickshell
import Quickshell.Io
import QtQuick

// One row per screen with 4 scales that fit its resolution. A click applies the scale at once and saves it in monitors.conf.
BarPopup {
  id: root
  property var screens: []
  // Scales in parts of 120, the same way Hyprland and Wayland count them: 83%, 100%, 125% and 150%
  readonly property var wantedScales: [100, 120, 150, 180]
  // An exact scale shows only when it is at most 10% away from the wanted one
  readonly property int maxScaleDistance: 12

  implicitWidth: 300
  implicitHeight: column.implicitHeight + 26
  onShownChanged: if (shown) readProc.running = true

  Column {
    id: column
    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
    anchors.leftMargin: 14; anchors.rightMargin: 14; anchors.topMargin: 12
    spacing: 12

    Text { text: "Scale"; font.family: Theme.fontFamily; font.pixelSize: 11; color: Theme.subtitle }

    Repeater {
      model: root.screens
      Column {
        id: screenRow
        required property var modelData
        width: column.width
        spacing: 8
        Text { width: parent.width; text: modelData.label; elide: Text.ElideRight; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; color: Theme.text }
        Flow {
          width: parent.width
          spacing: 6
          Repeater {
            model: root.exactScales(modelData.width, modelData.height)
            ScaleButton { required property int modelData; scaleParts: modelData; targetScreen: screenRow.modelData }
          }
        }
      }
    }
  }

  component ScaleButton: Rectangle {
    property int scaleParts: 120
    property var targetScreen: null
    readonly property bool current: targetScreen && Math.round(targetScreen.scale * 120) === scaleParts
    width: label.implicitWidth + 16; height: 24; radius: Theme.cornerRadius
    color: current ? Theme.glass : hover.hovered ? Theme.hover : "transparent"
    Text { id: label; anchors.centerIn: parent; text: Math.round(scaleParts * 100 / 120) + "%"; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: current ? Theme.text : Theme.soft }
    HoverHandler { id: hover }
    TapHandler { onTapped: root.applyScale(targetScreen, scaleParts) }
  }

  Process { id: readProc; command: ["hyprctl", "-j", "monitors"]; stdout: StdioCollector { id: rout; onStreamFinished: root.readScreens(rout.text) } }
  Process { id: applyProc; onExited: readProc.running = true }
  FileView { id: monitorsFile; path: Quickshell.env("HOME") + "/.config/hypr/monitors.conf"; blockLoading: true; watchChanges: true; onFileChanged: reload() }

  function readScreens(text) {
    var monitors = [];
    try { monitors = JSON.parse(text); } catch (error) { return; }
    screens = monitors.map(function (monitor) {
      var rule = monitor.description ? "desc:" + monitor.description : monitor.name;
      return { rule: rule, label: monitor.description || monitor.name, width: monitor.width, height: monitor.height, scale: monitor.scale };
    });
  }
  // For each wanted scale, the closest exact one. Two that end on the same scale show once.
  function exactScales(width, height) {
    var exact = [];
    wantedScales.forEach(function (wanted) {
      var closest = closestExactScale(width, height, wanted);
      if (closest > 0 && exact.indexOf(closest) === -1) exact.push(closest);
    });
    return exact;
  }
  // 0 when no exact scale is close enough. On a tie, the smaller scale wins.
  function closestExactScale(width, height, wanted) {
    for (var distance = 0; distance <= maxScaleDistance; distance++) {
      if (isExactScale(width, height, wanted - distance)) return wanted - distance;
      if (isExactScale(width, height, wanted + distance)) return wanted + distance;
    }
    return 0;
  }
  // Exact when the width and the height divide into whole pixels, so the screen stays sharp
  function isExactScale(width, height, scaleParts) {
    return (width * 120) % scaleParts === 0 && (height * 120) % scaleParts === 0;
  }
  function scaleValue(scaleParts) {
    return Number((scaleParts / 120).toFixed(6));
  }
  function applyScale(screen, scaleParts) {
    if (applyProc.running) return;
    applyProc.command = ["hyprctl", "keyword", "monitor", screen.rule + ", preferred, auto, " + scaleValue(scaleParts)];
    applyProc.running = true;
    saveScale(screen.rule, scaleValue(scaleParts));
  }
  // Replace the line of this screen and keep every other line as it is
  function saveScale(rule, scale) {
    var keptLines = monitorsFile.text().split("\n").filter(function (savedLine) {
      return savedLine !== "" && savedLine.indexOf("monitor = " + rule + ",") !== 0;
    });
    keptLines.push("monitor = " + rule + ", preferred, auto, " + scale);
    monitorsFile.setText(keptLines.join("\n") + "\n");
  }
}
