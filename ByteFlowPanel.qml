import QtQuick
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "io.github.exxzam.byteflow"
  manageIpc: false
  required property Item anchorItem
  required property var hostWidget
  readonly property var themeFont: Style.font

  KeyboardPanel {
    id: popup
    anchorItem: root.anchorItem
    owner: root.hostWidget
    bar: root.bar
    open: root.opened
    focusTarget: content
    contentWidth: fittedContentWidth(Style.space(360))
    contentHeight: fittedContentHeight(content.implicitHeight)

    Column {
      id: content
      anchors.fill: parent
      spacing: Style.space(14)
      focus: true
      Keys.onEscapePressed: root.close()

      PanelHero {
        title: "ByteFlow"
        meta: root.hostWidget.device || "No active route"
        detail: "LIVE · 1s"
        foreground: root.barForeground
      }

      Text {
        width: parent.width
        text: "↓ " + Model.formatRate(root.hostWidget.speed.down, root.hostWidget.unit)
          + "    ↑ " + Model.formatRate(root.hostWidget.speed.up, root.hostWidget.unit)
        color: root.barForeground
        font.family: root.themeFont.family
        font.pixelSize: root.themeFont.subtitle
      }

      PanelSeparator { width: parent.width; foreground: root.barForeground }
      PanelSectionHeader { text: "VIEW"; foreground: root.barForeground }
      ButtonGroup {
        options: [{ value: "both", label: "Both" }, { value: "download", label: "Download" }, { value: "upload", label: "Upload" }]
        value: root.hostWidget.view
        foreground: root.barForeground
        onChanged: function(value) { root.hostWidget.configure("view", value) }
      }

      PanelSectionHeader { text: "UNITS"; foreground: root.barForeground }
      ButtonGroup {
        options: [{ value: "bytes", label: "KB/s · MB/s" }, { value: "bits", label: "Kbps · Mbps" }]
        value: root.hostWidget.unit
        foreground: root.barForeground
        onChanged: function(value) { root.hostWidget.configure("unit", value) }
      }

      Toggle {
        width: parent.width
        label: "Hide below threshold"
        description: "Show when a displayed direction exceeds the limit."
        checked: root.hostWidget.thresholdEnabled
        foreground: root.barForeground
        onClicked: root.hostWidget.configure("thresholdEnabled", !checked)
      }

      NumberField {
        label: "Minimum speed · KB/s"
        value: root.hostWidget.thresholdKB
        from: 0
        to: 1000000000
        stepSize: 10
        fieldWidth: parent.width
        enabled: root.hostWidget.thresholdEnabled
        opacity: enabled ? 1 : 0.45
        foreground: root.barForeground
        onModified: function(value) { root.hostWidget.configure("thresholdKB", value) }
      }

      Text {
        width: parent.width
        text: "Threshold uses KB/s in either unit mode.\nSettings save automatically. Tab moves between controls."
        color: root.barForeground
        opacity: 0.55
        font.family: root.themeFont.family
        font.pixelSize: root.themeFont.caption
        wrapMode: Text.WordWrap
      }
    }
  }
}
