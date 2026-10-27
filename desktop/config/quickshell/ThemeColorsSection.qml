import Quickshell
import QtQuick

// The colors section of the theme panel: the theme color, from the Catppuccin Mocha colors,
// and the transparency of the windows, the cards and the notifications.
Column {
  id: root

  readonly property int swatchSize: 28
  // Red and yellow are left out, they are the alert colors
  readonly property var accentColors: ["#89b4fa", "#74c7ec", "#94e2d5", "#a6e3a1", "#fab387", "#f5c2e7", "#cba6f7", "#b4befe"]
  readonly property int minOpacityPercent: 50
  readonly property int opacityStepPercent: 5
  // The other windows are always this much more transparent than the active one
  readonly property int inactiveGapPercent: 20
  readonly property int savedOpacityPercent: Math.round(Theme.windowOpacity * 100)
  property int opacityPercent: savedOpacityPercent

  spacing: 24

  // A new theme file moves the slider too, also when it changes from the terminal
  onSavedOpacityPercentChanged: opacityPercent = savedOpacityPercent

  Column {
    width: parent.width
    spacing: 12

    Text {
      text: Language.text("accent")
      color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.Medium
    }

    Row {
      spacing: 8

      Repeater {
        model: root.accentColors
        delegate: Rectangle {
          required property string modelData
          readonly property bool chosen: Qt.colorEqual(Theme.accent, modelData)
          // A ring around the color, with a 2 px gap
          width: root.swatchSize + 8; height: width
          radius: width / 2
          color: "transparent"
          border.width: 2
          border.color: chosen ? Theme.text : swatchHover.hovered ? Theme.glass : "transparent"

          Rectangle {
            anchors.centerIn: parent
            width: root.swatchSize; height: width
            radius: width / 2
            color: modelData
          }

          HoverHandler { id: swatchHover }
          TapHandler { onTapped: if (!chosen) Quickshell.execDetached(["cuckoo-theme", "set", "accent", modelData]) }
        }
      }
    }
  }

  Column {
    width: parent.width
    spacing: 12

    Text {
      text: Language.text("transparency")
      color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.Medium
    }

    ThemeSlider {
      width: parent.width
      from: root.minOpacityPercent
      to: 100
      stepSize: root.opacityStepPercent
      value: root.opacityPercent
      valueText: root.opacityPercent + "%"
      onMoved: newValue => root.previewOpacity(newValue)
      onReleased: root.saveOpacity()
    }
  }

  // 85 gives "0.85", so there are no float errors
  function opacityText(percent) {
    return (percent / 100).toFixed(2);
  }

  // While dragging, only Hyprland changes, so the windows follow the mouse and nothing is saved
  function previewOpacity(percent) {
    opacityPercent = percent;
    Quickshell.execDetached(["hyprctl", "--batch",
      "keyword decoration:active_opacity " + opacityText(percent)
      + " ; keyword decoration:inactive_opacity " + opacityText(percent - inactiveGapPercent)]);
  }

  // On release, one save: cuckoo-theme applies it to the windows, the cards and the notifications
  function saveOpacity() {
    if (opacityPercent === savedOpacityPercent) return;
    Quickshell.execDetached(["cuckoo-theme", "set",
      "window_opacity", opacityText(opacityPercent),
      "inactive_window_opacity", opacityText(opacityPercent - inactiveGapPercent)]);
  }
}
