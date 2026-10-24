import QtQuick

// Observe presses without consuming clicks intended for the controls.
TapHandler {
  property var editors: []
  onPressedChanged: {
    if (!pressed) return
    for (let i = 0; i < editors.length; i++) {
      const editor = editors[i]
      if (editor.contains(editor.mapFromItem(parent, point.position.x, point.position.y))) return
    }
    parent.forceActiveFocus()
  }
}
