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
