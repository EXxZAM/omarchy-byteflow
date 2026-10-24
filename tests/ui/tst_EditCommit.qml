import QtQuick
import QtQuick.Controls
import QtTest
import "../.." as ByteFlow

TestCase {
  name: "EditCommit"
  width: 400
  height: 300
  visible: true
  when: windowShown

  Item {
    id: panel
    anchors.fill: parent
    focus: true
    property string saved: ""
    property string savedAtClick: ""

    ByteFlow.EditCommitHandler { editors: [first, second] }

    TextField {
      id: first
      x: 20; y: 20; width: 150; height: 40
      text: "10"
      validator: DoubleValidator { bottom: 0; top: 100; locale: "C" }
      onEditingFinished: panel.saved = text
    }
    TextField { id: second; x: 20; y: 80; width: 150; height: 40 }
    Button {
      id: button
      x: 200; y: 20; width: 150; height: 40
      text: "Change units"
      onClicked: panel.savedAtClick = panel.saved
    }
  }

  function init() {
    panel.forceActiveFocus()
    first.text = "10"
    panel.saved = ""
    panel.savedAtClick = ""
    mouseClick(first, 30, 20)
    verify(first.activeFocus)
    first.selectAll()
    keyClick(Qt.Key_2)
    keyClick(Qt.Key_5)
  }

  function test_background_commits() {
    mouseClick(panel, 300, 200)
    compare(panel.saved, "25")
    verify(!first.activeFocus)
  }
  function test_editor_click_keeps_focus() {
    mouseClick(first, 40, 20)
    verify(first.activeFocus)
    compare(panel.saved, "")
  }
  function test_other_editor_commits() {
    mouseClick(second, 30, 20)
    compare(panel.saved, "25")
    verify(second.activeFocus)
  }
  function test_button_sees_committed_value() {
    mouseClick(button, 30, 20)
    compare(panel.saved, "25")
    compare(panel.savedAtClick, "25")
  }
  function test_invalid_input_is_not_saved() {
    first.selectAll()
    keyClick(Qt.Key_Backspace)
    mouseClick(panel, 300, 200)
    compare(panel.saved, "")
  }
}
