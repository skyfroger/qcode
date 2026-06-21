[![English](https://img.shields.io/badge/lang-en-blue.svg)](README.md)
[![Русский](https://img.shields.io/badge/lang-ru-red.svg)](README.ru.md)

# qCode

**qCode** — расширение для [Quarto](https://quarto.org/), которое добавляет на страницу интерактивную Python IDE с возможностью выполнения кода прямо в браузере, а также поиск документации по функциям и методам Python.

## Установка

Добавьте расширение в свой проект Quarto:

```bash
quarto add skyfroger/qcode
```

После установки подключите фильтр `qcode` в YAML-заголовке документа или в `_quarto.yml` проекта.

## Локализация

Для локализации элементов интерфейса расширения укажите в YAML атрибут `lang`. По умолчанию используется английский язык. Также доступен русский язык:

```yaml
lang: ru
```

## Интерактивный редактор Python

Чтобы блок с Python-кодом стал интерактивным, укажите `sk-python` в качестве типа блока кода:

````markdown
```sk-python
for letter in "Привет, мир":
    print(letter)
```
````

Код внутри такого блока будет помещён в интерактивную среду разработки с поддержкой:

- **Выполнения кода** — запуск Python-скриптов в браузере через [Pyodide](https://pyodide.org/).
- **Ввода данных** — интерактивный `input()` прямо в окне вывода.
- **Подсветки синтаксиса** — редактор на базе [Ace Editor](https://ace.c9.io/).
- **Обнаружения функций** — автоматический анализ AST для выявления вызовов функций из документации.
- **Остановки выполнения** — прерывание бесконечных циклов и долгих вычислений.

### Панель инструментов редактора

Каждый редактор содержит кнопки:

| Кнопка | Назначение |
|--------|------------|
| <img style="display: inline-block; border-radius: 0.3em;background: #60a561;" src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNmZmZmZmYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1wbGF5LWljb24gbHVjaWRlLXBsYXkiPjxwYXRoIGQ9Ik01IDVhMiAyIDAgMCAxIDMuMDA4LTEuNzI4bDExLjk5NyA2Ljk5OGEyIDIgMCAwIDEgLjAwMyAzLjQ1OGwtMTIgN0EyIDIgMCAwIDEgNSAxOXoiLz48L3N2Zz4=" /> | Запустить код |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNlNzY1ODUiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1zcXVhcmUtaWNvbiBsdWNpZGUtc3F1YXJlIj48cmVjdCB3aWR0aD0iMTgiIGhlaWdodD0iMTgiIHg9IjMiIHk9IjMiIHJ4PSIyIi8+PC9zdmc+" /> | Остановить выполнение |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXBhbmVsLWJvdHRvbS1jbG9zZS1pY29uIGx1Y2lkZS1wYW5lbC1ib3R0b20tY2xvc2UiPjxyZWN0IHdpZHRoPSIxOCIgaGVpZ2h0PSIxOCIgeD0iMyIgeT0iMyIgcng9IjIiLz48cGF0aCBkPSJNMyAxNWgxOCIvPjxwYXRoIGQ9Im0xNSA4LTMgMy0zLTMiLz48L3N2Zz4=" /> | Очистить результаты выполнения |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXJvdGF0ZS1jY3ctaWNvbiBsdWNpZGUtcm90YXRlLWNjdyI+PHBhdGggZD0iTTMgMTJhOSA5IDAgMSAwIDktOSA5Ljc1IDkuNzUgMCAwIDAtNi43NCAyLjc0TDMgOCIvPjxwYXRoIGQ9Ik0zIDN2NWg1Ii8+PC9zdmc+" /> | Восстановить исходный код |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLWZpbGVzLWljb24gbHVjaWRlLWZpbGVzIj48cGF0aCBkPSJNMTUgMmgtNGEyIDIgMCAwIDAtMiAydjExYTIgMiAwIDAgMCAyIDJoOGEyIDIgMCAwIDAgMi0yVjgiLz48cGF0aCBkPSJNMTYuNzA2IDIuNzA2QTIuNCAyLjQgMCAwIDAgMTUgMnY1YTEgMSAwIDAgMCAxIDFoNWEyLjQgMi40IDAgMCAwLS43MDYtMS43MDZ6Ii8+PHBhdGggZD0iTTUgN2EyIDIgMCAwIDAtMiAydjExYTIgMiAwIDAgMCAyIDJoOGEyIDIgMCAwIDAgMS43MzItMSIvPjwvc3ZnPg==" /> | Копировать код в буфер обмена |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXNhdmUtaWNvbiBsdWNpZGUtc2F2ZSI+PHBhdGggZD0iTTE1LjIgM2EyIDIgMCAwIDEgMS40LjZsMy44IDMuOGEyIDIgMCAwIDEgLjYgMS40VjE5YTIgMiAwIDAgMS0yIDJINWEyIDIgMCAwIDEtMi0yVjVhMiAyIDAgMCAxIDItMnoiLz48cGF0aCBkPSJNMTcgMjF2LTdhMSAxIDAgMCAwLTEtMUg4YTEgMSAwIDAgMC0xIDF2NyIvPjxwYXRoIGQ9Ik03IDN2NGExIDEgMCAwIDAgMSAxaDciLz48L3N2Zz4=" /> | Сохранить код в файл `script.py` |

### Индикатор статуса

В правом верхнем углу редактора отображается текущий статус:

| Статус | Описание |
|--------|----------|
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiM1MTU3NmQiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1zcXVpcmNsZS1kYXNoZWQtaWNvbiBsdWNpZGUtc3F1aXJjbGUtZGFzaGVkIj48cGF0aCBkPSJNMTMuNzcgMy4wNDNhMzQgMzQgMCAwIDAtMy41NCAwIi8+PHBhdGggZD0iTTEzLjc3MSAyMC45NTZhMzMgMzMgMCAwIDEtMy41NDEuMDAxIi8+PHBhdGggZD0iTTIwLjE4IDE3Ljc0Yy0uNTEgMS4xNS0xLjI5IDEuOTMtMi40MzkgMi40NCIvPjxwYXRoIGQ9Ik0yMC4xOCA2LjI1OWMtLjUxLTEuMTQ4LTEuMjkxLTEuOTI5LTIuNDQtMi40MzgiLz48cGF0aCBkPSJNMjAuOTU3IDEwLjIzYTMzIDMzIDAgMCAxIDAgMy41NCIvPjxwYXRoIGQ9Ik0zLjA0MyAxMC4yM2EzNCAzNCAwIDAgMCAuMDAxIDMuNTQxIi8+PHBhdGggZD0iTTYuMjYgMjAuMTc5Yy0xLjE1LS41MDgtMS45My0xLjI5LTIuNDQtMi40MzgiLz48cGF0aCBkPSJNNi4yNiAzLjgyYy0xLjE0OS41MS0xLjkzIDEuMjkxLTIuNDQgMi40NCIvPjwvc3ZnPg==" /> Готов | Редактор загружен и готов к работе |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXNxdWFyZS1jaGV2cm9uLXJpZ2h0LWljb24gbHVjaWRlLXNxdWFyZS1jaGV2cm9uLXJpZ2h0Ij48cmVjdCB3aWR0aD0iMTgiIGhlaWdodD0iMTgiIHg9IjMiIHk9IjMiIHJ4PSIyIi8+PHBhdGggZD0ibTEwIDggNCA0LTQgNCIvPjwvc3ZnPg==" /> Выполняется | Код запущен на выполнение |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiMwMGE2ZWQiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1rZXlib2FyZC1pY29uIGx1Y2lkZS1rZXlib2FyZCI+PHBhdGggZD0iTTEwIDhoLjAxIi8+PHBhdGggZD0iTTEyIDEyaC4wMSIvPjxwYXRoIGQ9Ik0xNCA4aC4wMSIvPjxwYXRoIGQ9Ik0xNiAxMmguMDEiLz48cGF0aCBkPSJNMTggOGguMDEiLz48cGF0aCBkPSJNNiA4aC4wMSIvPjxwYXRoIGQ9Ik03IDE2aDEwIi8+PHBhdGggZD0iTTggMTJoLjAxIi8+PHJlY3Qgd2lkdGg9IjIwIiBoZWlnaHQ9IjE2IiB4PSIyIiB5PSI0IiByeD0iMiIvPjwvc3ZnPg==" /> Ожидает ввода | Скрипт ожидает данные от пользователя |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNlMzRhNmYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1iYWRnZS1hbGVydC1pY29uIGx1Y2lkZS1iYWRnZS1hbGVydCI+PHBhdGggZD0iTTMuODUgOC42MmE0IDQgMCAwIDEgNC43OC00Ljc3IDQgNCAwIDAgMSA2Ljc0IDAgNCA0IDAgMCAxIDQuNzggNC43OCA0IDQgMCAwIDEgMCA2Ljc0IDQgNCAwIDAgMS00Ljc3IDQuNzggNCA0IDAgMCAxLTYuNzUgMCA0IDQgMCAwIDEtNC43OC00Ljc3IDQgNCAwIDAgMSAwLTYuNzVaIi8+PGxpbmUgeDE9IjEyIiB4Mj0iMTIiIHkxPSI4IiB5Mj0iMTIiLz48bGluZSB4MT0iMTIiIHgyPSIxMi4wMSIgeTE9IjE2IiB5Mj0iMTYiLz48L3N2Zz4=" /> Ошибка | При выполнении произошла ошибка |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiM2MGE1NjEiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1iYWRnZS1jaGVjay1pY29uIGx1Y2lkZS1iYWRnZS1jaGVjayI+PHBhdGggZD0iTTMuODUgOC42MmE0IDQgMCAwIDEgNC43OC00Ljc3IDQgNCAwIDAgMSA2Ljc0IDAgNCA0IDAgMCAxIDQuNzggNC43OCA0IDQgMCAwIDEgMCA2Ljc0IDQgNCAwIDAgMS00Ljc3IDQuNzggNCA0IDAgMCAxLTYuNzUgMCA0IDQgMCAwIDEtNC43OC00Ljc3IDQgNCAwIDAgMSAwLTYuNzZaIi8+PHBhdGggZD0ibTkgMTIgMiAyIDQtNCIvPjwvc3ZnPg==" /> Завершён | Скрипт выполнился без ошибок |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiM1MTU3NmQiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1oYW5kLWljb24gbHVjaWRlLWhhbmQiPjxwYXRoIGQ9Ik0xOCAxMVY2YTIgMiAwIDAgMC0yLTJhMiAyIDAgMCAwLTIgMiIvPjxwYXRoIGQ9Ik0xNCAxMFY0YTIgMiAwIDAgMC0yLTJhMiAyIDAgMCAwLTIgMnYyIi8+PHBhdGggZD0iTTEwIDEwLjVWNmEyIDIgMCAwIDAtMi0yYTIgMiAwIDAgMC0yIDJ2OCIvPjxwYXRoIGQ9Ik0xOCA4YTIgMiAwIDEgMSA0IDB2NmE4IDggMCAwIDEtOCA4aC0yYy0yLjggMC00LjUtLjg2LTUuOTktMi4zNGwtMy42LTMuNmEyIDIgMCAwIDEgMi44My0yLjgyTDcgMTUiLz48L3N2Zz4=" /> Остановлен | Выполнение прервано пользователем |

### Строка используемых функций

Под редактором отображается список функций и методов, обнаруженных в коде. Клик по любой функции открывает модальное окно с её документацией.

## Поиск документации

Для добавления поля поиска по документации Python используйте блок с классом `.sk-api-search`:

```markdown
:::{.sk-api-search}
Документация содержит стандартные функции языка Python и методы встроенных типов.
:::
```

Поиск работает в режиме реального времени (с задержкой 300 мс). Результаты отображаются в выпадающем списке. Клик по результату открывает модальное окно с подробной документацией функции.

### Модальное окно документации

Модальное окно содержит:

- **Сигнатуру функции** — имя, параметры и возвращаемый тип.
- **Диаграмму «чёрного ящика»** — визуализацию входных параметров и выходного значения.
- **Описание** — текстовое описание функции.
- **Параметры** — список параметров с типами, значениями по умолчанию и описаниями.
- **Возвращаемое значение** — тип и описание результата.
- **Примеры** — примеры использования с входным кодом и ожидаемым выводом.
- **Ссылку на официальную документацию**.

### Настройки отображения документации

В модальном окне доступны переключатели:

| Переключатель | Описание |
|---------------|----------|
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXNldHRpbmdzMi1pY29uIGx1Y2lkZS1zZXR0aW5ncy0yIj48cGF0aCBkPSJNMTQgMTdINSIvPjxwYXRoIGQ9Ik0xOSA3aC05Ii8+PGNpcmNsZSBjeD0iMTciIGN5PSIxNyIgcj0iMyIvPjxjaXJjbGUgY3g9IjciIGN5PSI3IiByPSIzIi8+PC9zdmc+"/> | Показывать/скрывать необязательные параметры |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXNoYXBlcy1pY29uIGx1Y2lkZS1zaGFwZXMiPjxwYXRoIGQ9Ik04LjMgMTBhLjcuNyAwIDAgMS0uNjI2LTEuMDc5TDExLjQgM2EuNy43IDAgMCAxIDEuMTk4LS4wNDNMMTYuMyA4LjlhLjcuNyAwIDAgMS0uNTcyIDEuMVoiLz48cmVjdCB4PSIzIiB5PSIxNCIgd2lkdGg9IjciIGhlaWdodD0iNyIgcng9IjEiLz48Y2lyY2xlIGN4PSIxNy41IiBjeT0iMTcuNSIgcj0iMy41Ii8+PC9zdmc+" /> | Показывать/скрывать подсказки типов (type hints) |
| <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLW5ldHdvcmstaWNvbiBsdWNpZGUtbmV0d29yayI+PHJlY3QgeD0iMTYiIHk9IjE2IiB3aWR0aD0iNiIgaGVpZ2h0PSI2IiByeD0iMSIvPjxyZWN0IHg9IjIiIHk9IjE2IiB3aWR0aD0iNiIgaGVpZ2h0PSI2IiByeD0iMSIvPjxyZWN0IHg9IjkiIHk9IjIiIHdpZHRoPSI2IiBoZWlnaHQ9IjYiIHJ4PSIxIi8+PHBhdGggZD0iTTUgMTZ2LTNhMSAxIDAgMCAxIDEtMWgxMmExIDEgMCAwIDEgMSAxdjMiLz48cGF0aCBkPSJNMTIgMTJWOCIvPjwvc3ZnPg==" /> | Показывать/скрывать диаграмму «чёрного ящика» |

Настройки сохраняются в `localStorage` и применяются ко всем модальным окнам.

## Советы по разметке

1. **Фильтр в YAML.** Не забудьте добавить `filters: - qcode` в заголовок документа.
2. **Несколько редакторов.** На одной странице может быть несколько блоков `sk-python` — каждый получит собственный редактор с независимым окружением выполнения.
3. **Прерывание выполнения.** Для остановки бесконечного цикла используйте кнопку «Стоп» (если браузер поддерживает `SharedArrayBuffer`).
4. **Безопасность.** Код выполняется в изолированном окружении Pyodide внутри браузера, без доступа к файловой системе пользователя.
