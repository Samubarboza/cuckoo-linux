import Quickshell
import Quickshell.Io
import QtQuick

// Weather from wttr.in, refreshed every 30 minutes when there is internet.
BarItem {
  id: root

  property string value: ""
  visible: value !== ""

  Text {
    text: root.value
    color: Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
  }

  Process {
    id: weather
    command: ["sh", "-c", "ping -c1 -W2 wttr.in >/dev/null 2>&1 && curl -s 'wttr.in?format=%c%t' | tr -d '+' | sed 's/%//'"]
    stdout: StdioCollector {
      id: output
      onStreamFinished: root.value = output.text.trim()
    }
  }

  Timer {
    interval: 1800000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: weather.running = true
  }
}
