import QtQuick
import qs.Commons
import qs.Ui as Ui
import "Model.js" as Model

Ui.Panel {
  id: root
  moduleName: "io.github.exxzam.byteflow"
  manageIpc: false
  property var anchorItem: null
  property var hostWidget: null
  readonly property var themeFont: Style.font
  readonly property var barApi: bar
  readonly property var hostState: hostWidget || ({})
  readonly property var speed: hostState.speed || ({ down: 0, up: 0 })
  onOpenedChanged: if (!opened) keyCatcher.forceActiveFocus()

  function open() { root.controller.show() }
  function close() { root.controller.hide() }
  function switchPanel(direction) {
    return barApi && typeof barApi.switchPanelFrom === "function"
      ? barApi.switchPanelFrom(root.hostWidget || root, direction) : false
  }
  function configure(key, value) {
    if (hostWidget) hostWidget.configure(key, value)
  }

  Ui.KeyboardPanel {
    id: popup
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: fittedContentWidth(Style.space(360))
    contentHeight: fittedContentHeight(content.implicitHeight)

    Ui.PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: !activeFocus
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: content
        width: parent.width
        spacing: Style.space(14)
        focus: true
        Keys.onEscapePressed: root.close()

        EditCommitHandler {
          editors: [thresholdField.field, intervalField.field]
          margin: popup.padding
        }

        Ui.PanelHero {
          title: "ByteFlow"
          meta: root.hostState.device ? "Interface · " + root.hostState.device : "No active route"
          detail: "LIVE · " + (root.hostState.refreshSeconds || 1) + "s"
          foreground: root.barForeground
        }

        Text {
          width: parent.width
          text: "↓ " + Model.formatRate(root.speed.down, root.hostState.unit || "bytes")
            + "    ↑ " + Model.formatRate(root.speed.up, root.hostState.unit || "bytes")
          color: root.barForeground
          font.family: root.themeFont.family
          font.pixelSize: root.themeFont.subtitle
        }

        Ui.PanelSeparator { width: parent.width; foreground: root.barForeground }
        Ui.PanelSectionHeader { text: "VIEW"; foreground: root.barForeground }
        Ui.ButtonGroup {
          options: [{ value: "both", label: "Both" }, { value: "download", label: "Download" }, { value: "upload", label: "Upload" }]
          value: root.hostState.view || "both"
          foreground: root.barForeground
          onChanged: function(value) { root.configure("view", value) }
        }

        Ui.PanelSectionHeader { text: "UNITS"; foreground: root.barForeground }
        Ui.ButtonGroup {
          options: [{ value: "bytes", label: "KB/s · MB/s" }, { value: "bits", label: "Kbps · Mbps" }]
          value: root.hostState.unit || "bytes"
          foreground: root.barForeground
          onChanged: function(value) { root.configure("unit", value) }
        }

        Ui.Toggle {
          width: parent.width
          label: "Collapse below threshold"
          checked: root.hostState.thresholdEnabled === true
          foreground: root.barForeground
          onClicked: root.configure("thresholdEnabled", !checked)
        }

        Column {
          width: parent.width
          spacing: Style.space(8)
          enabled: root.hostState.thresholdEnabled === true
          opacity: enabled ? 1 : 0.45

          Ui.PanelSectionHeader { text: "MINIMUM SPEED"; foreground: root.barForeground }
          Ui.ButtonGroup {
            options: ["KB/s", "MB/s", "Kbps", "Mbps"]
            value: root.hostState.thresholdUnit || "KB/s"
            foreground: root.barForeground
            onChanged: function(value) { root.configure("thresholdUnit", value) }
          }
          DecimalField {
            id: thresholdField
            width: parent.width
            value: root.hostState.thresholdAmount || 0
            suffix: root.hostState.thresholdUnit || "KB/s"
            foreground: root.barForeground
            onModified: function(value) {
              root.configure("thresholdKB", value * Model.thresholdScale(root.hostState.thresholdUnit || "KB/s") / 1000)
            }
          }
        }

        Ui.PanelSectionHeader { text: "UPDATE INTERVAL"; foreground: root.barForeground }
        DecimalField {
          id: intervalField
          width: parent.width
          value: root.hostState.refreshSeconds || 1
          minimum: 0.25
          maximum: 60
          suffix: "seconds"
          foreground: root.barForeground
          onModified: function(value) { root.configure("refreshSeconds", value) }
        }

        Text {
          width: parent.width
          text: "Settings save automatically."
          color: root.barForeground
          opacity: 0.55
          font.family: root.themeFont.family
          font.pixelSize: root.themeFont.caption
          wrapMode: Text.WordWrap
        }
      }
    }
  }
}
