pragma Singleton

import Quickshell
import QtQuick

// One source of truth for the bar look: sizes, fonts and colors.
Singleton {
  // Sizes
  readonly property int barHeight: 30
  readonly property int cornerRadius: 7

  // Fonts
  readonly property string fontFamily: "Adwaita Sans"
  readonly property string iconFont: "JetBrainsMono Nerd Font Propo"
  readonly property int fontSize: 13
  readonly property int fontWeight: Font.Medium

  // Text, from strong to soft
  readonly property color text: "#ffffff"
  readonly property color soft: Qt.rgba(1, 1, 1, 0.85)
  readonly property color dim: Qt.rgba(1, 1, 1, 0.50)

  // White layers on the dark cards, from light to strong
  readonly property color selected: Qt.rgba(1, 1, 1, 0.10)
  readonly property color line: Qt.rgba(1, 1, 1, 0.12)
  readonly property color hover: Qt.rgba(1, 1, 1, 0.14)
  readonly property color glass: Qt.rgba(1, 1, 1, 0.22)

  readonly property color red: "#ff6961"
  readonly property color amber: "#ffd60a"

  // Bar background, dark glass from top to bottom
  readonly property color barTop: Qt.rgba(0, 0, 0, 0.28)
  readonly property color barBottom: Qt.rgba(0, 0, 0, 0.10)

  // One dark background for every card: popups, launcher and power menu
  readonly property color background: "#161a1f"
  readonly property real backgroundOpacity: 0.90
  readonly property color card: Qt.rgba(background.r, background.g, background.b, backgroundOpacity)
  // The bar popups start transparent on top, so they come out of the bar
  readonly property color cardTransparent: Qt.rgba(background.r, background.g, background.b, 0)
  readonly property int cardRadius: 14

  // App launcher
  readonly property int launcherRadius: 18
  readonly property int launcherFieldRadius: 12
  readonly property int launcherCellRadius: 14

  // Power menu: lilac on hover and red to shut down
  readonly property int powerMenuRadius: 20
  readonly property int powerButtonRadius: 15
  readonly property int powerIconRadius: 10
  readonly property color powerAccent: "#9d7dea"
  readonly property color powerAccentSoft: Qt.rgba(157 / 255, 125 / 255, 234 / 255, 0.12)
  readonly property color powerAccentBorder: Qt.rgba(157 / 255, 125 / 255, 234 / 255, 0.22)
  readonly property color powerAvatarBorder: Qt.rgba(157 / 255, 125 / 255, 234 / 255, 0.30)
  readonly property color powerRed: "#f87171"
  readonly property color powerRedSoft: Qt.rgba(248 / 255, 113 / 255, 113 / 255, 0.12)
  readonly property color powerRedHover: Qt.rgba(248 / 255, 113 / 255, 113 / 255, 0.08)
  readonly property color powerRedBorder: Qt.rgba(248 / 255, 113 / 255, 113 / 255, 0.22)
}
