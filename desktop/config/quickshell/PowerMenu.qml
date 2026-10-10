import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

// Power menu: suspend, lock, log out, restart and shut down, in the middle of the screen.
PanelWindow {
  id: root

  // 360 px window with a 20 px gap around the card
  readonly property int menuWidth: 360
  readonly property int cardMargin: 20
  readonly property int cardPadding: 32
  readonly property int avatarSize: 100
  readonly property string userName: Quickshell.env("USER")
  // The id names the text in Language.qml and the icon in /usr/share/cuckoo/icons
  readonly property var powerActions: [
    { id: "suspend", command: ["systemctl", "suspend"], iconBackground: Theme.powerAccentSoft },
    { id: "lock", command: ["loginctl", "lock-session"], iconBackground: Theme.powerAccentSoft },
    { id: "logout", command: ["hyprctl", "dispatch", "exit"], iconBackground: Theme.powerAccentSoft },
    { id: "reboot", command: ["systemctl", "reboot"], iconBackground: Theme.powerIconNeutral },
    { id: "shutdown", command: ["systemctl", "poweroff"], iconBackground: Theme.powerRedSoft, danger: true }
  ]
  property bool shown: false
  // The mouse and the arrows move the same selection
  property int selectedIndex: 0

  implicitWidth: menuWidth
  implicitHeight: content.implicitHeight + 2 * (cardMargin + cardPadding)
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
    anchors.margins: root.cardMargin
    radius: Theme.powerMenuRadius
    color: Theme.powerMenuBackground
    border.width: 1
    border.color: Theme.powerMenuLine
    opacity: root.shown ? 1 : 0
    focus: true
    Keys.onEscapePressed: root.close()
    Keys.onUpPressed: root.selectedIndex = (root.selectedIndex + root.powerActions.length - 1) % root.powerActions.length
    Keys.onDownPressed: root.selectedIndex = (root.selectedIndex + 1) % root.powerActions.length

    Behavior on opacity {
      NumberAnimation { id: fade; duration: 220; easing.type: Easing.OutCubic }
    }

    Column {
      id: content
      anchors.fill: parent
      anchors.margins: root.cardPadding

      // User photo, name and system name
      Item {
        width: parent.width
        implicitHeight: header.height + 24

        Row {
          id: header
          x: 6; y: 8
          spacing: 14

          ClippingRectangle {
            id: avatar
            width: root.avatarSize; height: root.avatarSize
            radius: root.avatarSize / 2
            color: Theme.powerAccentSoft
            border.width: 1
            border.color: Theme.powerAvatarBorder

            // Without ~/.face, the first letter of the name
            Text {
              anchors.centerIn: parent
              visible: photo.status !== Image.Ready
              text: root.userName.charAt(0).toUpperCase()
              color: Theme.powerAccent; font.family: Theme.fontFamily; font.pixelSize: 40; font.weight: Font.DemiBold
            }
            Image {
              id: photo
              anchors.fill: parent
              source: "file://" + Quickshell.env("HOME") + "/.face"
              fillMode: Image.PreserveAspectCrop
            }
          }

          Column {
            anchors.verticalCenter: avatar.verticalCenter
            spacing: 3
            Text {
              text: root.userName
              color: Theme.powerMenuName; font.family: Theme.fontFamily; font.pixelSize: 16; font.weight: Font.DemiBold
            }
            Text {
              text: "cuckoo linux"
              color: Theme.dim; font.family: Theme.fontFamily; font.pixelSize: 13
            }
          }
        }
      }

      // Line between the header and the buttons
      Item {
        width: parent.width
        implicitHeight: 21
        Rectangle {
          anchors.left: parent.left; anchors.right: parent.right
          anchors.leftMargin: 4; anchors.rightMargin: 4
          anchors.verticalCenter: parent.verticalCenter
          height: 1
          color: Theme.powerMenuLine
        }
      }

      // One button for each action
      Repeater {
        model: root.powerActions
        delegate: Item {
          required property var modelData
          required property int index
          // Shut down stays red, the others turn lilac when selected
          readonly property bool danger: modelData.danger === true
          readonly property bool highlighted: index === root.selectedIndex
          width: parent.width
          implicitHeight: 70

          Rectangle {
            anchors.fill: parent
            anchors.topMargin: 3; anchors.bottomMargin: 3
            radius: Theme.powerButtonRadius
            color: !highlighted ? "transparent" : danger ? Theme.powerRedHover : Theme.powerMenuHover
            border.width: 1
            border.color: !highlighted ? "transparent" : danger ? Theme.powerRedBorder : Theme.powerAccentBorder

            Row {
              anchors.fill: parent
              anchors.leftMargin: 14; anchors.rightMargin: 14
              spacing: 14

              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 42; height: 42
                radius: Theme.powerIconRadius
                color: modelData.iconBackground
                Image {
                  anchors.centerIn: parent
                  source: "file:///usr/share/cuckoo/icons/" + modelData.id + ".svg"
                  sourceSize.width: 24; sourceSize.height: 24
                }
              }
              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Language.text(modelData.id)
                color: danger ? Theme.powerRed : highlighted ? Theme.powerAccent : Theme.powerMenuLabel
                font.family: Theme.fontFamily; font.pixelSize: 15
                font.weight: danger || highlighted ? Font.DemiBold : Font.Medium
              }
            }
          }

          HoverHandler { onHoveredChanged: if (hovered) root.selectedIndex = index }
        }
      }
    }
  }

  // Open on the screen that has the focus
  function open() {
    var focusedName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
    screen = Quickshell.screens.find(s => s.name === focusedName) || Quickshell.screens[0];
    selectedIndex = 0;
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
