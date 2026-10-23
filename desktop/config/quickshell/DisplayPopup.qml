import Quickshell
import Quickshell.Io
import QtQuick

// One row per screen with the scales that fit its resolution. A click applies the scale at once.
BarPopup {
  id: root
  property var screens: []

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
            model: root.scalesThatFit(modelData.width, modelData.height)
            ScaleButton { required property int modelData; twentieths: modelData; targetScreen: screenRow.modelData }
          }
        }
      }
    }
  }

  component ScaleButton: Rectangle {
    property int twentieths: 20
    property var targetScreen: null
    readonly property bool current: targetScreen && Math.round(targetScreen.scale * 20) === twentieths
    width: label.implicitWidth + 16; height: 24; radius: Theme.cornerRadius
    color: current ? Theme.glass : hover.hovered ? Theme.hover : "transparent"
    Text { id: label; anchors.centerIn: parent; text: twentieths * 5 + "%"; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: current ? Theme.text : Theme.soft }
    HoverHandler { id: hover }
    TapHandler { onTapped: root.applyScale(targetScreen, twentieths) }
  }

  Process { id: readProc; command: ["hyprctl", "-j", "monitors"]; stdout: StdioCollector { id: rout; onStreamFinished: root.readScreens(rout.text) } }
  Process { id: applyProc; onExited: readProc.running = true }

  function readScreens(text) {
    var monitors = [];
    try { monitors = JSON.parse(text); } catch (error) { return; }
    screens = monitors.map(function (monitor) {
      var rule = monitor.description ? "desc:" + monitor.description : monitor.name;
      return { rule: rule, label: monitor.description || monitor.name, width: monitor.width, height: monitor.height, scale: monitor.scale };
    });
  }
  // Scales from 1 to 2, in steps of 0.05, that divide the width and the height exactly. Counted in twentieths to stay whole numbers.
  function scalesThatFit(width, height) {
    var fitting = [];
    for (var twentieths = 20; twentieths <= 40; twentieths++)
      if ((width * 20) % twentieths === 0 && (height * 20) % twentieths === 0) fitting.push(twentieths);
    return fitting;
  }
  function applyScale(screen, twentieths) {
    if (applyProc.running) return;
    applyProc.command = ["hyprctl", "keyword", "monitor", screen.rule + ", preferred, auto, " + twentieths / 20];
    applyProc.running = true;
  }
}
