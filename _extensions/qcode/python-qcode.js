// Глобальный инстанс Pyodide (один на страницу)
let pyodideInstance = null;
let pyodideReadyPromise = null;
let activeEditor = null; // ссылка на текущий выполняющий редактор

async function initPyodide() {
    if (pyodideReadyPromise) return pyodideReadyPromise;

    pyodideReadyPromise = loadPyodide();

    pyodideInstance = await pyodideReadyPromise;

    pyodideInstance.runPython(`
import ast
from pyodide.code import eval_code_async
import builtins

def __qcode_get_calls(source):
    try:
        tree = ast.parse(source)
    except Exception as e:
        return []
    names = []
    seen = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Call):
            if isinstance(node.func, ast.Name):
                name = node.func.id
            elif isinstance(node.func, ast.Attribute):
                name = node.func.attr
            else:
                continue
            if name not in seen:
                seen.add(name)
                names.append(name)
    return names

async def __qcode_run(source, globals_dict):
    if '__builtins__' not in globals_dict:
        globals_dict['__builtins__'] = builtins
    return await eval_code_async(source, globals=globals_dict, locals=globals_dict)
`);

    try {
        if (typeof SharedArrayBuffer !== "undefined") {
            const interruptBuffer = new Int32Array(new SharedArrayBuffer(4));
            pyodideInstance.setInterruptBuffer(interruptBuffer);
            window.__pyodideInterruptBuffer = interruptBuffer;
        }
    } catch (e) {
        console.warn(
            "SharedArrayBuffer недоступен. Прерывание бесконечных циклов невозможно.",
        );
    }

    return pyodideInstance;
}

// Маршрутизируем input() к активному редактору
window.__skGetInput = (prompt) => {
    if (!activeEditor) return Promise.resolve("");
    return new Promise((resolve) => {
        activeEditor.startInput(prompt, resolve);
    });
};

