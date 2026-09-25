# Мостик (Mostik)

**Локальный AI-API на вашем компьютере. Формат — как у OpenAI, модели — бесплатные.**

Мостик запускает на вашем ПК сервер с адресом `http://127.0.0.1:4891/v1`, полностью совместимый с
OpenAI API. Любая программа, которая умеет общаться с OpenAI (игра, мод, бот, скрипт, Postman),
начинает работать с ним без единой правки в коде — достаточно поменять адрес и ключ.

Под капотом Мостик использует **OpenCode** — бесплатный AI-агент с набором бесплатных моделей.
Ваша программа думает, что общается с OpenAI. Платёжные данные, аккаунты и подписки не нужны.

---

## Быстрый старт

> Раздел выше — главный. Три шага, две минуты.

### 1. Скачать

Скачайте **`Mostik-win64.zip`** со страницы [**Releases**](../../releases/latest) (последний релиз).
Размер около 100 МБ — внутрь уже упаковано всё, что нужно для работы.

### 2. Распаковать

Распакуйте архив в любую свою папку, например `C:\Mostik` или на рабочий стол.
Установка не требуется: это переносимая программа. Не распаковывайте в `C:\Program Files` —
папке нужны права на запись.

### 3. Запустить

Откройте папку и запустите **`Запустить Мостик.cmd`**.

Что произойдёт:
* Windows один раз спросит подтверждение прав администратора — нажмите **Да**
  (это нужно, чтобы программы могли подключаться к локальному порту).
* Появится окно **«Мостик»**. Сервис под ним запустится сам.
* В окне, в блоке **«Подключение клиентов»**, будут готовые адрес и ключ:
  * **Base URL:** `http://127.0.0.1:4891/v1`
  * **API key:** нажмите **«Копировать»** — ключ создаётся на вашем компьютере при первом запуске.

Если Windows покажет предупреждение SmartScreen («Неизвестный издатель») — нажмите
**«Подробнее» → «Выполнить в любом случае»**. Сборка не подписана сертификатом, это нормально
для открытых проектов.

### Проверка за 30 секунд

Нажмите в окне **«Чат»** → напишите «привет» → отправьте. Ответ пришёл — Мостик работает.
Дальше можно подключать свои программы.

---

## Подключение своих программ

Меняете в программе две вещи — адрес и ключ. Всё остальное остаётся как было.

| Что нужно | Значение |
|---|---|
| Base URL | `http://127.0.0.1:4891/v1` |
| API key | ключ из окна «Мостик» (кнопка «Копировать») |
| Модель | `big-pickle` (или любое имя из `GET /v1/models`) |

**curl**

```bash
curl http://127.0.0.1:4891/v1/chat/completions ^
  -H "Authorization: Bearer ВАШ_КЛЮЧ" ^
  -H "Content-Type: application/json" ^
  -d "{\"model\":\"big-pickle\",\"messages\":[{\"role\":\"user\",\"content\":\"привет\"}]}"
```

**Python (официальная библиотека `openai`)**

```python
from openai import OpenAI

client = OpenAI(base_url="http://127.0.0.1:4891/v1", api_key="ВАШ_КЛЮЧ")

answer = client.chat.completions.create(
    model="big-pickle",
    messages=[{"role": "user", "content": "привет"}],
)
print(answer.choices[0].message.content)
```

**JavaScript / Node.js**

```js
import OpenAI from "openai";

const client = new OpenAI({ baseURL: "http://127.0.0.1:4891/v1", apiKey: "ВАШ_КЛЮЧ" });

const answer = await client.chat.completions.create({
  model: "big-pickle",
  messages: [{ role: "user", content: "привет" }],
});
console.log(answer.choices[0].message.content);
```

**C# / Unity (через стандартный HttpClient)**

```csharp
var client = new HttpClient { BaseAddress = new Uri("http://127.0.0.1:4891/v1/") };
client.DefaultRequestHeaders.Add("Authorization", "Bearer ВАШ_КЛЮЧ");

var body = """{"model":"big-pickle","messages":[{"role":"user","content":"привет"}]}""";
var resp = await client.PostAsync("chat/completions",
    new StringContent(body, System.Text.Encoding.UTF8, "application/json"));
Console.WriteLine(await resp.Content.ReadAsStringAsync());
```

