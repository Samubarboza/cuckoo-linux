import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

// Theme panel: the look of the desktop, in the middle of the screen. A sibling of the app launcher.
PanelWindow {
  id: root

  readonly property int panelWidth: 720
  readonly property int panelHeight: 460
  property bool shown: false

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
  }

  // Open on the screen that has the focus
  function open() {
    var focusedName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
    screen = Quickshell.screens.find(s => s.name === focusedName) || Quickshell.screens[0];
    shown = true;
    card.forceActiveFocus();
  }
  function close() {
    shown = false;
  }
  function toggle() {
    if (shown) close();
    else open();
  }
}