function registerAlpineComponents() {
    const savedFilter = JSON.parse(
        localStorage.getItem("vis-filter") || '["blackBox"]',
    );

    Alpine.store("vis", {
        visFilter: savedFilter,
        showModal: false,
        selectedItem: null,
    });

    Alpine.effect(() => {
        const filter = Alpine.store("vis").visFilter;
        localStorage.setItem("vis-filter", JSON.stringify(filter));
    });

    Alpine.data("docModal", () => ({
        init() {
            this.$watch("$store.vis.visFilter", (value) => {
                Prism.highlightAll();
            });
        },
        closeModal() {
            this.$store.vis.showModal = false;
        },
        paramFormat(paramObj) {
            if (
                !this.$store.vis.visFilter.includes("optParams") &&
                !paramObj.required
            )
                return "";

            const typeHint = this.$store.vis.visFilter.includes("typeHints")
                ? `${paramObj.type_hint ? ": " + paramObj.type_hint : ""}`
                : "";
            const defaultValue = paramObj.default_value
                ? ` = ${paramObj.default_value}`
                : "";
            const formatedParam = paramObj.name + typeHint + defaultValue;
            return formatedParam;
        },
        signature(selectedItem) {
            let formatedSignature = selectedItem.name + "(";

            const formatedParams = selectedItem.parameters.map((param) =>
                this.paramFormat(param),
            );
            const notEmptyformatedParams = formatedParams.filter(
                (param) => param !== "",
            );
            formatedSignature += notEmptyformatedParams.join(", ");

            formatedSignature += ")";

            formatedSignature += this.$store.vis.visFilter.includes("typeHints")
                ? ` -> ${selectedItem.returns.type}`
                : "";

            return formatedSignature;
        },
        parametersFilter(selectedItem) {
            const allParams = selectedItem?.parameters ?? [];
            const predicat = (p) => {
                return (
                    this.$store.vis.visFilter.includes("optParams") ||
                    (!this.$store.vis.visFilter.includes("optParams") &&
                        p.required)
                );
            };
            return allParams.filter((p) => predicat(p));
        },
        returnFormat(selectedItem) {
            return selectedItem.returns.type;
        },
    }));

    Alpine.data("skulptEditor", (editorId) => ({
        editorId: editorId,
        editor: null,
        originalCode: "",
        isRunning: false,
        isWaitingForInput: false,
        hasError: false,
        status: "ready",
        statusImages: {
            ready: {
                icon: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiM1MTU3NmQiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1zcXVpcmNsZS1kYXNoZWQtaWNvbiBsdWNpZGUtc3F1aXJjbGUtZGFzaGVkIj48cGF0aCBkPSJNMTMuNzcgMy4wNDNhMzQgMzQgMCAwIDAtMy41NCAwIi8+PHBhdGggZD0iTTEzLjc3MSAyMC45NTZhMzMgMzMgMCAwIDEtMy41NDEuMDAxIi8+PHBhdGggZD0iTTIwLjE4IDE3Ljc0Yy0uNTEgMS4xNS0xLjI5IDEuOTMtMi40MzkgMi40NCIvPjxwYXRoIGQ9Ik0yMC4xOCA2LjI1OWMtLjUxLTEuMTQ4LTEuMjkxLTEuOTI5LTIuNDQtMi40MzgiLz48cGF0aCBkPSJNMjAuOTU3IDEwLjIzYTMzIDMzIDAgMCAxIDAgMy41NCIvPjxwYXRoIGQ9Ik0zLjA0MyAxMC4yM2EzNCAzNCAwIDAgMCAuMDAxIDMuNTQxIi8+PHBhdGggZD0iTTYuMjYgMjAuMTc5Yy0xLjE1LS41MDgtMS45My0xLjI5LTIuNDQtMi40MzgiLz48cGF0aCBkPSJNNi4yNiAzLjgyYy0xLjE0OS41MS0xLjkzIDEuMjkxLTIuNDQgMi40NCIvPjwvc3ZnPg==",
                title: "Редактор готов",
            },
            running: {
                icon: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXNxdWFyZS1jaGV2cm9uLXJpZ2h0LWljb24gbHVjaWRlLXNxdWFyZS1jaGV2cm9uLXJpZ2h0Ij48cmVjdCB3aWR0aD0iMTgiIGhlaWdodD0iMTgiIHg9IjMiIHk9IjMiIHJ4PSIyIi8+PHBhdGggZD0ibTEwIDggNCA0LTQgNCIvPjwvc3ZnPg==",
                title: "Скрипт запущен",
            },
            "waiting-input": {
                icon: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiMwMGE2ZWQiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1rZXlib2FyZC1pY29uIGx1Y2lkZS1rZXlib2FyZCI+PHBhdGggZD0iTTEwIDhoLjAxIi8+PHBhdGggZD0iTTEyIDEyaC4wMSIvPjxwYXRoIGQ9Ik0xNCA4aC4wMSIvPjxwYXRoIGQ9Ik0xNiAxMmguMDEiLz48cGF0aCBkPSJNMTggOGguMDEiLz48cGF0aCBkPSJNNiA4aC4wMSIvPjxwYXRoIGQ9Ik03IDE2aDEwIi8+PHBhdGggZD0iTTggMTJoLjAxIi8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjE2IiB4PSIyIiB5PSI0IiByeD0iMiIvPjwvc3ZnPg==",
                title: "Ожидается ввод значений",
            },
            error: {
                icon: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNlMzRhNmYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1iYWRnZS1hbGVydC1pY29uIGx1Y2lkZS1iYWRnZS1hbGVydCI+PHBhdGggZD0iTTMuODUgOC42MmE0IDQgMCAwIDEgNC43OC00Ljc3IDQgNCAwIDAgMSA2Ljc0IDAgNCA0IDAgMCAxIDQuNzggNC43OCA0IDQgMCAwIDEgMCA2Ljc0IDQgNCAwIDAgMS00Ljc3IDQuNzggNCA0IDAgMCAxLTYuNzUgMCA0IDQgMCAwIDEtNC43OC00Ljc3IDQgNCAwIDAgMSAwLTYuNzVaIi8+PGxpbmUgeDE9IjEyIiB4Mj0iMTIiIHkxPSI4IiB5Mj0iMTIiLz48bGluZSB4MT0iMTIiIHgyPSIxMi4wMSIgeTE9IjE2IiB5Mj0iMTYiLz48L3N2Zz4=",
                title: "Ошибка при выполнении скрипта",
            },
            finished: {
                icon: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiM2MGE1NjEiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1iYWRnZS1jaGVjay1pY29uIGx1Y2lkZS1iYWRnZS1jaGVjayI+PHBhdGggZD0iTTMuODUgOC42MmE0IDQgMCAwIDEgNC43OC00Ljc3IDQgNCAwIDAgMSA2Ljc0IDAgNCA0IDAgMCAxIDQuNzggNC43OCA0IDQgMCAwIDEgMCA2Ljc0IDQgNCAwIDAgMS00Ljc3IDQuNzggNCA0IDAgMCAxLTYuNzUgMCA0IDQgMCAwIDEtNC43OC00Ljc3IDQgNCAwIDAgMSAwLTYuNzZaIi8+PHBhdGggZD0ibTkgMTIgMiAyIDQtNCIvPjwvc3ZnPg==",
                title: "Скрипт выполнился без ошибок",
            },
            stopped: {
                icon: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiM1MTU3NmQiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1oYW5kLWljb24gbHVjaWRlLWhhbmQiPjxwYXRoIGQ9Ik0xOCAxMVY2YTIgMiAwIDAgMC0yLTJhMiAyIDAgMCAwLTIgMiIvPjxwYXRoIGQ9Ik0xNCAxMFY0YTIgMiAwIDAgMC0yLTJhMiAyIDAgMCAwLTIgMnYyIi8+PHBhdGggZD0iTTEwIDEwLjVWNmEyIDIgMCAwIDAtMi0yYTIgMiAwIDAgMC0yIDJ2OCIvPjxwYXRoIGQ9Ik0xOCA4YTIgMiAwIDEgMSA0IDB2NmE4IDggMCAwIDEtOCA4aC0yYy0yLjggMC00LjUtLjg2LTUuOTktMi4zNGwtMy42LTMuNmEyIDIgMCAwIDEgMi44My0yLjgyTDcgMTUiLz48L3N2Zz4=",
                title: "Скрипт остановлен",
            },
        },
        shouldStop: false,
        inputResolver: null,
        pyGlobals: null,
        functionNames: [],

        stdoutBuffer: "",
        stderrBuffer: "",

        init() {
            this.originalCode = this.$refs.original.textContent;
            this.$nextTick(async () => {
                this.initAce();
                const py = await initPyodide();
                this.pyGlobals = py.runPython("dict()");
                this.getAST(this.getCode());
            });
        },

        openModal(item) {
            const index = window.__NAMES__.indexOf(item);
            this.$store.vis.selectedItem = window.__DOCS__[index];
            this.$store.vis.showModal = true;
            this.$nextTick(() => {
                Prism.highlightAll();
            });
        },

        initAce() {
            const container = this.$refs.editorContainer;
            this.editor = ace.edit(container);
            this.editor.setTheme("ace/theme/github_light_default");
            this.editor.session.setMode("ace/mode/python");
            this.editor.setValue(this.originalCode, -1);

            ace.require("ace/ext/language_tools");

            this.editor.session.setUseWrapMode(false);
            this.editor.setOptions({
                fontSize: "0.95rem",
                showPrintMargin: false,
                highlightActiveLine: false,
                highlightGutterLine: false,
                enableBasicAutocompletion: true,
                enableSnippets: true,
                enableLiveAutocompletion: false,
            });

            const updateHeight = () => {
                const lineHeight = this.editor.renderer.lineHeight || 16;
                let h = (this.editor.session.getLength() + 0.5) * lineHeight;
                if (this.editor.renderer.scrollBar)
                    h += this.editor.renderer.scrollBar.getWidth();
                container.style.height =
                    (h > 40 ? Math.min(h, 350) : 40) + "px";
                this.editor.resize();
            };

            let validationTimeout = null;
            this.editor.session.on("change", () => {
                updateHeight();
                clearTimeout(validationTimeout);
                validationTimeout = setTimeout(() => {
                    this.getAST(this.getCode());
                }, 500);
            });
            updateHeight();
        },

        getCode() {
            return this.editor ? this.editor.getValue() : "";
        },

        stdoutRaw(char) {
            console.log(char);
            this.stdoutBuffer += String.fromCharCode(char);
            if (char !== 10) {
                this.addOutput(this.stdoutBuffer);
                this.stdoutBuffer = "";
            }
        },

        addOutput(text) {
            const out = this.$refs.output;
            out.style.display = "block";
            out.appendChild(document.createTextNode(text));
            out.scrollTop = out.scrollHeight;
        },

        clearOutput() {
            this.editor.getSession().setAnnotations([]); // убираем все отметки об ошибках
            this.stdoutBuffer = "";
            this.$refs.output.innerHTML = "";
            this.$refs.output.style.display = "none";
            this.status = "ready";
        },

        async getAST(code) {
            const py = await initPyodide();
            if (!py) {
                this.functionNames = [];
                return;
            }
            try {
                const result = py.runPython(
                    `__qcode_get_calls(${JSON.stringify(code)})`,
                );
                const allNames = result.toJs();
                this.functionNames = allNames.filter((n) =>
                    window.__NAMES__.includes(n),
                );
            } catch (e) {
                console.log(e);
                this.functionNames = [];
            }
        },

        extractErrorMessage(message) {
            const errorRegex =
                /  File.+line (?<line>\d+)[\w\s^*=(){}\[\]:\.]*\s(?<type>\w+): (?<desc>.+)/gm;
            const match = message.match(errorRegex);

            console.log(match);
        },

        // Запуск кода
        async run() {
            if (this.isRunning || activeEditor) return;

            const py = await initPyodide();
            this.pyGlobals = py.runPython("dict()"); // reset Globals before run

            activeEditor = this;

            this.isRunning = true;
            this.status = "running";

            this.clearOutput();

            if (window.__pyodideInterruptBuffer) {
                window.__pyodideInterruptBuffer[0] = 0;
            }

            py.setStdout({
                batched: (msg) => this.addOutput(`${msg}\n\r`),
            });
            py.setStderr({ batched: (msg) => this.addOutput(`${msg}\n\r`) });

            let code = this.getCode();
            const transformedCode = code.replace(
                /\binput\s*\(/g,
                "await input(",
            );

            try {
                const runFunc = py.globals.get("__qcode_run");
                await runFunc(transformedCode, this.pyGlobals);
                this.status = this.shouldStop ? "stopped" : "finished";
            } catch (err) {
                if (err.message.includes("KeyboardInterrupt")) {
                    this.addOutput("\nВыполнение остановлено пользователем.\n");
                    this.status = "stopped";
                } else {
                    this.status = "error";
                    this.addOutput(err.message + "\n");
                    this.extractErrorMessage(err.message);
                    // this.editor.getSession().setAnnotations([
                    //     {
                    //         row: 0,
                    //         text: "error",
                    //         type: "error",
                    //     },
                    // ]);
                }
            } finally {
                this.isRunning = false;
                this.inputResolver = null;
                this.isWaitingForInput = false;
                activeEditor = null;
                this.shouldStop = false;
            }
        },

        stop() {
            if (!this.isRunning) return;
            this.shouldStop = true;

            // Если ждём ввода — удаляем <input> и разрешаем Promise пустой строкой
            if (this.inputResolver) {
                const out = this.$refs.output;
                const inputEl = out.querySelector("input");
                if (inputEl) out.removeChild(inputEl);

                this.inputResolver("");
                this.inputResolver = null;
                this.isWaitingForInput = false;
            }

            // Прерывание вычислений
            if (window.__pyodideInterruptBuffer) {
                window.__pyodideInterruptBuffer[0] = 2;
            } else if (pyodideInstance) {
                pyodideInstance
                    .runPythonAsync(`raise KeyboardInterrupt()`)
                    .catch(() => {});
            }

            this.isRunning = false;
            this.status = "stopped";
            activeEditor = null;
        },

        startInput(prompt, resolve) {
            this.inputResolver = resolve;
            this.isWaitingForInput = true;
            this.status = "waiting-input";

            // Выводим prompt в <pre>
            this.addOutput(prompt);

            const out = this.$refs.output;
            const inputEl = document.createElement("input");
            inputEl.type = "text";

            inputEl.onkeydown = (e) => {
                if (e.key === "Enter") {
                    e.preventDefault();
                    const value = inputEl.value;

                    // Отображаем введённое значение и перенос строки
                    this.addOutput(value + "\n");
                    out.removeChild(inputEl);

                    this.isWaitingForInput = false;
                    this.inputResolver = null;
                    if (!this.shouldStop) this.status = "running";

                    resolve(value);
                }
            };

            out.appendChild(inputEl);
            inputEl.focus();
        },

        resetCode() {
            if (this.editor) this.editor.setValue(this.originalCode, -1);
            if (this.pyGlobals) {
                this.pyGlobals.clear();
            }
        },

        copyCode() {
            navigator.clipboard.writeText(this.getCode());
        },

        saveToFile() {
            const blob = new Blob([this.getCode().replace(/\n/g, "\r\n")], {
                type: "plain/text",
            });
            const a = document.createElement("a");
            a.href = window.URL.createObjectURL(blob);
            a.download = "script.py";
            a.style.display = "none";
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
        },
    }));

    Alpine.data("apiSearch", () => ({
        query: "",
        results: [],
        fuse: new Fuse(window.__DOCS__, {
            useExtendedSearch: true,
            keys: ["name"],
            threshold: 0.3,
            includeScore: true,
        }),
        init() {
            this.$watch("$store.vis.visFilter", (value) => {
                Prism.highlightAll();
            });
        },
        searchDef() {
            if (this.query.length < 3) {
                this.results = [];
            } else {
                this.results = this.fuse.search(this.query, { limit: 5 });
            }
            this.$nextTick(() => {
                Prism.highlightAll();
            });
        },
        openModal(item) {
            this.$store.vis.selectedItem = item;
            this.$store.vis.showModal = true;
            this.$nextTick(() => {
                this.query = "";
                this.results = [];
                Prism.highlightAll();
            });
        },
    }));
}

if (window.Alpine) {
    registerAlpineComponents();
} else {
    document.addEventListener("alpine:init", () => {
        initPyodide().then((py) => {
            // Асинхронная обёртка для input() без дублирующего print()
            py.runPythonAsync(`
import builtins
import js

async def __sk_input(prompt=""):
    return await js.window.__skGetInput(prompt)

builtins.input = __sk_input
`);
        });
        registerAlpineComponents();
    });
}
