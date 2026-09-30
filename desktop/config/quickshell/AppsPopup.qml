import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

BarPopup {
  id: root
  readonly property var windows: ToplevelManager.toplevels.values.slice(3)

  implicitWidth: 300
  implicitHeight: Math.min(column.implicitHeight + 20, 380)

  Flickable {
    anchors.fill: parent
    anchors.leftMargin: 8; anchors.rightMargin: 8; anchors.topMargin: 12; anchors.bottomMargin: 8
    contentHeight: column.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
      id: column
      width: parent.width
      spacing: 2
      Repeater {
        model: root.windows
        delegate: Rectangle {
          required property var modelData
          anchors.left: parent.left; anchors.right: parent.right
          height: 36
          radius: Theme.cornerRadius
          color: hover.hovered ? Qt.rgba(1, 1, 1, 0.14) : (modelData.activated ? Qt.rgba(1, 1, 1, 0.10) : "transparent")
          Row {
            anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 10
            IconImage {
              anchors.verticalCenter: parent.verticalCenter
              implicitSize: 20
              source: root.iconFor(modelData.appId)
            }
            Text {
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 30
              text: modelData.title
              color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 13
              elide: Text.ElideRight
            }
          }
          HoverHandler { id: hover }
          TapHandler { onTapped: { modelData.activate(); root.close(); } }
        }
      }
    }
  }

  function iconFor(appId) {
    if (!appId) return Quickshell.iconPath("application-x-executable");
    var entry = DesktopEntries.heuristicLookup(appId);
    if (entry && entry.icon) return Quickshell.iconPath(entry.icon, "application-x-executable");
    return Quickshell.iconPath(appId.toLowerCase(), "application-x-executable");
  }
}
