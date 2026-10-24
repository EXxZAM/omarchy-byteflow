import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Row {
  id: root
  property real value: 0
  property real minimum: 0
  property real maximum: 1000000000000
  property string suffix: ""
  property color foreground: Commons.Color.foreground
  property alias field: editor
  readonly property var themeFont: Style.font
  signal modified(real value)
  spacing: Style.space(10)

  TextField {
    id: editor
    width: parent.width - unitLabel.implicitWidth - parent.spacing
    text: Number(root.value.toFixed(6)).toString()
    foreground: root.foreground
    selectByMouse: true
    validator: DoubleValidator {
      bottom: root.minimum
      top: root.maximum
      decimals: 6
      locale: "C"
      notation: DoubleValidator.StandardNotation
    }
    onEditingFinished: {
      if (acceptableInput) root.modified(Number(text))
      text = Qt.binding(function() { return Number(root.value.toFixed(6)).toString() })
    }
    onActiveFocusChanged: {
      if (!activeFocus && !acceptableInput)
        text = Qt.binding(function() { return Number(root.value.toFixed(6)).toString() })
    }
  }

  Text {
    id: unitLabel
    anchors.verticalCenter: parent.verticalCenter
    text: root.suffix
    color: root.foreground
    opacity: 0.65
    font.family: root.themeFont.family
    font.pixelSize: root.themeFont.body
  }
}
