import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Music from the active MPRIS player. Hidden when there is nothing playing or paused.
Item {
  id: root

  readonly property var player: pickPlayer()
  readonly property bool playing: player && player.playbackState === MprisPlaybackState.Playing
  readonly property bool paused: player && player.playbackState === MprisPlaybackState.Paused

  visible: playing || paused
  implicitWidth: visible ? Math.max(256, card.implicitWidth + 24) : 0
  implicitHeight: Theme.barHeight

  signal activated

  Rectangle {
    id: card
    anchors.fill: parent
    anchors.topMargin: 3
    anchors.bottomMargin: 3
    radius: Theme.cornerRadius
    color: hover.hovered ? Theme.glass : "transparent"
    implicitWidth: row.implicitWidth

    Row {
      id: row
      anchors.centerIn: parent
      spacing: 8

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.playing ? root.playerIcon() : "󰏤"
        color: root.playing ? Theme.text : Theme.dim
        font.family: Theme.iconFont
        font.pixelSize: 16
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.player ? root.player.trackTitle : ""
        color: root.playing ? Theme.text : Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        elide: Text.ElideRight
        maximumLineCount: 1
        width: Math.min(implicitWidth, 210)
      }
    }
  }

  HoverHandler {
    id: hover
  }
  WheelHandler {
    onWheel: function (event) {
      if (!root.player)
        return;
      if (event.angleDelta.y > 0)
        root.player.next();
      else
        root.player.previous();
    }
  }
  TapHandler {
    acceptedButtons: Qt.MiddleButton
    onTapped: if (root.player)
      root.player.togglePlaying()
  }
  TapHandler {
    acceptedButtons: Qt.LeftButton
    onTapped: root.activated()
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

  function playerIcon() {
    if (!player)
      return "󰎆";
    var name = (player.desktopEntry || player.identity || "").toLowerCase();
    if (name.indexOf("spotify") >= 0)
      return "󰓇";
    if (name.indexOf("firefox") >= 0)
      return "󰈹";
    if (name.indexOf("brave") >= 0)
      return "󰖟";
    if (name.indexOf("chromium") >= 0 || name.indexOf("chrome") >= 0)
      return "󰖟";
    return "󰎆";
  }
}
