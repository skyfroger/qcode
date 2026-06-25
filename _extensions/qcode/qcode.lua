local EXTENSION_NAME = "qcode"

local l10n  = require("./utils/localize")

local function writeEnvironments()
  if quarto.doc.is_format("html:js") then
    quarto.doc.add_html_dependency({
      name = "qcode",
      version = "1",
      scripts = {
        { path = "python-qcode.js"}
      },
      stylesheets = { "qc-styles.css", "prism-theme-github-light.css" }
    })

    quarto.doc.add_html_dependency({
      name = "alpine",
      version = "3.12",
      scripts = {
        { path = "sort-alpine.min.js", afterBody = "true" },
        { path = "alpine.min.js", afterBody = "true" },
      }
    })

    quarto.doc.add_html_dependency({
      name = "prism",
      version = "1",
      scripts = {
        { path = "prism.js", afterBody = "true" }
      }
    })
  end
end

local docsJSON = "" -- JSON from yaml documentation file
local aceLibsAdded = false
local function addAceLibsOnce()
  if aceLibsAdded then return end
  aceLibsAdded = true
  quarto.doc.include_text("in-header", [[
<script src="https://unpkg.com/fuse.js@7.2.0/dist/fuse.min.js"></script>  
<script src="https://www.unpkg.com/ace-builds@latest/src-noconflict/ace.js"></script>
<script src="https://www.unpkg.com/ace-builds@latest/src-noconflict/ext-language_tools.js"></script>
<script src="https://cdn.jsdelivr.net/pyodide/v0.25.0/full/pyodide.js"></script>
<script>
  window.__DOCS__ = ]]..docsJSON..[[;
  window.__NAMES__ = window.__DOCS__.map((entry) => entry.name);
</script>
<style>[x-cloak] { display: none !important; }</style>
]])
end

