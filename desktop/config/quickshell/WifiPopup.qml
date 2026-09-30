import Quickshell
import Quickshell.Io
import QtQuick

// Wifi card: radio switch, autoconnect switch and the network list with password entry.
// The typed password lives here, not in the list, and the list refresh is paused
// while typing, so the field is never recreated and the text is never lost.
BarPopup {
  id: root

  property bool radioEnabled: true
  property string autoconnectState: "none"
  property var networks: []
  property string selectedSsid: ""
  property string connectingSsid: ""
  property string passwordText: ""
  property bool showPassword: false

  readonly property var signalIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

  implicitWidth: 300
  implicitHeight: column.implicitHeight + 22

  Column {
    id: column
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.leftMargin: 10
    anchors.rightMargin: 10
    anchors.topMargin: 12
    spacing: 10

    // Header: title and radio switch
    Row {
      anchors.left: parent.left
      anchors.right: parent.right

      Text {
        width: parent.width - radioSwitch.width
        text: "Wi-Fi"
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.weight: Font.DemiBold
      }
      ToggleSwitch {
        id: radioSwitch
        active: root.radioEnabled
        onToggled: root.runAction(["sh", "-c", root.radioEnabled ? "nmcli radio wifi off" : "nmcli radio wifi on"])
      }
    }

    // Autoconnect for the active network
    Row {
      anchors.left: parent.left
      anchors.right: parent.right
      visible: root.radioEnabled && root.autoconnectState !== "none"

      Text {
        width: parent.width - autoSwitch.width
        text: "Conectar automáticamente"
        color: Theme.soft
        font.family: Theme.fontFamily
        font.pixelSize: 12
      }
      ToggleSwitch {
        id: autoSwitch
        active: root.autoconnectState === "yes"
        onToggled: root.toggleAutoconnect()
      }
    }

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      height: 1
      color: Qt.rgba(1, 1, 1, 0.12)
      visible: root.radioEnabled
    }

    Text {
      text: "Redes"
      color: Theme.subtitle
      font.family: Theme.fontFamily
      font.pixelSize: 11
      font.weight: Font.DemiBold
      visible: root.radioEnabled
    }

    Flickable {
      anchors.left: parent.left
      anchors.right: parent.right
      height: 250
      visible: root.radioEnabled
      clip: true
      contentHeight: list.implicitHeight
      boundsBehavior: Flickable.StopAtBounds

      Column {
        id: list
        width: parent.width
        spacing: 2

        Repeater {
          model: root.networks
          NetworkRow {}
        }
      }
    }
  }

  // A network row, with the password box that opens under it when selected
  component NetworkRow: Column {
    required property var modelData

    anchors.left: parent ? parent.left : undefined
    anchors.right: parent ? parent.right : undefined

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      height: 34
      radius: Theme.cornerRadius
      color: hover.hovered ? Qt.rgba(1, 1, 1, 0.14) : (modelData.active ? Qt.rgba(1, 1, 1, 0.10) : "transparent")

      Row {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 10

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: modelData.icon
          color: Theme.text
          font.family: Theme.iconFont
          font.pixelSize: 15
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 15 - state.implicitWidth - lock.implicitWidth - 30
          text: modelData.ssid
          color: Theme.text
          font.family: Theme.fontFamily
          font.pixelSize: 13
          elide: Text.ElideRight
        }
        Text {
          id: state
          anchors.verticalCenter: parent.verticalCenter
          text: root.connectingSsid === modelData.ssid ? "Conectando..." : (modelData.active ? "󰄬" : "")
          color: Qt.rgba(1, 1, 1, 0.70)
          font.family: Theme.iconFont
          font.pixelSize: 12
        }
        Text {
          id: lock
          anchors.verticalCenter: parent.verticalCenter
          text: modelData.secure ? "󰌾" : ""
          color: Theme.subtitle
          font.family: Theme.iconFont
          font.pixelSize: 12
        }
      }

      HoverHandler {
        id: hover
      }
      TapHandler {
        onTapped: root.selectNetwork(modelData)
      }
    }

    // Password box for this network
    Loader {
      anchors.left: parent.left
      anchors.right: parent.right
      active: root.selectedSsid === modelData.ssid
      visible: active
      sourceComponent: passwordBox
    }

    Component {
      id: passwordBox
      Column {
        spacing: 6
        padding: 6

        Text {
          text: "Contraseña"
          color: Theme.subtitle
          font.family: Theme.fontFamily
          font.pixelSize: 11
          font.weight: Font.DemiBold
        }
        Rectangle {
          anchors.left: parent.left
          anchors.right: parent.right
          height: 32
          radius: Theme.cornerRadius
          color: Qt.rgba(1, 1, 1, 0.10)
          border.width: 1
          border.color: Qt.rgba(1, 1, 1, 0.14)

          Row {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 6

            TextInput {
              id: field
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - eye.width - 6
              color: Theme.text
              font.family: Theme.fontFamily
              font.pixelSize: 13
              echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
              focus: true
              // Restore what was typed even if the row is rebuilt
              Component.onCompleted: {
                text = root.passwordText;
                forceActiveFocus();
              }
              onTextChanged: root.passwordText = text
              onAccepted: root.connectNetwork(modelData, root.passwordText)
            }
            Text {
              id: eye
              anchors.verticalCenter: parent.verticalCenter
              text: root.showPassword ? "󰈉" : "󰈈"
              color: Qt.rgba(1, 1, 1, 0.70)
              font.family: Theme.iconFont
              font.pixelSize: 14

              TapHandler {
                onTapped: root.showPassword = !root.showPassword
              }
            }
          }
        }
        Rectangle {
          anchors.left: parent.left
          anchors.right: parent.right
          height: 30
          radius: Theme.cornerRadius
          color: connectHover.hovered ? Qt.rgba(1, 1, 1, 0.28) : Qt.rgba(1, 1, 1, 0.18)

          Text {
            anchors.centerIn: parent
            text: "Conectar"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
          }
          HoverHandler {
            id: connectHover
          }
          TapHandler {
            onTapped: root.connectNetwork(modelData, root.passwordText)
          }
        }
      }
    }
  }

  // macOS style switch
  component ToggleSwitch: Rectangle {
    property bool active: false
    signal toggled

    width: 30
    height: 18
    radius: 999
    color: active ? Qt.rgba(1, 1, 1, 0.85) : Qt.rgba(1, 1, 1, 0.22)

    Rectangle {
      width: 14
      height: 14
      radius: 999
      color: parent.active ? "#1c1c1e" : "#ffffff"
      anchors.verticalCenter: parent.verticalCenter
      x: parent.active ? parent.width - width - 2 : 2

      Behavior on x {
        NumberAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
    }

    TapHandler {
      onTapped: parent.toggled()
    }
  }

  // Status: radio, active connection and its autoconnect
  Process {
    id: statusProc
    command: ["sh", "-c", "echo radio=$(nmcli radio wifi); a=$(nmcli -t -f NAME,TYPE connection show --active | grep ':802-11-wireless$' | head -n1 | sed 's/:802-11-wireless$//'); echo active=$a; if [ -n \"$a\" ]; then echo autoconnect=$(nmcli -g connection.autoconnect connection show \"$a\"); else echo autoconnect=none; fi"]
    stdout: StdioCollector {
      id: statusOut
      onStreamFinished: root.parseStatus(statusOut.text)
    }
  }

  // Saved connections and the scan list
  Process {
    id: networksProc
    command: ["sh", "-c", "echo SAVED; nmcli -t -f NAME,TYPE connection show | grep ':802-11-wireless$' | sed 's/:802-11-wireless$//'; echo LIST; nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan no 2>/dev/null"]
    stdout: StdioCollector {
      id: networksOut
      onStreamFinished: root.parseNetworks(networksOut.text)
    }
  }

  // One process for the actions, its command set right before running
  Process {
    id: action
    onRunningChanged: if (!running) {
      root.connectingSsid = "";
      statusProc.running = true;
      networksProc.running = true;
    }
  }

  Timer {
    interval: 3000
    running: root.shown
    repeat: true
    triggeredOnStart: true
    onTriggered: statusProc.running = true
  }
  Timer {
    // Paused while typing a password, so the list is never rebuilt then
    interval: 6000
    running: root.shown && root.selectedSsid === ""
    repeat: true
    triggeredOnStart: true
    onTriggered: networksProc.running = true
  }

  onShownChanged: if (!shown) {
    selectedSsid = "";
    passwordText = "";
    showPassword = false;
  }

  function runAction(command) {
    action.command = command;
    action.running = true;
  }

  function toggleAutoconnect() {
    var next = autoconnectState === "yes" ? "no" : "yes";
    runAction(["sh", "-c", "a=$(nmcli -t -f NAME,TYPE connection show --active | grep ':802-11-wireless$' | head -n1 | sed 's/:802-11-wireless$//'); [ -n \"$a\" ] && nmcli connection modify \"$a\" connection.autoconnect " + next]);
  }

  // Click on a network: active does nothing, saved or open connects, secured asks the password
  function selectNetwork(network) {
    if (network.active)
      return;
    if (network.saved || !network.secure) {
      connectNetwork(network, "");
      return;
    }
    selectedSsid = network.ssid;
    passwordText = "";
    showPassword = false;
  }

  function connectNetwork(network, password) {
    connectingSsid = network.ssid;
    selectedSsid = "";
    if (password !== "")
      action.command = ["nmcli", "dev", "wifi", "connect", network.ssid, "password", password];
    else if (network.saved)
      action.command = ["nmcli", "connection", "up", "id", network.ssid];
    else
      action.command = ["nmcli", "dev", "wifi", "connect", network.ssid];
    action.running = true;
    passwordText = "";
  }

  function parseStatus(text) {
    var lines = text.split("\n");
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (line.indexOf("radio=") === 0)
        radioEnabled = line.slice(6) === "enabled";
      else if (line.indexOf("autoconnect=") === 0)
        autoconnectState = line.slice(12);
    }
  }

  function parseNetworks(text) {
    var lines = text.split("\n");
    var section = "";
    var saved = {};
    var raw = [];
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (line === "SAVED" || line === "LIST") {
        section = line;
        continue;
      }
      if (line === "")
        continue;
      if (section === "SAVED")
        saved[line] = true;
      else if (section === "LIST")
        raw.push(line);
    }

    var byName = {};
    for (var j = 0; j < raw.length; j++) {
      var f = splitEscaped(raw[j]);
      var ssid = f[3] || "";
      if (ssid === "")
        continue;
      var signal = parseInt(f[1]) || 0;
      var network = {
        "ssid": ssid,
        "signal": signal,
        "icon": signalIcons[Math.min(Math.floor(signal / 20), 4)],
        "secure": f[2] !== "" && f[2] !== "--",
        "saved": saved[ssid] === true,
        "active": f[0] === "*"
      };
      var old = byName[ssid];
      if (!old || network.active || (signal > old.signal && !old.active))
        byName[ssid] = network;
    }

    var ordered = [];
    for (var key in byName)
      ordered.push(byName[key]);
    ordered.sort(function (a, b) {
      if (a.active !== b.active)
        return a.active ? -1 : 1;
      return b.signal - a.signal;
    });
    networks = ordered.slice(0, 12);
  }

  // Split nmcli fields on ":", keeping escaped "\:" inside the SSID
  function splitEscaped(line) {
    var parts = [];
    var current = "";
    for (var i = 0; i < line.length; i++) {
      var c = line[i];
      if (c === "\\" && line[i + 1] === ":") {
        current += ":";
        i++;
      } else if (c === ":" && parts.length < 3) {
        parts.push(current);
        current = "";
      } else {
        current += c;
      }
    }
    parts.push(current);
    return parts;
  }
}
