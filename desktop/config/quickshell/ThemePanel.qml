import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

// Theme panel: the look of the desktop, in the middle of the screen. A sibling of the app launcher.
PanelWindow {
  id: root

  readonly property int panelWidth: 720
  readonly property int panelHeight: 460
  readonly property int sectionListWidth: 180
  // The id names the text in Language.qml
  readonly property var sections: ["colors", "fonts", "windows", "cursor"]
  property bool shown: false
  // The mouse and the arrows move the same selection
  property int selectedIndex: 0
  readonly property string selectedSection: sections[selectedIndex]
  property bool isConfirmingReset: false

  implicitWidth: panelWidth
  implicitHeight: panelHeight
  color: "transparent"
  visible: shown || fade.running
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "cuckoo-theme-panel"
  WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  // Hyprland sends super+T here (quickshell:theme in hyprland.conf)
  GlobalShortcut {
    name: "theme"
    description: "Open or close the theme panel"
    onPressed: root.toggle()
  }

  // Clicking outside the card closes it
  HyprlandFocusGrab {
    windows: [root]
    active: root.shown
    onCleared: root.close()
  }

  Rectangle {
    id: card
    anchors.fill: parent
    radius: Theme.themePanelRadius
    color: Theme.card
    border.width: 1
    border.color: Theme.line
    opacity: root.shown ? 1 : 0
    focus: true
    Keys.onEscapePressed: root.close()
    Keys.onUpPressed: root.selectedIndex = (root.selectedIndex + root.sections.length - 1) % root.sections.length
    Keys.onDownPressed: root.selectedIndex = (root.selectedIndex + 1) % root.sections.length
    // Right and Tab go into the section, Left comes back. The keys the section does not use
    // come up to the card, so Esc closes from anywhere
    Keys.onRightPressed: root.focusSectionContent()
    Keys.onTabPressed: root.focusSectionContent()
    Keys.onLeftPressed: card.forceActiveFocus()

    Behavior on opacity {
      NumberAnimation { id: fade; duration: 220; easing.type: Easing.OutCubic }
    }

    // Title on the left, close button on the right
    Item {
      id: header
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 24
      height: 28

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Language.text("appearance")
        color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 16; font.weight: Font.DemiBold
      }

      Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 28; height: 28
        radius: Theme.cornerRadius
        color: closeHover.hovered ? Theme.hover : "transparent"

        Text {
          anchors.centerIn: parent
          text: String.fromCodePoint(0xf0156)
          color: Theme.text; font.family: Theme.iconFont; font.pixelSize: 16
        }

        HoverHandler { id: closeHover }
        TapHandler { onTapped: root.close() }
      }
    }

    // One row for each section, on the left
    Column {
      id: sectionList
      anchors.top: header.bottom
      anchors.left: parent.left
      anchors.bottom: parent.bottom
      anchors.topMargin: 20
      anchors.leftMargin: 24
      anchors.bottomMargin: 24
      width: root.sectionListWidth
      spacing: 4

      Repeater {
        model: root.sections
        delegate: Rectangle {
          required property string modelData
          required property int index
          readonly property bool highlighted: index === root.selectedIndex
          width: parent.width
          height: 40
          radius: Theme.themePanelSectionRadius
          color: highlighted || sectionHover.hovered ? Theme.selected : "transparent"
          border.width: 1
          border.color: highlighted ? Theme.accentLine : "transparent"

          Text {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: Language.text(modelData)
            color: highlighted ? Theme.accent : Theme.soft
            font.family: Theme.fontFamily; font.pixelSize: 14
            font.weight: highlighted ? Font.DemiBold : Font.Medium
          }

          HoverHandler { id: sectionHover }
          TapHandler { onTapped: root.selectedIndex = index }
        }
      }
    }

    // Reset, at the bottom of the sections. The first click asks to confirm,
    // so one click by mistake changes nothing
    Rectangle {
      anchors.left: sectionList.left
      anchors.right: sectionList.right
      anchors.bottom: sectionList.bottom
      height: 40
      radius: Theme.themePanelSectionRadius
      color: root.isConfirmingReset ? Theme.redSoft : resetHover.hovered ? Theme.selected : "transparent"
      border.width: 1
      border.color: root.isConfirmingReset ? Theme.redLine : "transparent"

      Text {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        text: Language.text(root.isConfirmingReset ? "confirmReset" : "reset")
        color: root.isConfirmingReset ? Theme.red : Theme.soft
        font.family: Theme.fontFamily; font.pixelSize: 14
        font.weight: root.isConfirmingReset ? Font.DemiBold : Font.Medium
      }

      HoverHandler { id: resetHover }
      TapHandler { onTapped: root.pressReset() }
    }

    // Without a second click, the button goes back to Reset
    Timer {
      id: resetConfirmTimer
      interval: 3000
      onTriggered: root.isConfirmingReset = false
    }

    // Line between the sections and the content
    Rectangle {
      id: divider
      anchors.top: sectionList.top
      anchors.bottom: sectionList.bottom
      anchors.left: sectionList.right
      anchors.leftMargin: 16
      width: 1
      color: Theme.line
    }

    // The content of the chosen section. A section with a focusItem can take the keyboard
    Column {
      id: sectionContent
      anchors.top: sectionList.top
      anchors.left: divider.right
      anchors.right: parent.right
      anchors.leftMargin: 24
      anchors.rightMargin: 24
      spacing: 20

      Text {
        text: Language.text(root.selectedSection)
        color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 15; font.weight: Font.DemiBold
      }

      ThemeColorsSection {
        width: parent.width
        visible: root.selectedSection === "colors"
      }

      ThemeFontsSection {
        width: parent.width
        visible: root.selectedSection === "fonts"
      }

      ThemeWindowsSection {
        width: parent.width
        visible: root.selectedSection === "windows"
      }

      ThemeCursorSection {
        width: parent.width
        visible: root.selectedSection === "cursor"
        active: root.shown && visible
      }
    }
  }

  // A hidden section loses the keyboard, so the card takes it back
  onSelectedIndexChanged: card.forceActiveFocus()

  function focusSectionContent() {
    for (var i = 0; i < sectionContent.children.length; i++) {
      var section = sectionContent.children[i];
      if (section.visible && section.focusItem) section.focusItem.forceActiveFocus();
    }
  }

  // Open on the screen that has the focus, on the first section
  function open() {
    var focusedName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
    screen = Quickshell.screens.find(s => s.name === focusedName) || Quickshell.screens[0];
    selectedIndex = 0;
    shown = true;
    card.forceActiveFocus();
  }
  function close() {
    shown = false;
    isConfirmingReset = false;
  }

  // The sliders and the palettes read the theme, so they go back by themselves
  function pressReset() {
    if (!isConfirmingReset) {
      isConfirmingReset = true;
      resetConfirmTimer.restart();
      return;
    }
    isConfirmingReset = false;
    resetConfirmTimer.stop();
    Quickshell.execDetached(["cuckoo-theme", "reset"]);
  }
  function toggle() {
    if (shown) close();
    else open();
  }
}
