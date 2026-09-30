import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

// Open windows. The arrow (left) reveals up to 3 icons to its right. "+N" opens the rest in a popup.
Row {
  id: root
  spacing: 4
  property bool expanded: false
  readonly property var windows: ToplevelManager.toplevels.values

  signal overflowClicked

  BarItem {
    Text {
      text: String.fromCodePoint(0xf0141)
      color: root.expanded ? Theme.text : Theme.soft
      font.family: Theme.iconFont
      font.pixelSize: 16
    }
    onClicked: root.expanded = !root.expanded
  }

  Row {
    id: shown
    spacing: 4
    clip: true
    width: root.expanded ? implicitWidth : 0
    opacity: root.expanded ? 1 : 0
    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 150 } }

    Repeater {
      model: Math.min(root.windows.length, 3)
      delegate: AppIcon { toplevel: root.windows[index] }
    }
    BarItem {
      visible: root.windows.length > 3
      Text {
        text: "+" + (root.windows.length - 3)
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.weight: Font.DemiBold
      }
      onClicked: root.overflowClicked()
    }
  }

  component AppIcon: Item {
    property var toplevel
    width: 30
    height: Theme.barHeight

    Rectangle {
      anchors.fill: parent
      anchors.topMargin: 3
      anchors.bottomMargin: 3
      radius: Theme.cornerRadius
      color: hover.hovered ? Theme.hover : "transparent"
    }
    IconImage {
      anchors.centerIn: parent
      implicitSize: 18
      source: root.iconFor(toplevel ? toplevel.appId : "")
    }
    HoverHandler { id: hover }
    TapHandler { onTapped: if (toplevel) toplevel.activate() }
  }

  function iconFor(appId) {
    if (!appId) return Quickshell.iconPath("application-x-executable");
    var entry = DesktopEntries.heuristicLookup(appId);
    if (entry && entry.icon) return Quickshell.iconPath(entry.icon, "application-x-executable");
    return Quickshell.iconPath(appId.toLowerCase(), "application-x-executable");
  }
}
