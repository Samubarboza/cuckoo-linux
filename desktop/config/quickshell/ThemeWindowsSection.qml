import Quickshell
import QtQuick

// The windows section of the theme panel: the window border, on or off, its size and its color,
// and the window corners.
Column {
  id: root

  readonly property bool hasBorder: Theme.borderSize > 0
  // White looks like glass on the dark background
  readonly property var borderColors: Theme.paletteColors.concat(["#ffffff"])
  readonly property int savedBorderSize: Theme.borderSize
  property int borderSize: savedBorderSize
  readonly property int savedRounding: Theme.windowRounding
  property int rounding: savedRounding

  spacing: 24

  // A new theme file moves the sliders too, also when it changes from the terminal
  onSavedBorderSizeChanged: borderSize = savedBorderSize
  onSavedRoundingChanged: rounding = savedRounding

  // Off is a size of 0. On goes back to the default size
  Row {
    width: parent.width

    Text {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - borderSwitch.width
      text: Language.text("border")
      color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.Medium
    }
    ToggleSwitch {
      id: borderSwitch
      active: root.hasBorder
      onToggled: Quickshell.execDetached(["cuckoo-theme", "set", "border_size", String(root.hasBorder ? 0 : Theme.defaultBorderSize)])
    }
  }

  Column {
    width: parent.width
    spacing: 12
    visible: root.hasBorder

    Text {
      text: Language.text("borderSize")
      color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.Medium
    }

    ThemeSlider {
      width: parent.width
      from: 1
      to: 10
      value: root.borderSize
      valueText: root.borderSize + " px"
      onMoved: newValue => root.previewBorderSize(newValue)
      onReleased: root.saveBorderSize()
    }
  }

  Column {
    width: parent.width
    spacing: 12
    visible: root.hasBorder

    Text {
      text: Language.text("borderColor")
      color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.Medium
    }

    ColorPalette {
      colors: root.borderColors
      chosenColor: Theme.borderColor
      onPicked: color => Quickshell.execDetached(["cuckoo-theme", "set", "border_color", color])
    }
  }

  Column {
    width: parent.width
    spacing: 12

    Text {
      text: Language.text("rounding")
      color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.Medium
    }

    ThemeSlider {
      width: parent.width
      from: 0
      to: 30
      stepSize: 2
      value: root.rounding
      valueText: root.rounding + " px"
      onMoved: newValue => root.previewRounding(newValue)
      onReleased: root.saveRounding()
    }
  }

  // While dragging, only Hyprland changes, so the windows follow the mouse and nothing is saved
  function previewBorderSize(size) {
    borderSize = size;
    Quickshell.execDetached(["hyprctl", "keyword", "general:border_size", String(size)]);
  }

  function previewRounding(size) {
    rounding = size;
    Quickshell.execDetached(["hyprctl", "keyword", "decoration:rounding", String(size)]);
  }

  // On release, one save
  function saveBorderSize() {
    if (borderSize === savedBorderSize) return;
    Quickshell.execDetached(["cuckoo-theme", "set", "border_size", String(borderSize)]);
  }

  function saveRounding() {
    if (rounding === savedRounding) return;
    Quickshell.execDetached(["cuckoo-theme", "set", "rounding", String(rounding)]);
  }
}
