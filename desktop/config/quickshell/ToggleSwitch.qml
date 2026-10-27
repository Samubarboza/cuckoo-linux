import QtQuick

// macOS style switch
Rectangle {
  property bool active: false
  signal toggled

  width: 30
  height: 18
  radius: 999
  color: active ? Theme.accent : Theme.glass

  Rectangle {
    width: 14
    height: 14
    radius: 999
    color: parent.active ? Theme.background : Theme.text
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
