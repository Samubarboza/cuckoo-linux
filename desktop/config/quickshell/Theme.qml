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

  // Colors
  readonly property color text: "#ffffff"
  readonly property color soft: Qt.rgba(1, 1, 1, 0.85)
  readonly property color dim: Qt.rgba(1, 1, 1, 0.45)
  readonly property color glass: Qt.rgba(1, 1, 1, 0.22)
  readonly property color hover: Qt.rgba(1, 1, 1, 0.14)
  readonly property color red: "#ff6961"
  readonly property color amber: "#ffd60a"

  // Bar background, dark glass from top to bottom
  readonly property color barTop: Qt.rgba(0, 0, 0, 0.28)
  readonly property color barBottom: Qt.rgba(0, 0, 0, 0.10)

  // Popup cards: transparent on top, darker to the bottom
  readonly property int cardRadius: 14
  readonly property color subtitle: Qt.rgba(1, 1, 1, 0.55)
  readonly property color cardFade0: Qt.rgba(24 / 255, 24 / 255, 26 / 255, 0.0)
  readonly property color cardFade1: Qt.rgba(24 / 255, 24 / 255, 26 / 255, 0.86)
  readonly property color cardFade2: Qt.rgba(24 / 255, 24 / 255, 26 / 255, 0.95)
  readonly property color cardFade3: Qt.rgba(24 / 255, 24 / 255, 26 / 255, 0.98)

  // App launcher: dark glass card with a soft border
  readonly property int launcherRadius: 18
  readonly property int launcherFieldRadius: 12
  readonly property int launcherCellRadius: 14
  readonly property color launcherBackground: Qt.rgba(29 / 255, 31 / 255, 33 / 255, 0.53)
  readonly property color launcherField: Qt.rgba(42 / 255, 45 / 255, 49 / 255, 0.60)
  readonly property color launcherBorder: Qt.rgba(1, 1, 1, 0.13)

  // Power menu: dark card, lilac on hover and red to shut down
  readonly property int powerMenuRadius: 20
  readonly property int powerButtonRadius: 15
  readonly property int powerIconRadius: 10
  readonly property color powerMenuBackground: Qt.rgba(22 / 255, 26 / 255, 31 / 255, 0.914)
  readonly property color powerMenuLine: Qt.rgba(1, 1, 1, 0.07)
  readonly property color powerMenuName: "#e8e8f0"
  readonly property color powerMenuLabel: Qt.rgba(1, 1, 1, 0.75)
  readonly property color powerMenuHover: Qt.rgba(218 / 255, 218 / 255, 218 / 255, 0.10)
  readonly property color powerAccent: "#9d7dea"
  readonly property color powerAccentSoft: Qt.rgba(157 / 255, 125 / 255, 234 / 255, 0.12)
  readonly property color powerAccentBorder: Qt.rgba(157 / 255, 125 / 255, 234 / 255, 0.22)
  readonly property color powerAvatarBorder: Qt.rgba(157 / 255, 125 / 255, 234 / 255, 0.30)
  readonly property color powerRed: "#f87171"
  readonly property color powerRedSoft: Qt.rgba(248 / 255, 113 / 255, 113 / 255, 0.12)
  readonly property color powerRedHover: Qt.rgba(248 / 255, 113 / 255, 113 / 255, 0.08)
  readonly property color powerRedBorder: Qt.rgba(248 / 255, 113 / 255, 113 / 255, 0.22)
  readonly property color powerIconNeutral: Qt.rgba(1, 1, 1, 0.08)
}
