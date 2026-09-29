import Quickshell
import Quickshell.Hyprland
import QtQuick

// Workspaces on this screen. Click to activate, scroll to move between them.
Row {
  id: root

  required property var screen
  readonly property var monitor: Hyprland.monitorFor(screen)

  spacing: 2

  Repeater {
    model: root.workspacesOnMonitor()

    Rectangle {
      id: button

      required property var modelData
      readonly property bool isActive: modelData.active
      readonly property bool isUrgent: modelData.urgent

      implicitWidth: Math.max(28, name.implicitWidth + 16)
      implicitHeight: 20
      radius: Theme.cornerRadius
      color: isActive ? Theme.glass : (hover.hovered ? Qt.rgba(1, 1, 1, 0.12) : "transparent")

      Text {
        id: name
        anchors.centerIn: parent
        text: button.modelData.name
        color: button.isUrgent ? Theme.red : (button.isActive || hover.hovered ? Theme.text : Theme.dim)
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.weight: Font.DemiBold
      }

      HoverHandler {
        id: hover
      }
      TapHandler {
        onTapped: Hyprland.dispatch("workspace " + button.modelData.id)
      }
    }
  }

  WheelHandler {
    onWheel: function (event) {
      if (event.angleDelta.y > 0)
        Hyprland.dispatch("workspace e+1");
      else
        Hyprland.dispatch("workspace e-1");
    }
  }

  // Only the workspaces of this monitor, without special ones, sorted by id
  function workspacesOnMonitor() {
    var all = Hyprland.workspaces.values;
    var mine = [];
    for (var i = 0; i < all.length; i++) {
      var workspace = all[i];
      if (workspace.id > 0 && workspace.monitor === monitor)
        mine.push(workspace);
    }
    mine.sort(function (first, second) {
      return first.id - second.id;
    });
    return mine;
  }
}
