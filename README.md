# ByteFlow

A compact, theme-aware network speed widget for the Omarchy Quattro bar.

```text
↓ 2.4 MB/s   ↑ 180 KB/s
```

- Show both directions, download only, or upload only.
- Choose automatic KB/s–MB/s or Kbps–Mbps units (scales further when needed).
- Always show, or appear only when a displayed direction exceeds a threshold.
- Click to configure; settings persist through shell restarts in Omarchy's `shell.json`.
- Follows the active route, including VPN routes, with a one-second refresh.
- Uses the shell's fonts, colors, spacing and controls; supports vertical bars.

## Requirements

Omarchy with the Quattro plugin API (`schemaVersion: 1`), Quickshell, `iproute2`,
a POSIX shell and `cat`. These are included with Omarchy. Linux `/proc` must be
available. No extra service, installer, network request or elevated privilege is
needed. Plugins run with your user permissions inside the existing shell.

## Local installation

From this repository, copy the runtime files to a new plugin directory:

```sh
plugin_dir="$HOME/.config/omarchy/plugins/byteflow"
mkdir "$plugin_dir"
cp manifest.json ByteFlow.qml ByteFlowPanel.qml Model.js sample.sh LICENSE "$plugin_dir/"
omarchy plugin validate "$plugin_dir"
omarchy-shell shell rescanPlugins
omarchy plugin enable io.github.exxzam.byteflow --section right
```

The directory must not already exist. Use a real directory: Omarchy rejects
symlinks inside plugins. To update your local copy, repeat the `cp` command and
rescan; user plugin changes also hot-reload.

Once published, install through `omarchy plugin add <repository-url> --enable`.

## Settings

Click the widget to open settings. Tab navigates controls, arrow keys select
options, Enter applies a choice, and Escape closes the panel.

| Setting | Default | Behavior |
| --- | --- | --- |
| View | Both | Download and upload, download only, or upload only |
| Units | KB/s · MB/s | Decimal bytes/s or bits/s; 1 KB = 1,000 bytes |
| Hide below threshold | Off | Hides the entire widget when no displayed direction exceeds the limit |
| Minimum speed | 10 KB/s | Always measured in KB/s, independently of display units |

In **Both** view, either direction can reveal the entire widget. In a single
direction view, only that direction counts. Equality stays hidden. The widget
stays visible while its settings panel is open, so changes remain accessible.

If the widget is hidden, reopen its settings from a terminal:

```sh
omarchy-shell shell summon io.github.exxzam.byteflow '{}'
```

Settings live on the widget's layout entry in `~/.config/omarchy/shell.json`:

```json
{
  "id": "io.github.exxzam.byteflow",
  "view": "both",
  "unit": "bytes",
  "thresholdEnabled": false,
  "thresholdKB": 10
}
```

## Measurement

ByteFlow uses a local route lookup for `1.1.1.1`, falling back to
`2606:4700:4700::1111` on IPv6-only networks. **No packets are sent.** It reads
that interface's byte counters from `/proc/net/dev` and computes rates using
elapsed `/proc/uptime`, avoiding timer drift and wall-clock changes.

Only the selected route's interface is counted. Split-tunnel traffic on other
interfaces and LAN-only traffic without an internet route are not aggregated.
The first sample after an interface change, disconnect, counter reset, or a gap
over five seconds establishes a new baseline. With no route, speeds show zero
and the panel reports “No active route.” Each bar instance samples independently.

## Development

No build step or package installation is needed. Tests require Node.js:

```sh
node --test tests/model.test.cjs
omarchy plugin validate .

# Resolve qs.Ui and qs.Commons against the installed shell for Qt's linter.
imports=$(mktemp -d)
ln -s "$OMARCHY_PATH/shell" "$imports/qs"
/usr/lib/qt6/bin/qmllint --max-warnings 0 -I "$imports" ByteFlow.qml ByteFlowPanel.qml
rm "$imports/qs"
rmdir "$imports"
```

Before a release, check the widget on a live bar: all three views, both units,
threshold crossings, saved settings after restart, VPN/reconnect, panel click,
keyboard navigation, Escape, shell summon/hide, disable/re-enable and removal.

## Disable or remove

```sh
omarchy plugin disable io.github.exxzam.byteflow
omarchy plugin remove io.github.exxzam.byteflow
```

MIT licensed. Built against the [Omarchy plugin development guide](https://plugins.omarchy.org/develop.html).
