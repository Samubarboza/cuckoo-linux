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
  readonly property color cardFade1: Qt.rgba(24 / 255, 24 / 255, 26 / 255, 0.55)
  readonly property color cardFade2: Qt.rgba(24 / 255, 24 / 255, 26 / 255, 0.78)
  readonly property color cardFade3: Qt.rgba(24 / 255, 24 / 255, 26 / 255, 0.85)
}
