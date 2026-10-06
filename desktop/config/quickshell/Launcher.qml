import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

// App launcher: a search box and a grid of the installed apps, in the middle of the screen.
PanelWindow {
  id: root

  readonly property int columns: 7
  readonly property int rows: 5
  readonly property int iconSize: 56
  property bool shown: false
  property string query: ""
  readonly property var installedApps: DesktopEntries.applications.values
    .filter(entry => !entry.noDisplay)
    .sort((a, b) => a.name.localeCompare(b.name))
  readonly property var foundApps: installedApps.filter(entry => entry.name.toLowerCase().includes(query.toLowerCase()))

  implicitWidth: screen ? Math.round(screen.width * 0.7) : 900
  implicitHeight: content.implicitHeight + 48
  color: "transparent"
  visible: shown || fade.running
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "cuckoo-launcher"
  WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  // Clicking outside the card closes it
  HyprlandFocusGrab {
    windows: [root]
    active: root.shown
    onCleared: root.close()
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.launcherRadius
    color: Theme.launcherBackground
    border.width: 1
    border.color: Theme.launcherBorder
    opacity: root.shown ? 1 : 0

    Behavior on opacity {
      NumberAnimation { id: fade; duration: 220; easing.type: Easing.OutCubic }
    }

    Column {
      id: content
      anchors.fill: parent
      anchors.margins: 24
      spacing: 20

      Rectangle {
        width: parent.width
        height: 40
        radius: Theme.launcherFieldRadius
        color: Theme.launcherField

        Row {
          anchors.fill: parent
          anchors.leftMargin: 16; anchors.rightMargin: 16
          spacing: 8
          Text {
            id: searchIcon
            anchors.verticalCenter: parent.verticalCenter
            text: String.fromCodePoint(0xf0349)
            color: Theme.text; font.family: Theme.iconFont; font.pixelSize: 16
          }
          TextInput {
            id: search
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - searchIcon.width - parent.spacing
            color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 14
            clip: true
            onTextChanged: {
              root.query = text;
              grid.currentIndex = 0;
            }
            Keys.onPressed: function (event) { root.handleKey(event); }

            Text {
              visible: !search.text
              text: "Search..."
              color: Theme.dim; font: search.font
            }
          }
        }
      }

      Item {
        width: parent.width
        height: grid.cellHeight * root.rows

        GridView {
          id: grid
          anchors.fill: parent
          cellWidth: width / root.columns
          cellHeight: root.iconSize + 54
          model: root.foundApps
          keyNavigationWraps: true
          boundsBehavior: Flickable.StopAtBounds
          clip: true

          delegate: Item {
            required property var modelData
            required property int index
            readonly property bool selected: index === grid.currentIndex
            width: grid.cellWidth
            height: grid.cellHeight

            Rectangle {
              anchors.fill: parent
              anchors.margins: 5
              radius: Theme.launcherCellRadius
              color: selected ? Theme.launcherField : "transparent"
              border.width: selected ? 1 : 0
              border.color: Theme.launcherBorder

              Column {
                anchors.centerIn: parent
                width: parent.width - 12
                spacing: 8
                IconImage {
                  anchors.horizontalCenter: parent.horizontalCenter
                  implicitSize: root.iconSize
                  source: root.iconFor(modelData)
                }
                Text {
                  width: parent.width
                  horizontalAlignment: Text.AlignHCenter
                  elide: Text.ElideRight
                  text: modelData.name
                  color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 12
                }
              }
            }

            HoverHandler { onHoveredChanged: if (hovered) grid.currentIndex = index }
            TapHandler { onTapped: root.launch(index) }
          }
        }

        Text {
          anchors.centerIn: parent
          visible: root.foundApps.length === 0
          text: "No apps found"
          color: Theme.dim; font.family: Theme.fontFamily; font.pixelSize: 14
        }
      }
    }
  }

  function handleKey(event) {
    if (event.key === Qt.Key_Escape) close();
    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) launch(grid.currentIndex);
    else if (event.key === Qt.Key_Left) grid.moveCurrentIndexLeft();
    else if (event.key === Qt.Key_Right) grid.moveCurrentIndexRight();
    else if (event.key === Qt.Key_Up) grid.moveCurrentIndexUp();
    else if (event.key === Qt.Key_Down) grid.moveCurrentIndexDown();
    else return;
    event.accepted = true;
  }

  // Some apps give a full file path as their icon instead of a theme name
  function iconFor(entry) {
    if (entry.icon.startsWith("/")) return "file://" + entry.icon;
    return Quickshell.iconPath(entry.icon, "application-x-executable");
  }

  function launch(appIndex) {
    if (appIndex < 0 || appIndex >= foundApps.length) return;
    foundApps[appIndex].execute();
    close();
  }

  // Open on the screen that has the focus, with an empty search
  function open() {
    var focusedName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
    screen = Quickshell.screens.find(s => s.name === focusedName) || Quickshell.screens[0];
    search.text = "";
    grid.currentIndex = 0;
    grid.positionViewAtBeginning();
    shown = true;
    search.forceActiveFocus();
  }
  function close() {
    shown = false;
  }
  function toggle() {
    if (shown) close();
    else open();
  }
}
