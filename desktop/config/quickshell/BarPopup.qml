import Quickshell
import Quickshell.Hyprland
import QtQuick

// A card that drops down from the bar. Fixed position, closes on click outside.
// Reused by the music, system and wifi popups.
PopupWindow {
  id: root

  required property var barWindow
  property int anchorX: 0
  property bool shown: false
  property double lastCleared: 0
  default property alias content: holder.data

  anchor.window: barWindow
  anchor.rect.x: anchorX
  anchor.rect.y: barWindow.height
  color: "transparent"
  visible: shown || fade.running

  // Clicking outside the card clears the grab and closes it
  HyprlandFocusGrab {
    windows: [root]
    active: root.shown
    onCleared: {
      root.shown = false;
      root.lastCleared = Date.now();
    }
  }

  Rectangle {
    id: card
    anchors.fill: parent
    radius: Theme.cardRadius
    opacity: root.shown ? 1 : 0

    gradient: Gradient {
      GradientStop {
        position: 0.0
        color: Theme.cardFade0
      }
      GradientStop {
        position: Math.min(1, 26 / root.height)
        color: Theme.cardFade1
      }
      GradientStop {
        position: Math.min(1, 60 / root.height)
        color: Theme.cardFade2
      }
      GradientStop {
        position: 1.0
        color: Theme.cardFade3
      }
    }

    Behavior on opacity {
      NumberAnimation {
        id: fade
        duration: 220
        easing.type: Easing.OutCubic
      }
    }
    transform: Translate {
      y: root.shown ? 0 : -10
      Behavior on y {
        NumberAnimation {
          duration: 220
          easing.type: Easing.OutCubic
        }
      }
    }

    Item {
      id: holder
      anchors.fill: parent
    }
  }

  function open() {
    shown = true;
  }
  function close() {
    shown = false;
  }
  // Ignore the click that just closed it, so the same button does not reopen it
  function toggle() {
    if (Date.now() - lastCleared < 250)
      return;
    shown = !shown;
  }
}