local modalAdded = false
local function addModal()
  if modalAdded then return end
  modalAdded = true
  quarto.doc.include_text("after-body", [[
<div x-data="docModal" class="modal-overlay"
      x-show="$store.vis.showModal"
      @keydown.escape.window="closeModal"
      @click.self="closeModal"
      x-transition:enter="fade-enter"
      x-transition:enter-start="fade-enter-start"
      x-transition:enter-end="fade-enter-end"
      x-transition:leave="fade-leave"
      x-transition:leave-start="fade-leave-start"
      x-transition:leave-end="fade-leave-end"
      x-cloak>
        <div 
        x-show="$store.vis.showModal" 
        class="modal-content"
        @click.stop
        x-transition:enter="zoom-enter"
        x-transition:enter-start="zoom-enter-start"
        x-transition:enter-end="zoom-enter-end"
        x-transition:leave="zoom-leave"
        x-transition:leave-start="zoom-leave-start"
        x-transition:leave-end="zoom-leave-end"
        x-cloak>
          <div class="modal-toolbar">
            <div class="modal-toolbar-options">
            <label title="]]..l10n("showOptionalParams")..[[">
              <input type="checkbox" value="optParams" x-model="$store.vis.visFilter">
              <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXNldHRpbmdzMi1pY29uIGx1Y2lkZS1zZXR0aW5ncy0yIj48cGF0aCBkPSJNMTQgMTdINSIvPjxwYXRoIGQ9Ik0xOSA3aC05Ii8+PGNpcmNsZSBjeD0iMTciIGN5PSIxNyIgcj0iMyIvPjxjaXJjbGUgY3g9IjciIGN5PSI3IiByPSIzIi8+PC9zdmc+"/>
            </label>

            <label title="]]..l10n("showTypes")..[[">
              <input type="checkbox" value="typeHints" x-model="$store.vis.visFilter">
              <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXNoYXBlcy1pY29uIGx1Y2lkZS1zaGFwZXMiPjxwYXRoIGQ9Ik04LjMgMTBhLjcuNyAwIDAgMS0uNjI2LTEuMDc5TDExLjQgM2EuNy43IDAgMCAxIDEuMTk4LS4wNDNMMTYuMyA4LjlhLjcuNyAwIDAgMS0uNTcyIDEuMVoiLz48cmVjdCB4PSIzIiB5PSIxNCIgd2lkdGg9IjciIGhlaWdodD0iNyIgcng9IjEiLz48Y2lyY2xlIGN4PSIxNy41IiBjeT0iMTcuNSIgcj0iMy41Ii8+PC9zdmc+"/>
            </label>

            <label title="]]..l10n("showDiagram")..[[">
              <input type="checkbox" value="blackBox" x-model="$store.vis.visFilter">
              <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLW5ldHdvcmstaWNvbiBsdWNpZGUtbmV0d29yayI+PHJlY3QgeD0iMTYiIHk9IjE2IiB3aWR0aD0iNiIgaGVpZ2h0PSI2IiByeD0iMSIvPjxyZWN0IHg9IjIiIHk9IjE2IiB3aWR0aD0iNiIgaGVpZ2h0PSI2IiByeD0iMSIvPjxyZWN0IHg9IjkiIHk9IjIiIHdpZHRoPSI2IiBoZWlnaHQ9IjYiIHJ4PSIxIi8+PHBhdGggZD0iTTUgMTZ2LTNhMSAxIDAgMCAxIDEtMWgxMmExIDEgMCAwIDEgMSAxdjMiLz48cGF0aCBkPSJNMTIgMTJWOCIvPjwvc3ZnPg=="/>
            </label>
            </div>
            <button class="btn-close" @click="closeModal">&times;</button>
          </div>
          <div class="modal-card">
            
          <template x-if="$store.vis.selectedItem">
            <div style="overflow-y: auto;">
              <h4 class="signature">
                <code class="language-python" x-text="signature($store.vis.selectedItem)"></code>
              </h4>

              <div x-show="$store.vis.visFilter.includes('blackBox')" class="blackbox">
                <div class="blackbox__input">
                  <ul>
                    <template x-for="(param, index) in parametersFilter($store.vis.selectedItem)" :key="index">
                      <li :class="param.required ? 'required' : '' ">
                        <code x-text="param.name"></code>
                      </li>
                    </template>
                  </ul>
                </div>
                <div class="blackbox__body">
                  <code x-text="$store.vis.selectedItem.name"></code>
                </div>
                <div class="blackbox__output">
                  <div x-show="$store.vis.selectedItem.returns.type !== 'None'">
                    <code
                    x-text="$store.vis.visFilter.includes('typeHints') ? $store.vis.selectedItem.returns.type : '&nbsp;'"></code>
                  </div>
                </div>
              </div>

              <p x-text="$store.vis.selectedItem.description"></p>
              
              <template x-if="parametersFilter($store.vis.selectedItem).length !== 0">
              <div>
                <h4>]]..l10n("parameters")..[[</h4>
                <ul>
                  <template x-for="(param, index) in parametersFilter($store.vis.selectedItem)" :key="index">
                    <li>
                      <code class="language-python" x-text="paramFormat(param)"></code>
                      <span x-text="` - ${param.description}`"></span>
                    </li>
                  </template>
                </ul>
              </div>
              </template>
              
                <div>
                  <h4>]]..l10n("returnValue")..[[</h4>

                  <code 
                    x-show="$store.vis.visFilter.includes('typeHints')" 
                    class="language-python" 
                    x-text="returnFormat($store.vis.selectedItem)"></code>
                  <span x-text="$store.vis.selectedItem.returns.description"></span>
                </div>

              <h4>]]..l10n("examples")..[[</h4>
              <template x-for="(example, index) in $store.vis.selectedItem.examples" :key="index">
                <div class="api__example">
                  <div class="api__example__input">
                    <span class="vertical-text">]]..l10n("codeExample")..[[</span>
                    <pre><code class="language-python" x-text="example.code"></code></pre>
                  </div>
                  <div class="api__example__output" x-show="example.output !== ''">
                    <span class="vertical-text">]]..l10n("codeOutput")..[[</span>
                    <code class="language-markdown" x-text="example.output"></code>
                  </div>
                  
                </div>
              </template>

              <p>
                <a :href="$store.vis.selectedItem.url" target="_blank">]]..l10n("linkToDocs")..[[</a>
              </p>

          </div>
          </template>
        </div>
      </div>
      </div>
]])
end

local idesCounter = 0

