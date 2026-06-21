[![English](https://img.shields.io/badge/lang-en-blue.svg)](README.md)
[![Русский](https://img.shields.io/badge/lang-ru-red.svg)](README.ru.md)

# qCode

**qCode** is an extension for [Quarto](https://quarto.org/) that adds an interactive Python IDE to your page with the ability to run code directly in the browser, as well as search documentation for Python functions and methods.

## Installation

Add the extension to your Quarto project:

```bash
quarto add skyfroger/qcode
```

After installation, connect the `qcode` filter in the YAML header of the document or in the project's `_quarto.yml`.

## Localization

To localize the extension's UI elements, specify the `lang` attribute in YAML. English is used by default. Russian is also available:

```yaml
lang: ru
```

## Interactive Python Editor

To make a Python code block interactive, use `sk-python` as the code block type:

````markdown
```sk-python
for letter in "Hello, world":
    print(letter)
```
````

Code inside such a block will be placed into an interactive development environment with support for:

- **Code execution** - running Python scripts in the browser via [Pyodide](https://pyodide.org/).
- **Data input** - interactive `input()` directly in the output window.
- **Syntax highlighting** - editor based on [Ace Editor](https://ace.c9.io/).
- **Function detection** - automatic AST analysis to detect function calls from the documentation.
- **Execution stop** - interruption of infinite loops and long computations.

### Editor Toolbar

Each editor contains buttons:

| Button | Purpose |
|--------|---------|
| <img style="display: inline-block; border-radius: 0.3em;background: #60a561;" src="images/play.svg" /> | Run code |
| ![](images/stop.svg) | Stop execution |
|![](images/clear.svg) | Clear execution results |
| ![](images/restore.svg) | Restore original code |
| ![](images/copy.svg) | Copy code to clipboard |
| ![](images/save.svg) | Save code to file `script.py` |

### Status Indicator

The current status is displayed in the upper right corner of the editor:

| Status | Description |
|--------|-------------|
| ![](images/status-ready.svg) Ready | Editor is loaded and ready |
| ![](images/status-running.svg) Running | Code is being executed |
| ![](images/status-input.svg) Waiting for input | Script is waiting for user input |
| ![](images/status-error.svg) Error | An error occurred during execution |
| ![](images/status-finished.svg) Finished | Script executed without errors |
| ![](images/status-stopped.svg) Stopped | Execution was interrupted by user |

### Used Functions Bar

Below the editor, a list of functions and methods detected in the code is displayed. Clicking any function opens a modal window with its documentation.

## Documentation Search

To add a documentation search field for Python, use a block with the `.sk-api-search` class:

```markdown
:::{.sk-api-search}
The documentation contains standard Python language functions and built-in type methods.
:::
```

Search works in real-time mode (with 300 ms debounce). Results are displayed in a dropdown list. Clicking a result opens a modal window with detailed function documentation.

### Documentation Modal Window

The modal window contains:

- **Function signature** - name, parameters, and return type.
- **Black box diagram** - visualization of input parameters and output value.
- **Description** - textual description of the function.
- **Parameters** - list of parameters with types, default values, and descriptions.
- **Return value** - type and description of the result.
- **Examples** - usage examples with input code and expected output.
- **Link to official documentation**.

### Documentation Display Settings

The modal window has toggles:

| Toggle | Description |
|--------|-------------|
|<img src="images/toggle-optional.svg"/>|Show/hide optional parameters|
| <img src="images/toggle-types.svg"/> |Show/hide type hints|
| <img src="images/toggle-diagram.svg"/> | Show/hide black box diagram |

Settings are saved to `localStorage` and apply to all modal windows.

## Markup Tips

1. **Filter in YAML.** Don't forget to add `filters: - qcode` to the document header.
2. **Multiple editors.** A page can contain multiple `sk-python` blocks - each gets its own editor with an independent execution environment.
3. **Interrupting execution.** To stop an infinite loop, use the "Stop" button (if the browser supports `SharedArrayBuffer`).
4. **Security.** Code runs in an isolated Pyodide environment inside the browser, without access to the user's file system.
