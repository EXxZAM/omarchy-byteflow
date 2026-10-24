# Local development

Run from the repository on an Omarchy desktop. No push or commit is needed.

```sh
./dev check
./dev preview
```

`check` runs the model tests, UI interaction tests, QML lint and plugin validation.
It requires Node.js and the Qt development tools (`qmllint`, `qmltestrunner`).

`preview` checks the code, backs up the installed plugin, copies the current
working files into it and restarts the existing Omarchy shell. The restart
ensures QML changes appear despite the current shell's plugin cache behavior.
Your saved widget settings are preserved. Edit the source and run it again to
try another change.

To finish testing and restore the installation from before the first preview:

```sh
./dev restore
```

The backup lives under `$XDG_STATE_HOME/byteflow/preview`, or
`~/.local/state/byteflow/preview` by default. Restore before running
`omarchy plugin update`, since preview changes make the installed checkout dirty.

To test numeric settings: edit the threshold or interval, then click a section
heading, a blank area, another editor, or a button. Reopen the panel and verify
the value persisted. Clicking inside the same editor should keep it focused.

## Plugin contract

ByteFlow follows the [Omarchy development guide](https://plugins.omarchy.org/develop.html):

- `manifest.json` declares one `bar-widget` with entry point `BarWidget.qml`.
- `BarWidget.qml` loads `Panel.qml` through a `Loader` and injects `bar`,
  `anchorItem` and `hostWidget` after loading and when the bar changes.
- The entry point forwards `opened`, `popoutSwitchClosing`, `open`, `close`,
  `toggle` and `closeForPopoutSwitch` to the loaded panel.
- The nested panel uses the same plugin ID, `manageIpc: false`, `KeyboardPanel`
  and `PanelKeyCatcher`. Form controls retain their normal key handling.
- The published manifest uses ByteFlow's permanent namespaced ID and contains
  no temporary `omarchy.clonedFrom` field.
- Runtime files contain no symlinks and run inside the existing shell process.

After `./dev preview`, complete these checks from the desktop session:

```sh
omarchy plugin list --json | jq '.[] | select(.id == "io.github.exxzam.byteflow")'
omarchy-shell shell summon io.github.exxzam.byteflow '{}'
omarchy-shell shell hide io.github.exxzam.byteflow
```

Verify click-to-toggle, Escape, repeated open/close, Tab between panels, form
keyboard navigation, settings persistence, and both bar orientations. Before
release, also check disable/re-enable, shell restart and removal/reinstallation.
These desktop checks supplement the automated tests; neither lint nor manifest
validation confirms that the running shell has loaded the current code.
