import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Music card: title, artist and the play controls.
BarPopup {
  id: root

  readonly property var player: pickPlayer()
  readonly property bool playing: player && player.playbackState === MprisPlaybackState.Playing

  implicitWidth: 280
  implicitHeight: column.implicitHeight + 20

  Column {
    id: column
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.leftMargin: 10
    anchors.rightMargin: 10
    anchors.topMargin: 12
    spacing: 8

    Column {
      anchors.left: parent.left
      anchors.right: parent.right
      spacing: 2

      Text {
        width: parent.width
        text: root.player ? root.player.trackTitle : ""
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.weight: Font.DemiBold
        elide: Text.ElideRight
      }
      Text {
        width: parent.width
        text: root.player ? root.player.trackArtist : ""
        color: Theme.subtitle
        font.family: Theme.fontFamily
        font.pixelSize: 12
        elide: Text.ElideRight
      }
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 18

      MediaButton {
        icon: "󰒮"
        onClicked: if (root.player)
          root.player.previous()
      }
      MediaButton {
        icon: root.playing ? "󰏤" : "󰐊"
        onClicked: if (root.player)
          root.player.togglePlaying()
      }
      MediaButton {
        icon: "󰒭"
        onClicked: if (root.player)
          root.player.next()
      }
      MediaButton {
        icon: "󰅖"
        danger: true
        onClicked: root.close()
      }
    }
  }

  component MediaButton: Rectangle {
    id: button
    property string icon: ""
    property bool danger: false
    signal clicked

    width: 44
    height: 28
    radius: Theme.cornerRadius
    color: hover.hovered ? (danger ? Qt.rgba(1, 105 / 255, 97 / 255, 0.16) : Theme.hover) : "transparent"

    Text {
      anchors.centerIn: parent
      text: button.icon
      font.family: Theme.iconFont
      font.pixelSize: 15
      color: hover.hovered ? (button.danger ? Theme.red : Theme.text) : Theme.soft
    }

    HoverHandler {
      id: hover
    }
    TapHandler {
      onTapped: button.clicked()
    }
  }

  function pickPlayer() {
    var players = Mpris.players.values;
    if (players.length === 0)
      return null;
    for (var i = 0; i < players.length; i++)
      if (players[i].playbackState === MprisPlaybackState.Playing)
        return players[i];
    return players[0];
  }
}
