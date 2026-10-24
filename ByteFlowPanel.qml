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
  onOpenedChanged: if (!opened) content.forceActiveFocus()

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

      EditCommitHandler {
        editors: [thresholdField.field, intervalField.field]
        margin: popup.padding
      }

      PanelHero {
        title: "ByteFlow"
        meta: root.hostWidget.device ? "Interface · " + root.hostWidget.device : "No active route"
        detail: "LIVE · " + root.hostWidget.refreshSeconds + "s"
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
        label: "Collapse below threshold"
        description: "Keep a small settings icon when speeds are below the limit."
        checked: root.hostWidget.thresholdEnabled
        foreground: root.barForeground
        onClicked: root.hostWidget.configure("thresholdEnabled", !checked)
      }

      Column {
        width: parent.width
        spacing: Style.space(8)
        enabled: root.hostWidget.thresholdEnabled
        opacity: enabled ? 1 : 0.45

        PanelSectionHeader { text: "MINIMUM SPEED"; foreground: root.barForeground }
        ButtonGroup {
          options: ["KB/s", "MB/s", "Kbps", "Mbps"]
          value: root.hostWidget.thresholdUnit
          foreground: root.barForeground
          onChanged: function(value) { root.hostWidget.configure("thresholdUnit", value) }
        }
        DecimalField {
          id: thresholdField
          width: parent.width
          value: root.hostWidget.thresholdAmount
          suffix: root.hostWidget.thresholdUnit
          foreground: root.barForeground
          onModified: function(value) {
            root.hostWidget.configure("thresholdKB", value * Model.thresholdScale(root.hostWidget.thresholdUnit) / 1000)
          }
        }
      }

      PanelSectionHeader { text: "UPDATE INTERVAL"; foreground: root.barForeground }
      DecimalField {
        id: intervalField
        width: parent.width
        value: root.hostWidget.refreshSeconds
        minimum: 0.25
        maximum: 60
        suffix: "seconds"
        foreground: root.barForeground
        onModified: function(value) { root.hostWidget.configure("refreshSeconds", value) }
      }

      Text {
        width: parent.width
        text: "Updates every 0.25–60 seconds.\nSettings save automatically. Tab moves between controls."
        color: root.barForeground
        opacity: 0.55
        font.family: root.themeFont.family
        font.pixelSize: root.themeFont.caption
        wrapMode: Text.WordWrap
      }
    }
  }
}
