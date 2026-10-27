pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// One source of truth for the bar look: sizes, fonts and colors.
// The accent and the font come from the theme, so they change live with cuckoo-theme.
Singleton {
  // The theme made by cuckoo-theme. Until that file exists, the default theme of the package.
  FileView {
    path: Quickshell.env("HOME") + "/.config/cuckoo/theme/theme.json"
    blockLoading: true
    watchChanges: true
    onFileChanged: reload()
    JsonAdapter {
      id: chosenTheme
      property string accent
      property string font
    }
  }
  FileView {
    path: "/usr/share/cuckoo/theme.json"
    blockLoading: true
    JsonAdapter {
      id: defaultTheme
      property string accent
      property string font
    }
  }

  // Sizes
  readonly property int barHeight: 30
  readonly property int cornerRadius: 7

  // Fonts
  readonly property string fontFamily: chosenTheme.font || defaultTheme.font
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
  readonly property color accent: chosenTheme.accent || defaultTheme.accent
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

  // Theme panel, the same shape as the launcher
  readonly property int themePanelRadius: launcherRadius

  // Power menu
  readonly property int powerMenuRadius: 20
  readonly property int powerButtonRadius: 15
  readonly property int powerIconRadius: 10
}