Литература по формату — официальная документация OpenAI API. Всё, что там описано
(`messages`, `temperature`, `stream`, `tools`), Мостик принимает как есть.

---

## Что внутри и как это работает

```
ваша программа  →  http://127.0.0.1:4891/v1  →  Мостик  →  OpenCode  →  модель
     (игра, мод)        формат OpenAI            перевод      агент       (облако)
```

* **Мостик** — два исполняемых файла в одной папке: оконное приложение (управление) и сервис
  (сам API). Оба уже содержат всё необходимое, отдельно ставить .NET не нужно.
* **OpenCode** — открытый AI-агент. Если его нет на компьютере, Мостик скачает и поставит его сам
  (кнопка **«Скачать OpenCode»** в настройках, при первом запуске — автоматически).
* **Модели** — бесплатные модели, доступные через OpenCode. Список актуальных:
  `GET /v1/models` или окно **«Модели»**.

Подробный разбор схемы, стриминга, tool calling и настроек — в документе
[`docs/how-it-works.md`](docs/how-it-works.md).

---

## Возможности

| Возможность | Описание |
|---|---|
| OpenAI-совместимый API | `POST /v1/chat/completions`, `GET /v1/models`, коды и формат ошибок как у OpenAI |
| Стриминг (SSE) | Настоящие чанки по мере генерации; отдельным полем передаётся «размышление» модели (reasoning) |
| Tool calling | `tools` / `functions`, `tool_calls`, `finish_reason="tool_calls"`, ответы роли `tool` |
| Многоходовые диалоги | История отправляется целиком (сервер не хранит состояние — как в обычном API) |
| Алиасы моделей | `gpt-4o`, `gpt-4o-mini` и другие привычные имена → реальные бесплатные модели |
| Автоустановка OpenCode | Нет OpenCode — программа скачает его сама |
| Локальность | Сервер слушает только `127.0.0.1`: наружу ничего не открыто |
| Управление | Окно: Панель, Чат, Модели, Логи, Настройки; старт/стоп/рестарт кнопками |

---

## API

| Метод | Адрес | Назначение |
|---|---|---|
| `GET` | `/v1/models` | Список доступных имён моделей |
| `POST` | `/v1/chat/completions` | Чат и генерация (обычный режим или `stream: true`) |
| `GET` | `/healthz` | Проверка живости сервиса (без ключа) |
| `GET` | `/admin/status` | Состояние: версия, порт, путь к OpenCode, счётчики |
| `GET` | `/admin/logs` | Последние строки логов |
| `POST` | `/admin/opencode/install` | Скачать и установить OpenCode |
| `POST` | `/admin/shutdown` | Остановить сервис |

Ключ передаётся заголовком: `Authorization: Bearer <ключ>`.
Запросы без ключа получают `401` в формате ошибки OpenAI.

---

## Модели и алиасы

По умолчанию настроены привычные имена, за которыми стоят бесплатные модели:

| Имя для программы | Реальная модель OpenCode |
|---|---|
| `gpt-4o` | `opencode/nemotron-3-ultra-free` |
| `gpt-4o-mini` | `opencode/big-pickle` |
| `gpt-4.1-mini` | `opencode/mimo-v2.6-flash-free` |
| `gpt-3.5-turbo` | `opencode/mimo-v2.6-flash-free` |
| `big-pickle` | `opencode/big-pickle` |
| `nemotron-ultra` | `opencode/nemotron-3-ultra-free` |
| `mimo-flash` | `opencode/mimo-v2.6-flash-free` |
| `muse-spark` | `opencode/muse-spark-1.3-contributor-free` |

Переименовать или добавить свои соответствия можно в окне **«Модели»** или прямо в
`appsettings.json` (секция `OpenCode.ModelAliases`). Неизвестное имя модели не вызовет ошибку —
запрос уйдёт на модель по умолчанию (`DefaultModel`).

---

## Настройки

Файл `appsettings.json` лежит рядом с программой и правится как в окне **«Настройки»**, так и
вручную (после правки — кнопка **«Рестарт»** в окне).

