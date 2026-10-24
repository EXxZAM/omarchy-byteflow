// Pure functions shared by the widget and its regression tests.
function parseSample(raw) {
  try {
    var lines = raw.trim().split("\n")
    var route = JSON.parse(lines.shift())[0]
    var uptime = Number(lines.pop().trim().split(/\s+/)[0])
    if (!route || !route.dev || route.dev === "lo" || !isFinite(uptime)) return null
    for (var i = 0; i < lines.length; i++) {
      var colon = lines[i].indexOf(":")
      if (colon < 0 || lines[i].slice(0, colon).trim() !== route.dev) continue
      var fields = lines[i].slice(colon + 1).trim().split(/\s+/)
      var rx = Number(fields[0]), tx = Number(fields[8])
      if (fields.length < 16 || !isFinite(rx) || !isFinite(tx) || rx < 0 || tx < 0) return null
      return { device: route.dev, time: uptime, rx: rx, tx: tx }
    }
  } catch (error) { /* Missing routes and partial reads are a disconnected sample. */ }
  return null
}

function rates(previous, current, refreshSeconds) {
  var idle = { down: 0, up: 0 }
  if (!previous || !current || previous.device !== current.device) return idle
  var seconds = current.time - previous.time
  // Rebaseline after reconnect, counter reset, suspend, or a stalled reader.
  if (seconds <= 0 || seconds > Math.max(5, intervalSeconds(refreshSeconds) * 3)
      || current.rx < previous.rx || current.tx < previous.tx) return idle
  return { down: (current.rx - previous.rx) / seconds, up: (current.tx - previous.tx) / seconds }
}

function intervalSeconds(value) {
  var seconds = Number(value)
  return isFinite(seconds) ? Math.max(0.25, Math.min(60, seconds)) : 1
}

function thresholdScale(unit) {
  return ({ "KB/s": 1000, "MB/s": 1000000, "Kbps": 125, "Mbps": 125000 })[unit] || 1000
}

function formatRate(bytes, unit) {
  var value = Math.max(0, Number(bytes) || 0) * (unit === "bits" ? 8 : 1)
  var labels = unit === "bits" ? ["Kbps", "Mbps", "Gbps", "Tbps"] : ["KB/s", "MB/s", "GB/s", "TB/s"]
  value /= 1000
  var index = 0
  while (value >= 999.5 && index < labels.length - 1) { value /= 1000; index++ }
  return (value < 10 && value >= 0.1 ? value.toFixed(1) : value.toFixed(0)) + " " + labels[index]
}

function aboveThreshold(speed, view, thresholdKB) {
  var limit = Math.max(0, Number(thresholdKB) || 0) * 1000
  return (view !== "upload" && speed.down > limit) || (view !== "download" && speed.up > limit)
}
