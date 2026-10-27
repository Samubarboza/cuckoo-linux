pragma Singleton

import Quickshell
import QtQuick

// The desktop texts, in the system language.
Singleton {
  readonly property var textsByLanguage: ({
    en: { suspend: "Suspend", lock: "Lock", logout: "Log out", reboot: "Restart", shutdown: "Shut down", appearance: "Appearance", colors: "Colors", fonts: "Fonts", windows: "Windows", cursor: "Cursor", accent: "Theme color", transparency: "Transparency", border: "Border", borderSize: "Thickness", borderColor: "Border color", rounding: "Corners", system: "System", terminal: "Terminal", cursorSize: "Size", reset: "Reset", confirmReset: "Confirm" },
    es: { suspend: "Suspender", lock: "Bloquear", logout: "Cerrar sesión", reboot: "Reiniciar", shutdown: "Apagar", appearance: "Apariencia", colors: "Colores", fonts: "Fuentes", windows: "Ventanas", cursor: "Cursor", accent: "Color del tema", transparency: "Transparencia", border: "Marco", borderSize: "Grosor", borderColor: "Color del marco", rounding: "Esquinas", system: "Sistema", terminal: "Terminal", cursorSize: "Tamaño", reset: "Restablecer", confirmReset: "Confirmar" }
  })

  // es_AR gives es. A language without texts falls back to English
  readonly property string systemLanguage: Qt.locale().name.split("_")[0]
  readonly property var systemTexts: textsByLanguage[systemLanguage] || textsByLanguage.en

  function text(key) {
    return systemTexts[key];
  }
}