function createSkulptIDE(block)
  local elementContent = {}
  local id = idesCounter

  table.insert(elementContent, pandoc.RawBlock("html",
    [[<div class="skulpt-editor" x-data="skulptEditor(]] .. id .. [[)">
    <div class="sk__dropdown">
    <div class="sk__toolbar"> <!-- начало блока с кнопками -->
      <button class="sk__dropdown-button run" type="button"
        :disabled="isRunning"
        @click="run()"
        title="]]..l10n("runCode")..[[">
        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNmZmZmZmYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1wbGF5LWljb24gbHVjaWRlLXBsYXkiPjxwYXRoIGQ9Ik01IDVhMiAyIDAgMCAxIDMuMDA4LTEuNzI4bDExLjk5NyA2Ljk5OGEyIDIgMCAwIDEgLjAwMyAzLjQ1OGwtMTIgN0EyIDIgMCAwIDEgNSAxOXoiLz48L3N2Zz4=" />
      </button>

      <button class="sk__dropdown-button general" type="button"
        title="]]..l10n("stopCode")..[["
        :disabled="!isRunning"
        @click="stop()">
        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNlNzY1ODUiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1zcXVhcmUtaWNvbiBsdWNpZGUtc3F1YXJlIj48cmVjdCB3aWR0aD0iMTgiIGhlaWdodD0iMTgiIHg9IjMiIHk9IjMiIHJ4PSIyIi8+PC9zdmc+" />
      </button>

      <button class="sk__dropdown-button general" type="button"
        title="]]..l10n("hideExecResults")..[["
        @click="clearOutput()">
        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXBhbmVsLWJvdHRvbS1jbG9zZS1pY29uIGx1Y2lkZS1wYW5lbC1ib3R0b20tY2xvc2UiPjxyZWN0IHdpZHRoPSIxOCIgaGVpZ2h0PSIxOCIgeD0iMyIgeT0iMyIgcng9IjIiLz48cGF0aCBkPSJNMyAxNWgxOCIvPjxwYXRoIGQ9Im0xNSA4LTMgMy0zLTMiLz48L3N2Zz4=" />
      </button>

      <button class="sk__dropdown-button general" type="button"
        title="]]..l10n("restoreSourceCode")..[["
        @click="resetCode()">
        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXJvdGF0ZS1jY3ctaWNvbiBsdWNpZGUtcm90YXRlLWNjdyI+PHBhdGggZD0iTTMgMTJhOSA5IDAgMSAwIDktOSA5Ljc1IDkuNzUgMCAwIDAtNi43NCAyLjc0TDMgOCIvPjxwYXRoIGQ9Ik0zIDN2NWg1Ii8+PC9zdmc+" />
      </button>

      <button class="sk__dropdown-button general" type="button"
        title="]]..l10n("copyCode")..[["
        @click="copyCode()">
        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLWZpbGVzLWljb24gbHVjaWRlLWZpbGVzIj48cGF0aCBkPSJNMTUgMmgtNGEyIDIgMCAwIDAtMiAydjExYTIgMiAwIDAgMCAyIDJoOGEyIDIgMCAwIDAgMi0yVjgiLz48cGF0aCBkPSJNMTYuNzA2IDIuNzA2QTIuNCAyLjQgMCAwIDAgMTUgMnY1YTEgMSAwIDAgMCAxIDFoNWEyLjQgMi40IDAgMCAwLS43MDYtMS43MDZ6Ii8+PHBhdGggZD0iTTUgN2EyIDIgMCAwIDAtMiAydjExYTIgMiAwIDAgMCAyIDJoOGEyIDIgMCAwIDAgMS43MzItMSIvPjwvc3ZnPg==" />
      </button>

      <button class="sk__dropdown-button general" type="button"
        title="]]..l10n("saveCode")..[["
        @click="saveToFile()">
        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXNhdmUtaWNvbiBsdWNpZGUtc2F2ZSI+PHBhdGggZD0iTTE1LjIgM2EyIDIgMCAwIDEgMS40LjZsMy44IDMuOGEyIDIgMCAwIDEgLjYgMS40VjE5YTIgMiAwIDAgMS0yIDJINWEyIDIgMCAwIDEtMi0yVjVhMiAyIDAgMCAxIDItMnoiLz48cGF0aCBkPSJNMTcgMjF2LTdhMSAxIDAgMCAwLTEtMUg4YTEgMSAwIDAgMC0xIDF2NyIvPjxwYXRoIGQ9Ik03IDN2NGExIDEgMCAwIDAgMSAxaDciLz48L3N2Zz4=" />
      </button>
    </div> <!-- конец блока с кнопками -->

      <img :title="statusImages[status].title" :src="statusImages[status].icon"/>
    </div>

    <div>
      <div class="ide" x-ref="editorContainer"></div>
      <pre id="skulpt-output]] .. id .. [[" x-ref="output" class="output__container"></pre>
      <pre style="display:none" x-ref="original">]] .. block.text .. [[</pre>
    </div>

    <div class="sk__editor__func" x-show="functionNames.length !== 0" x-transition>
    <img title="]]..l10n("listOfFunctions")..[[" style="height: 18px;" src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiM1MTU3NmQiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1ib29rLW1hcmtlZC1pY29uIGx1Y2lkZS1ib29rLW1hcmtlZCI+PHBhdGggZD0iTTEwIDJ2OGwzLTMgMyAzVjIiLz48cGF0aCBkPSJNNCAxOS41di0xNUEyLjUgMi41IDAgMCAxIDYuNSAySDE5YTEgMSAwIDAgMSAxIDF2MThhMSAxIDAgMCAxLTEgMUg2LjVhMSAxIDAgMCAxIDAtNUgyMCIvPjwvc3ZnPg=="/>
    <template x-for="(func, index) in functionNames" :key="index">
      <code x-text="func" @click="openModal(func)"></code>
    </template>
    </div>
</div>

]]))

  idesCounter = idesCounter + 1
  return pandoc.Div(elementContent)
