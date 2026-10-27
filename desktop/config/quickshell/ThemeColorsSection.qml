import Quickshell
import QtQuick

// The colors section of the theme panel: the theme color, and the transparency of the windows,
// the cards and the notifications.
Column {
  id: root

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

    ColorPalette {
      colors: Theme.paletteColors
      chosenColor: Theme.accent
      onPicked: color => Quickshell.execDetached(["cuckoo-theme", "set", "accent", color])
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
