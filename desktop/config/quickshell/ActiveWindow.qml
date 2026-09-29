import Quickshell
import Quickshell.Hyprland
import QtQuick

// Active app on this screen. Shows the app class, "Desktop" when nothing is focused.
Item {
  id: root

  required property var screen

  readonly property var monitor: Hyprland.monitorFor(screen)
  readonly property var toplevel: Hyprland.activeToplevel
  readonly property bool onThisMonitor: toplevel && toplevel.monitor === monitor
  readonly property string appClass: onThisMonitor && toplevel.wayland ? toplevel.wayland.appId : ""

  implicitWidth: Math.max(98, label.implicitWidth + 32)
  implicitHeight: Theme.barHeight

  Text {
    id: label
    anchors.centerIn: parent
    text: root.rewrite(root.appClass)
    color: root.appClass === "" ? Theme.soft : Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Font.Bold
    elide: Text.ElideRight
  }

  // Same rules as the old Waybar window module, kept in order
  function rewrite(name) {
    if (name === "")
      return "Desktop";
    if (name === "dev.zed.Zed")
      return "Zed";
    if (name === "com.mitchellh.ghostty")
      return "Ghostty";
    var parts = name.split(".");
    if (parts.length >= 3)
      name = parts[parts.length - 1];
    else if (name.indexOf("org.") === 0)
      name = name.slice(4);
    return name.length > 12 ? name.slice(0, 12) : name;
  }
}