end


function createSkAPISearch(div)
  local content = {}       -- содержимое блока

  table.insert(content, div) -- сохраняем исходную разметку

  -- добавляем поле для поиска
  table.insert(content,
        pandoc.RawBlock("html",[[
    <div x-data="apiSearch">
      <div class="search__form">
        <input
          type="text"
          placeholder="]]..l10n("searchInputPlaceholder")..[["
          @input.debounce="searchDef"
          x-model.fill="query"
        />
      </div>
      <div class="api__suggestions">
        <template x-for="result in results" :key="result.refIndex">
          <div class="api__suggestions__item" @click="openModal(result.item);">
            <code class="language-python" x-text="result.item.name"></code></br>
            <span x-text="result.item.description"></span>
          </div>
        </template>
      </div>
    </div>]]))

  return pandoc.Div(content, { class = "sk-api-search__formated" })
end

-- Загрузка YAML-файла локализации
local function parse_yaml_to_table(path)
  local metafile = io.open(path, 'r')
  local content = metafile:read("*a")
  metafile:close()
  local yamlDocs = require("./utils/tinyyaml").parse(content)
  return yamlDocs
end

local function render_elements(options)

  l10n.load(options.lang)

  local extension_path = pandoc.path.directory(
    pandoc.path.normalize(PANDOC_SCRIPT_FILE)
  )
  local docs = parse_yaml_to_table(extension_path.."/docs/python.yaml")
  docsJSON = quarto.json.encode(docs)

  return {
    CodeBlock = function(block)
      if quarto.doc.isFormat("html:js") and block.classes:includes("sk-python") then
        addAceLibsOnce()
        writeEnvironments()
        addModal()
        return createSkulptIDE(block)
      end
      return nil
    end,
    Div = function(div)
      if quarto.doc.isFormat("html:js") and div.classes:includes("sk-api-search") then -- если div содержит нужный стиль - обрабатываем разметку
          addAceLibsOnce()
          writeEnvironments()
          addModal()
          return createSkAPISearch(div)
      end
      return nil
    end
  }
end

function Pandoc(doc)
  -- default options
  local options = {
    lang = pandoc.utils.stringify(doc.meta.lang)
  }

  -- replace default option with local 
  local globalOptions = doc.meta[EXTENSION_NAME]
  if type(globalOptions) == "table" then
    for k, v in pairs(globalOptions) do
      options[k] = pandoc.utils.stringify(v)
    end
  end

  return doc:walk(render_elements(options))
end