| Параметр | По умолчанию | Что делает |
|---|---|---|
| `Urls` | `http://127.0.0.1:4891` | Адрес и порт API. `127.0.0.1` — только этот компьютер |
| `OpenCode.ApiKey` | создаётся при первом запуске | Ключ, который спрашивают клиенты |
| `OpenCode.DefaultModel` | `opencode/big-pickle` | Модель для неизвестных имён |
| `OpenCode.TimeoutSeconds` | `300` | Предельное время одного запроса |
| `OpenCode.MaxConcurrent` | `4` | Сколько запросов могут идти одновременно |
| `OpenCode.WorkDir` | пусто | Рабочая папка агента; пусто — папка `workspace` рядом с программой |
| `OpenCode.ExecutablePath` | пусто | Путь к `opencode.exe`; пусто — искать автоматически |
| `OpenCode.AutoInstall` | `true` | Скачивать OpenCode автоматически, если его нет |
| `OpenCode.ToolCalling` | `true` | Поддержка `tools` / `functions` |
| `OpenCode.UsePure` | `false` | Запускать OpenCode без внешних плагинов |

---

## Требования

* Windows 10 или Windows 11, 64-битная.
* Права администратора при запуске (окно запрашивает их один раз).
* Интернет: запросы уходят к моделям в облаке. Сам API работает локально.
* .NET и OpenCode устанавливать не нужно — всё входит в архив, OpenCode ставится автоматически.

---

## Обновление

1. Скачайте новый релиз.
2. Распакуйте архив в ту же папку, согласившись на замену файлов.
3. Файл `appsettings.json` можно не заменять — в нём ваш ключ и настройки.

---

## Если что-то не работает

| Симптом | Что делать |
|---|---|
| окно просит права администратора | нажмите «Да» — это требование сборки |
| Windows SmartScreen предупреждает | «Подробнее» → «Выполнить в любом случае» |
| программа не видит API | проверьте адрес: именно `http://127.0.0.1:4891/v1`, ключ с префиксом `Bearer` |
| «порт занят» | в `appsettings.json` поменяйте `Urls` на другой порт (например `4892`) и нажмите «Рестарт» |
| «OpenCode не найден» | откройте «Настройки» → «Скачать OpenCode» |
| ответ приходит одним куском при `stream: true` | клиент не читает SSE — проверьте, что поток разбирается построчно |
| нужен ключ заново | удалите `appsettings.json` и запустите `generate-key.ps1` |

Полезно посмотреть в окне страницу **«Логи»** — там живые записи сервиса.

---

## Безопасность и приватность

* Сервер слушает `127.0.0.1` — доступен только на вашем компьютере. Из локальной сети и из
  интернета он недоступен, если вы сами не измените адрес на `0.0.0.0`.
* Ключ создаётся на вашем компьютере и хранится локально, в `appsettings.json`.
* Никаких данных о вас на сторонние серверы не отправляется, кроме самих запросов к модели.
* Мостик — прослойка. Он использует OpenCode и доступные в нём бесплатные модели; условия
  использования OpenCode и моделей остаются на вашей ответственности.

---

## English (short)

**Mostik is a local OpenAI-compatible API for Windows.** It runs on `http://127.0.0.1:4891/v1`
and serves free models through [OpenCode](https://github.com/sst/opencode) — no subscription needed.

1. Download `Mostik-win64.zip` from [Releases](../../releases/latest) and unpack it anywhere.
2. Run `Запустить Мостик.cmd` (Start Mostik).
3. Copy **Base URL** and **API key** from the window, then point your app to them.

```python
from openai import OpenAI
client = OpenAI(base_url="http://127.0.0.1:4891/v1", api_key="YOUR_KEY")
print(client.chat.completions.create(
    model="big-pickle", messages=[{"role": "user", "content": "hello"}]
).choices[0].message.content)
```

Everything included — no .NET install, OpenCode is downloaded automatically if missing.
Streaming, tool calling and OpenAI error format are supported. Package is self-contained and portable.

---

## Лицензия

MIT — см. [`LICENSE`](LICENSE). Пользуйтесь, встраивайте, изучайте.
