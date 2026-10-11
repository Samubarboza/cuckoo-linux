pragma Singleton

import Quickshell
import QtQuick

// The desktop texts, in the system language.
Singleton {
  readonly property var textsByLanguage: ({
    en: { suspend: "Suspend", lock: "Lock", logout: "Log out", reboot: "Restart", shutdown: "Shut down" },
    es: { suspend: "Suspender", lock: "Bloquear", logout: "Cerrar sesión", reboot: "Reiniciar", shutdown: "Apagar" }
  })

  // es_AR gives es. A language without texts falls back to English
  readonly property string systemLanguage: Qt.locale().name.split("_")[0]
  readonly property var systemTexts: textsByLanguage[systemLanguage] || textsByLanguage.en

  function text(key) {
    return systemTexts[key];
  }
}
