import Quickshell
import Quickshell.Io
import QtQuick

// The fonts section of the theme panel: the system font and the terminal font, each with its style.
// Moving in the lists only changes the preview, picking saves the family and the style together.
Column {
  id: root

  // Each tab with its theme keys and what is saved now
  readonly property var tabs: [
    { id: "system", fontKey: "font", styleKey: "font_style", family: Theme.fontFamily, style: Theme.fontStyle },
    { id: "terminal", fontKey: "terminal_font", styleKey: "terminal_font_style", family: Theme.terminalFont, style: Theme.terminalFontStyle }
  ]
  property int tabIndex: 0
  readonly property var tab: tabs[tabIndex]
  // The lists come from cuckoo-theme, so they only have what cuckoo-theme set accepts
  property var systemFonts: []
  property var terminalFonts: []
  readonly property var fonts: tabIndex === 0 ? systemFonts : terminalFonts
  // The preview shows the highlighted rows, before anything is saved
  readonly property string previewFamily: rowValue(familyList, tab.family)
  readonly property string previewStyle: rowValue(styleList, tab.style)
  readonly property Item focusItem: familyList

  spacing: 16

  // Asked again each time, so a font added by the user shows up without a restart
  onVisibleChanged: if (visible) {
    systemFontList.running = true;
    terminalFontList.running = true;
  }

  Process {
    id: systemFontList
    command: ["cuckoo-theme", "fonts"]
    stdout: StdioCollector { id: systemFontOutput; onStreamFinished: root.systemFonts = root.parseFonts(systemFontOutput.text) }
  }
  Process {
    id: terminalFontList
    command: ["cuckoo-theme", "terminal-fonts"]
    stdout: StdioCollector { id: terminalFontOutput; onStreamFinished: root.terminalFonts = root.parseFonts(terminalFontOutput.text) }
  }

  Row {
    spacing: 6

    Repeater {
      model: root.tabs
      delegate: Rectangle {
        required property var modelData
        required property int index
        readonly property bool selected: index === root.tabIndex
        width: tabText.implicitWidth + 24
        height: 28
        radius: Theme.cornerRadius
        color: selected || tabHover.hovered ? Theme.selected : "transparent"

        Text {
          id: tabText
          anchors.centerIn: parent
          text: Language.text(modelData.id)
          color: selected ? Theme.accent : Theme.soft
          font.family: Theme.fontFamily; font.pixelSize: 13
          font.weight: selected ? Font.DemiBold : Font.Medium
        }

        HoverHandler { id: tabHover }
        TapHandler { onTapped: root.tabIndex = index }
      }
    }
  }

  // Families on the left, their styles on the right
  Row {
    width: parent.width
    height: 200
    spacing: 12

    ThemeList {
      id: familyList
      width: (parent.width - parent.spacing) / 2
      height: parent.height
      model: root.fonts.map(font => ({ value: font.family, label: font.family }))
      chosenValue: root.tab.family
      onPicked: family => root.save(family, root.styleFor(family))
      Keys.onRightPressed: styleList.forceActiveFocus()
    }

    ThemeList {
      id: styleList
      width: (parent.width - parent.spacing) / 2
      height: parent.height
      model: root.stylesOf(root.previewFamily).map(style => ({ value: style, label: style }))
      chosenValue: root.styleFor(root.previewFamily)
      onPicked: style => root.save(root.previewFamily, style)
      Keys.onLeftPressed: familyList.forceActiveFocus()
    }
  }

  Text {
    width: parent.width
    elide: Text.ElideRight
    text: "Whereas recognition of the inherent dignity"
    color: Theme.text; font.family: root.previewFamily; font.styleName: root.previewStyle; font.pixelSize: 18
  }

  // Output that is not json gives an empty list, so a broken cuckoo-theme never breaks the panel
  function parseFonts(output) {
    try {
      var fontList = JSON.parse(output);
      return Array.isArray(fontList) ? fontList : [];
    } catch (error) {
      return [];
    }
  }

  function rowValue(list, fallback) {
    return list.hasRow(list.currentIndex) ? list.model[list.currentIndex].value : fallback;
  }

  function stylesOf(family) {
    var font = fonts.find(entry => entry.family === family);
    return font ? font.styles : [];
  }

  // A new family keeps the style it has now. If it does not have it, Regular, and if not, the first one
  function styleFor(family) {
    var styles = stylesOf(family);
    if (styles.includes(tab.style)) return tab.style;
    if (styles.includes("Regular")) return "Regular";
    return styles.length > 0 ? styles[0] : "";
  }

  function save(family, style) {
    if (!style || (family === tab.family && style === tab.style)) return;
    Quickshell.execDetached(["cuckoo-theme", "set", tab.fontKey, family, tab.styleKey, style]);
  }
}
