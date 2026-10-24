# ByteFlow

A compact, theme-aware network speed widget for the Omarchy Quattro bar.

```text
↓ 2.4 MB/s   ↑ 180 KB/s
```

## Features

- Show download and upload together, or either direction individually.
- Display speeds in bytes/s (KB/s, MB/s) or bits/s (Kbps, Mbps).
- Hide below a configurable threshold, with KB/s, MB/s, Kbps and Mbps options.
- Choose an update interval from 0.25 to 60 seconds; defaults to 1 second.
- Configure everything from the bar widget, with settings saved automatically.
- Follows the active network route, including VPN interfaces.
- Adapts to your theme and supports horizontal and vertical bars.

## Requirements

Omarchy with the Quattro plugin API. Uses Quickshell, `iproute2`, a POSIX shell
and `cat`, all included with Omarchy. No additional service or privileges needed.

## Install

```sh
omarchy plugin add https://github.com/EXxZAM/omarchy-byteflow.git --enable
```

Choose the right bar section when prompted.

## Usage

Click ByteFlow to open its settings. Use Tab to navigate, arrow keys to select
options, Enter to apply a choice or numeric value, and Escape to close.

| Setting | Default | Options |
| --- | --- | --- |
| View | Both | Both, Download, Upload |
| Display units | KB/s · MB/s | Bytes/s or bits/s, scaled automatically |
| Hide below threshold | Off | Always visible, or show above the minimum speed |
| Minimum speed | 10 KB/s | Decimal value in KB/s, MB/s, Kbps or Mbps |
| Update interval | 1 second | 0.25–60 seconds |

In **Both** view, either direction exceeding the threshold reveals the whole
widget. In a single-direction view, only that direction counts. Switching the
threshold unit converts the value while preserving the same speed limit.
Threshold units and display units are independent. Units use decimal scaling:
1 MB/s = 1,000 KB/s = 8 Mbps.

The panel subtitle identifies the network interface being measured. ByteFlow
measures the interface selected by the current internet route, rather than
adding together all interfaces. With no active route, speeds show zero.

The widget stays visible while settings are open. To reopen settings when it
is hidden:

```sh
omarchy-shell shell summon io.github.exxzam.byteflow '{}'
```

## Update

```sh
omarchy plugin update io.github.exxzam.byteflow
```

## Disable or remove

```sh
omarchy plugin disable io.github.exxzam.byteflow
omarchy plugin remove io.github.exxzam.byteflow
```

## License

[MIT](LICENSE)
