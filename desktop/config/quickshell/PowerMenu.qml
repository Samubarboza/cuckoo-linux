import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

// Power menu: suspend, lock, log out, restart and shut down, in the middle of the screen.
PanelWindow {
  id: root

  property bool shown: false

  implicitWidth: content.implicitWidth
  implicitHeight: content.implicitHeight
  color: "transparent"
  visible: shown || fade.running
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "cuckoo-power-menu"
  WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  // Hyprland sends super+X here (quickshell:power in hyprland.conf)
  GlobalShortcut {
    name: "power"
    description: "Open or close the power menu"
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
    radius: Theme.powerMenuRadius
    color: Theme.powerMenuBackground
    border.width: 1
    border.color: Theme.powerMenuLine
    opacity: root.shown ? 1 : 0
    focus: true
    Keys.onEscapePressed: root.close()

    Behavior on opacity {
      NumberAnimation { id: fade; duration: 220; easing.type: Easing.OutCubic }
    }

    Column {
      id: content
      anchors.fill: parent
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
