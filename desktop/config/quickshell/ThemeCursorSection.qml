import Quickshell
import Quickshell.Io
import QtQuick

// The cursor section of the theme panel: the cursor theme and its size, both live.
// Moving in the list shows the cursor right away and picking saves it. A cursor that was only
// shown goes back to the saved one when the section closes.
Column {
  id: root

  // The panel is open and this section is the chosen one
  property bool active: false
  // The list comes from cuckoo-theme, so it only has what cuckoo-theme set accepts
  property var cursors: []
  readonly property int savedCursorSize: Theme.cursorSize
  property int cursorSize: savedCursorSize
  readonly property string highlightedCursor: cursorList.hasRow(cursorList.currentIndex)
    ? cursorList.model[cursorList.currentIndex].value : Theme.cursorTheme
  // A cursor or a size is on screen but not saved
  property bool isShowingUnsaved: false
  readonly property Item focusItem: cursorList

  spacing: 24

  // A new theme file moves the slider too, also when it changes from the terminal
  onSavedCursorSizeChanged: cursorSize = savedCursorSize
  // Asked again each time, so a cursor added by the user shows up without a restart
  onActiveChanged: {
    if (active) cursorThemes.running = true;
    else showSavedCursor();
  }

  Process {
    id: cursorThemes
    command: ["cuckoo-theme", "cursors"]
    stdout: StdioCollector { id: cursorOutput; onStreamFinished: root.cursors = root.parseCursors(cursorOutput.text) }
  }

  ThemeList {
    id: cursorList
    width: parent.width
    height: 200
    model: root.cursors.map(cursor => ({ value: cursor.id, label: cursor.name }))
    chosenValue: Theme.cursorTheme
    onHighlighted: cursorId => root.showCursor(cursorId, root.cursorSize)
    onPicked: cursorId => root.saveCursor(cursorId)
  }

  Column {
    width: parent.width
    spacing: 12

    Text {
      text: Language.text("cursorSize")
      color: Theme.soft; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.Medium
    }

    ThemeSlider {
      width: parent.width
      from: 16
      to: 48
      stepSize: 8
      value: root.cursorSize
      valueText: root.cursorSize + " px"
      onMoved: newValue => {
        root.cursorSize = newValue;
        root.showCursor(root.highlightedCursor, newValue);
      }
      onReleased: root.saveCursorSize()
    }
  }

  // Output that is not json gives an empty list, so a broken cuckoo-theme never breaks the panel
  function parseCursors(output) {
    try {
      var cursorList = JSON.parse(output);
      return Array.isArray(cursorList) ? cursorList : [];
    } catch (error) {
      return [];
    }
  }

  // Only Hyprland changes, nothing is saved
  function showCursor(cursorId, size) {
    var isSaved = cursorId === Theme.cursorTheme && size === savedCursorSize;
    if (!active || (isSaved && !isShowingUnsaved)) return;
    Quickshell.execDetached(["hyprctl", "setcursor", cursorId, String(size)]);
    isShowingUnsaved = !isSaved;
  }

  function showSavedCursor() {
    cursorSize = savedCursorSize;
    if (!isShowingUnsaved) return;
    Quickshell.execDetached(["hyprctl", "setcursor", Theme.cursorTheme, String(savedCursorSize)]);
    isShowingUnsaved = false;
  }

  // cuckoo-theme sets the saved cursor in Hyprland again, so nothing unsaved is left on screen
  function saveCursor(cursorId) {
    if (cursorId === Theme.cursorTheme) return;
    Quickshell.execDetached(["cuckoo-theme", "set", "cursor", cursorId]);
    isShowingUnsaved = false;
  }

  function saveCursorSize() {
    if (cursorSize === savedCursorSize) return;
    Quickshell.execDetached(["cuckoo-theme", "set", "cursor_size", String(cursorSize)]);
    isShowingUnsaved = false;
  }
}
