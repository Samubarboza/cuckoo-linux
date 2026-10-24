pragma Singleton

import Quickshell
import QtQuick

// One source of truth for the bar look: sizes, fonts and colors.
Singleton {
  // Sizes
  readonly property int barHeight: 30
  readonly property int cornerRadius: 7

  // Fonts
  readonly property string fontFamily: "IBM Plex Sans"
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

  // Accent and alerts: soft colors from one family. The soft and line versions follow their color
  readonly property color accent: "#89b4fa"
  readonly property color accentSoft: Qt.rgba(accent.r, accent.g, accent.b, 0.12)
  readonly property color accentLine: Qt.rgba(accent.r, accent.g, accent.b, 0.22)
  readonly property color red: "#f38ba8"
  readonly property color redSoft: Qt.rgba(red.r, red.g, red.b, 0.12)
  readonly property color redLine: Qt.rgba(red.r, red.g, red.b, 0.22)
  readonly property color amber: "#f9e2af"

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

  // Power menu
  readonly property int powerMenuRadius: 20
  readonly property int powerButtonRadius: 15
  readonly property int powerIconRadius: 10
}
