import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

BarWidget {
  id: root
  moduleName: "io.github.exxzam.byteflow"

  readonly property string view: ["both", "download", "upload"].indexOf(setting("view", "both")) >= 0 ? setting("view", "both") : "both"
  readonly property string unit: setting("unit", "bytes") === "bits" ? "bits" : "bytes"
  readonly property bool thresholdEnabled: setting("thresholdEnabled", false) === true
  readonly property real thresholdKB: Math.max(0, Number(setting("thresholdKB", 10)) || 0)
  readonly property string thresholdUnit: ["KB/s", "MB/s", "Kbps", "Mbps"].indexOf(setting("thresholdUnit", "KB/s")) >= 0 ? setting("thresholdUnit", "KB/s") : "KB/s"
  readonly property real thresholdAmount: thresholdKB * 1000 / Model.thresholdScale(thresholdUnit)
  readonly property real refreshSeconds: Model.intervalSeconds(setting("refreshSeconds", 1))
  property var previous: null
  property var speed: ({ down: 0, up: 0 })
  property string device: ""
  readonly property var barApi: bar
  readonly property var themeFont: Style.font
  readonly property bool opened: panel.opened
  readonly property bool popoutSwitchClosing: panel.popoutSwitchClosing
  readonly property bool showRates: !thresholdEnabled || Model.aboveThreshold(speed, view, thresholdKB)
  readonly property real openPanelIndicatorWidth: showRates ? metrics.implicitWidth : button.opticalSize

  function open() { panel.open() }
  function close() { panel.close() }
  function toggle() { panel.toggle() }
  function closeForPopoutSwitch() { panel.closeForPopoutSwitch() }

  function configure(key, value) {
    var entry = Object.assign({}, settings)
    entry[key] = value
    if (barApi && barApi.shell && barApi.shell.updateEntryInline(moduleName, entry)) settings = entry
  }

  function consume(raw) {
    var current = Model.parseSample(raw)
    speed = Model.rates(previous, current, refreshSeconds)
    previous = current
    device = current ? current.device : ""
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  onRefreshSecondsChanged: {
    previous = null
    speed = { down: 0, up: 0 }
  }

  Process {
    id: sampler
    command: ["sh", decodeURIComponent(Qt.resolvedUrl("sample.sh").toString().replace(/^(?:file|qs):\/\//, ""))]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.consume(text)
    }
    onExited: function(exitCode, exitStatus) {
      if (exitCode !== 0 || exitStatus !== 0) root.consume("")
    }
  }

  Timer {
    interval: Math.round(root.refreshSeconds * 1000)
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!sampler.running) sampler.running = true
  }

  ByteFlowPanel {
    id: panel
    bar: root.bar
    hostWidget: root
    anchorItem: button
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.showRates ? "" : "⇅"
    hasVisualContent: true
    dimmed: !root.showRates && !root.opened
    fixedWidth: root.vertical ? root.barSize : (root.showRates ? metrics.implicitWidth + Style.space(16) : slotSize)
    fixedHeight: root.vertical ? (root.showRates ? metrics.implicitHeight + Style.space(12) : slotSize) : root.barSize
    tooltipText: "ByteFlow · " + (root.device || "No active route") + "\nDownload  "
      + Model.formatRate(root.speed.down, root.unit) + "\nUpload    "
      + Model.formatRate(root.speed.up, root.unit) + "\nClick to configure"
    onPressed: function(buttonCode) { if (buttonCode === Qt.LeftButton) root.toggle() }

    Item {
      id: metrics
      visible: root.showRates
      anchors.centerIn: parent
      readonly property real spacing: Style.space(root.vertical ? 4 : 10)
      implicitWidth: root.vertical ? Math.max(down.implicitWidth, up.implicitWidth)
        : (down.visible ? down.implicitWidth : 0) + (up.visible ? up.implicitWidth : 0) + (down.visible && up.visible ? spacing : 0)
      implicitHeight: root.vertical ? (down.visible ? down.implicitHeight : 0) + (up.visible ? up.implicitHeight : 0)
        + (down.visible && up.visible ? spacing : 0) : Math.max(down.implicitHeight, up.implicitHeight)

      Text {
        id: down
        x: root.vertical ? (parent.width - width) / 2 : 0
        visible: root.view !== "upload"
        text: "↓ " + Model.formatRate(root.speed.down, root.unit).replace(" ", root.vertical ? "\n" : " ")
        color: button.foreground
        opacity: root.speed.down > 0 ? 1 : 0.55
        font.family: button.fontFamily
        font.pixelSize: root.vertical ? root.themeFont.caption : root.themeFont.bodySmall
        horizontalAlignment: Text.AlignHCenter
      }
      Text {
        id: up
        x: root.vertical ? (parent.width - width) / 2 : (down.visible ? down.width + metrics.spacing : 0)
        y: root.vertical && down.visible ? down.height + metrics.spacing : 0
        visible: root.view !== "download"
        text: "↑ " + Model.formatRate(root.speed.up, root.unit).replace(" ", root.vertical ? "\n" : " ")
        color: button.foreground
        opacity: root.speed.up > 0 ? 1 : 0.55
        font.family: button.fontFamily
        font.pixelSize: root.vertical ? root.themeFont.caption : root.themeFont.bodySmall
        horizontalAlignment: Text.AlignHCenter
      }
    }
  }
}
