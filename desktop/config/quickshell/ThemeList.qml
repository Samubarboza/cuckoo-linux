import QtQuick

// A list for the theme panel, with the same rows as the section list. The model is a list of
// { value, label }. The mouse and the arrows move the highlight, a click or Enter picks.
// It only tells what happened: the parent previews the highlighted value and saves the picked one.
// Left, Right and Esc are not used here, so they go up to the section and the panel.
ListView {
  id: root

  readonly property int rowHeight: 36
  property string chosenValue
  // No mouse seen yet, since the list showed up
  property point lastMousePoint: Qt.point(-1, -1)
  property bool isMakingRows: true
  signal highlighted(string value)
  signal picked(string value)

  clip: true
  spacing: 2
  boundsBehavior: Flickable.StopAtBounds

  delegate: Rectangle {
    required property var modelData
    required property int index
    readonly property bool chosen: modelData.value === root.chosenValue
    width: ListView.view.width
    height: root.rowHeight
    radius: Theme.themePanelSectionRadius
    color: ListView.isCurrentItem ? Theme.selected : "transparent"
    border.width: 1
    border.color: chosen ? Theme.accentLine : "transparent"

    Text {
      anchors.left: parent.left; anchors.right: parent.right
      anchors.leftMargin: 12; anchors.rightMargin: 12
      anchors.verticalCenter: parent.verticalCenter
      elide: Text.ElideRight
      text: modelData.label
      color: chosen ? Theme.accent : Theme.soft
      font.family: Theme.fontFamily; font.pixelSize: 13
      font.weight: chosen ? Font.DemiBold : Font.Medium
    }

    // A click also gives the list the keyboard, so the arrows go on from there
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onPositionChanged: mouse => root.followMouse(mapToItem(root, mouse.x, mouse.y), index)
      onClicked: {
        root.forceActiveFocus();
        root.picked(modelData.value);
      }
    }
  }

  Keys.onReturnPressed: pickCurrent()
  Keys.onEnterPressed: pickCurrent()

  // The list moves the highlight to the first row by itself while it makes the rows. That is not told,
  // and the chosen row is shown once it is done
  onCurrentIndexChanged: if (!isMakingRows && hasRow(currentIndex)) highlighted(model[currentIndex].value)
  onCountChanged: waitForRows()
  onModelChanged: waitForRows()
  onChosenValueChanged: Qt.callLater(showChosen)
  // A list that shows up again starts on the chosen row. The same list given again does not
  // change the model, so this is the only way it knows
  onVisibleChanged: {
    lastMousePoint = Qt.point(-1, -1);
    if (visible) showChosen();
  }

  function hasRow(rowIndex) {
    return rowIndex >= 0 && rowIndex < count;
  }

  // A list that shows up under a still mouse also gets a mouse event, so the highlight
  // only follows the mouse once it really moves
  function followMouse(mousePoint, rowIndex) {
    var hasMoved = lastMousePoint.x >= 0 && (mousePoint.x !== lastMousePoint.x || mousePoint.y !== lastMousePoint.y);
    lastMousePoint = mousePoint;
    if (hasMoved) currentIndex = rowIndex;
  }

  function waitForRows() {
    isMakingRows = true;
    Qt.callLater(showChosen);
  }

  // Start on the chosen row, or on the first one when it is not in the list
  function showChosen() {
    if (count === 0) return;
    isMakingRows = false;
    currentIndex = Math.max(0, model.findIndex(entry => entry.value === chosenValue));
    positionViewAtIndex(currentIndex, ListView.Center);
  }

  function pickCurrent() {
    if (hasRow(currentIndex)) picked(model[currentIndex].value);
  }
}
