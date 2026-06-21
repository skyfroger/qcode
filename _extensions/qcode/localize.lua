
-- // LOCALIZATION STRINGS //
local loc_data = {
  en = {
    showOptionalParams = "Show optional parameters",
    showTypes = "Show types",
    showDiagram = "Show diagram",
    parameters = "Parameters",
    returnValue = "Return value",
    examples = "Examples",
    codeExample = "Code",
    codeOutput = "Output",
    linkToDocs = "Link to the documentation",
    runCode = "Run script",
    stopCode = "Stop script",
    hideExecResults = "Hide result",
    restoreSourceCode = "Restore code",
    copyCode = "Copy",
    saveCode = "Save to file...",
    listOfFunctions = "List of used functions",
    searchInputPlaceholder = "Type function or method name",
  },
  ru = {
    showOptionalParams = "Показать необязательные параметры",
    showTypes = "Показать типы",
    showDiagram = "Показать диаграмму",
    parameters = "Параметры",
    returnValue = "Возвращаемое значение",
    examples = "Примеры",
    codeExample = "Код",
    codeOutput = "Вывод",
    linkToDocs = "Ссылка на документацию (англ.)",
    runCode = "Запустить",
    stopCode = "Остановить скрипт",
    hideExecResults = "Скрыть результат работы скрипта",
    restoreSourceCode = "Восстановить исходный код",
    copyCode = "Скопировать код",
    saveCode = "Сохранить скрипт в файл...",
    listOfFunctions = "Список используемых функций",
    searchInputPlaceholder = "Введите название функции или метода",
  }
}
-- // END OF LOCALIZATION STRINGS //

-- localisation helper function
local M = {}
local current_loc_data = loc_data["en"] -- default language: english

-- set localisation language
function M.load(lang)
  current_loc_data = loc_data[lang] or loc_data["en"]
end

function M.get(key)
  return current_loc_data[key] or loc_data["en"][key] or key
end

-- make table callable
setmetatable(M, {
  __call = function(_, key)
    return M.get(key)
  end
})

return M