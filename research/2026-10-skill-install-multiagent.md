---
created: 2026-10-20
updated: 2026-10-20
summary: "Как раскладывать скилл, его хуки и прочие триггеры, чтобы он ставился, удалялся без мусора и работал у разных агентов при каноне в AGENTS.md и .agents/skills/. Статус: concluded."
---
# Установка скилла и его триггеров для нескольких агентов

- Вопрос: как раскладывать скилл, его хуки и прочие триггеры, чтобы он ставился, удалялся без мусора и работал у разных агентов при каноне в `AGENTS.md` и `.agents/skills/`.
- Статус: concluded.
- Режим исследования: глубокий `[Г]` — решение задаёт формат всех скиллов канона и их перенос между агентами.
- Агенты: Claude Code, Codex, Gemini CLI, Cursor, GitHub Copilot, Kimi Code, DeepSeek Harness, ZCode (GLM).
- Образцы: caveman, ponytail.

## Выводы

1. Папка `.agents/skills/<имя>/SKILL.md` — общий путь скиллов для большинства агентов. Codex, Gemini CLI, GitHub Copilot и Cursor читают её нативно; Claude Code — только `.claude/skills/`, нужна ссылка адаптера. Уверенность: high. Источники: [1], [2], [3], [4], [5].
	- Codex ищет `.agents/skills` от текущей папки до корня репозитория и следует по симлинкам [1].
	- Gemini CLI считает `.agents/skills/` псевдонимом `.gemini/skills/` [2].
	- Cursor дополнительно читает `.claude/skills/` и `.codex/skills/` [4].
2. `AGENTS.md` — общая точка входа. Codex, Copilot, Cursor, Amp, OpenCode читают нативно. Claude Code с v2.1.277 читает `AGENTS.md`, только когда нет `CLAUDE.md`, и не читает ничего под `.agents/`. Gemini CLI — `GEMINI.md` или `contextFileName`. Уверенность: high. Источники: [6], [7], [8].
	- Связка `CLAUDE.md` = `@AGENTS.md` остаётся рабочей и явной [6].
3. Хук не переносится одним файлом: у каждого агента своя регистрация и свои имена событий. Скрипт переносится, регистрация — нет. Уверенность: high. Источники: [9], [10], [11], [12].
	- Claude Code — `.claude/settings.json`, события `SessionStart`, `PreToolUse`, `PostToolUse`, `Stop` [9].
	- Codex — `.codex/hooks.json` или `[hooks]` в `config.toml`; та же трёхуровневая схема «событие → matcher → hooks»; включены по умолчанию; новый или изменённый хук пропускается до доверия через `/hooks` [10].
	- Gemini CLI — `.gemini/settings.json`, события `BeforeTool`, `AfterTool`, `SessionStart`; экспериментально, включается `tools.enableHooks` и `hooks.enabled` [11].
	- Cursor — `.cursor/hooks.json`, `version: 1`, события в camelCase; выставляет `CLAUDE_PROJECT_DIR` для совместимости [12].
4. Хуки во frontmatter скилла Claude Code регистрируются при вызове скилла и живут до конца сессии. Для `SessionStart` и guard до вызова не годятся. Вне Claude Code ключ `hooks` во frontmatter — ошибка. Уверенность: high. Источники: [9], [13], [3].
5. Стандарт Agent Skills разрешает во frontmatter только `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`. Рекомендует `scripts/`, `references/`, `assets/` в папке скилла и ссылки на один уровень вглубь. Уверенность: high. Источники: [3], [13].
	- `name` совпадает с именем папки, только `a-z`, `0-9`, `-`.
	- `metadata` — карта строка → строка для своих полей.
6. Готовые установщики решают удаление тремя приёмами. Уверенность: moderate. Источники: [14], [15], [16], [17].
	1. Делегирование менеджеру плагинов агента — caveman, ponytail [14], [15].
	2. Реестр владения с хэшами развёрнутых файлов — APM `deployed_files`, `deployed_file_hashes`; skills CLI `skills-lock.json` [16], [17].
	3. Блок с маркерами в общем файле (`AGENTS.md`) — caveman [14].
7. Поиск владельца по подстроке имени в `settings.json` — хрупкий: ловит чужие хуки. Уверенность: moderate. Источник: [14].
8. Делегирование плагин-менеджеру Claude Code оставляет сирот: хуки срабатывают после удаления плагина, запись в `settings.json` остаётся. Уверенность: moderate. Источник: [18].
9. Автовызов скилла по `description` ненадёжен: в эвале Vercel скилл не вызвался в 56% случаев, указатель в `AGENTS.md` дал 100%. Уверенность: moderate — один эвал, одна кодовая база. Источник: [19].
10. Разработчики агентов рекомендуют упаковывать скилл вместе с хуками в плагин — единицу установки и удаления. Уверенность: high. Источники: [15], [21], [22], [25].
	- Anthropic: «плагин — когда несколько скиллов, хуков, MCP нужны одним целым»; отдельная настройка в `.claude/` — пока она служит одному проекту [21], [22].
	- ZCode: хуки проектного уровня не исполняются вовсе, делиться хуками с командой — только плагином [25].
11. Claude Code грузит «плагин из папки скиллов»: папка `.claude/skills/<имя>/` с `.claude-plugin/plugin.json` загружается на месте, без копии и без установки, каждую сессию. Уверенность: high. Источники: [22], [23].
	- `SKILL.md` в корне папки вызывается как `/<имя>`, без префикса плагина [22].
	- `hooks/hooks.json` папки регистрируется со старта сессии — подходит для `SessionStart` и guard [15], [23].
	- `${CLAUDE_PLUGIN_ROOT}` указывает на исходную папку; скрипты — `${CLAUDE_PLUGIN_ROOT}/scripts/` [15], [23].
	- Удаление папки или `claude plugin disable <имя>@skills-dir` — плагин не грузится [22].
	- Условия: сессия запущена из корня репо, папка прошла диалог доверия; фоновые мониторы не грузятся [23].
	- Хук в `settings.json` и в `hooks/hooks.json` одновременно срабатывает дважды [22].
12. Формат плагина Claude становится общим: ZCode берёт `.claude-plugin/plugin.json` запасным манифестом и передаёт `CLAUDE_PLUGIN_ROOT`; Codex ищет `hooks/hooks.json` в плагине и передаёт `CLAUDE_PLUGIN_ROOT`; DeepSeek Harness, по вторичным данным, исполняет хуки формата Claude Code. Уверенность: moderate. Источники: [10], [24], [25], [28].
	- Codex копирует локальный плагин в кэш, а не грузит на месте [24].
13. Kimi Code читает скиллы из `.agents/skills/` и `.claude/skills/`; хуки — `[[hooks]]` в `config.toml`, бета; плагин несёт скиллы, агентов и MCP, установка плагина хуки не запускает. Уверенность: moderate. Источники: [26], [27].
14. DeepSeek Harness (`dsh`) читает `.agents/skills/` проекта; публичный API до стабильной версии, совместимость будет ломаться. Уверенность: low — в основном вторичные источники. Источник: [28].
15. GLM — официальный агент ZCode: `AGENTS.md` в корне проекта, скиллы `~/.zcode/skills/`, проектная папка скиллов не описана. Уверенность: moderate. Источники: [25], [29].
16. Образцы раскладывают пакет одинаково: общие скиллы, скрипты и файлы регистрации хуков в корне пакета, тонкий манифест на агента ссылается на них. Уверенность: moderate — 2 образца. Источники: [7], [14], [30], [31].
	- ponytail: один файл `hooks/claude-codex-hooks.json` подключают манифесты Claude и Codex; для Cursor, Copilot, Qoder — свои файлы `hooks/<агент>-hooks.json` с вызовом тех же скриптов [30].
	- Манифесты агентов — `.claude-plugin/`, `.codex-plugin/`, `.kimi-plugin/`, `.cursor-plugin/` и т.д.; Gemini — `gemini-extension.json` [30], [31].
	- Копии правил для агентов без `AGENTS.md` — `.cursor/rules/`, `.windsurf/rules/`, `.clinerules/`, `.kiro/steering/`, `.github/copilot-instructions.md`; расхождение копий ловит скрипт `check-rule-copies.js` [30].
	- caveman: профиль на агента `agents/profiles/<агент>.json`, генерация и отчёт о расхождении — `compile.mjs`, `drift-report.mjs` [31].
	- `INSTALL.md` в обоих — человеческая инструкция установки и удаления по агентам [7], [14].
17. Точки подключения, найденные в образцах и документации, — полный перечень видов. Уверенность: moderate. Источники: [9], [13], [14], [15], [30].
	1. `description` и `when_to_use` — автовызов.
	2. Указатель в `AGENTS.md` — всегда в контексте.
	3. Копия правил для агента без `AGENTS.md`.
	4. Явный вызов: `/<имя>`, `$<имя>`; командные файлы для агентов без вызова скилла — `commands/*.toml`.
	5. `paths` — автовызов по области файлов.
	6. Хук `SessionStart`, matcher `startup|resume|clear|compact` — подмешать контекст, в том числе после сжатия.
	7. Хук `UserPromptSubmit` — триггер по словам пользователя.
	8. Хук `PreToolUse` — guard до действия.
	9. Хук `PostToolUse` — проверка после правки.
	10. Хук `Stop` — напоминание до завершения.
	11. Хук `SubagentStart` — передать правила субагенту.
	12. Субагент: `agents/*.md`, предзагрузка `skills:`.
	13. MCP-сервер.
	14. Статусная строка и флаг режима.
	15. Разрешения: `allowed-tools`, `permissions` в `settings.json`.
	16. Монитор `on-skill-invoke:<скилл>`.
	17. Ссылки из других скиллов, шаблонов, планов.
	18. Зависимости машины: `gh`, `node` и т.п.
	19. Состояние вне репо: `~/.config/<имя>/`, флаги режима — чистится при удалении.
	20. Проверка расхождения копий и регистраций.

---

## Спорное

- Польза контекстных файлов: Vercel — `AGENTS.md` лучше скиллов [19]; ETH Zurich — контекстные файлы снижают успех задач (по вторичному пересказу, первоисточник не открыт).
- Приоритет `.agents/skills/` над `.gemini/skills/` внутри одного уровня — одно сообщество, в официальных доках нет.

---

## Пробелы

- Copilot CLI: формат хуков проектного уровня не проверен.
- Codex: поведение вложенных папок в `.agents/skills/` (например, `temp/<имя>/SKILL.md`) не проверено.
- Gemini CLI: чтение `AGENTS.md` без `contextFileName` не проверено.
- Claude Code: загрузка плагина из папки скиллов через junction не проверена.
- Kimi Code: имя манифеста плагина — `plugin.json` или `kimi.plugin.json`, источники расходятся.
- DeepSeek Harness: пути скиллов и мост хуков подтверждены только вторичными обзорами.
- ZCode: проектная папка скиллов в документации не описана.

---

## Практические выводы

1. Канон скиллов остаётся в `.agents/skills/`: это путь Codex, Gemini CLI, Copilot, Cursor, Kimi Code, DeepSeek Harness. Адаптер нужен Claude Code — ссылка `.claude/skills` уже есть.
2. Скилл с хуками оформляется плагином из папки скиллов: `.claude-plugin/plugin.json`, `hooks/hooks.json`, `scripts/` рядом с `SKILL.md`. Сам `SKILL.md` про хуки не знает.
3. Скрипт хука — в `scripts/` папки скилла, вызов — через `${CLAUDE_PLUGIN_ROOT}`. Путь в команде сам указывает на владельца.
4. Удаление папки скилла снимает скилл и его хуки Claude Code одним действием.
5. Остаются точки вне папки: указатель в `AGENTS.md`, разрешения, регистрация хуков у агентов без плагинов из папки скиллов (Codex `.codex/hooks.json`, Kimi `config.toml`). Их список нужен в одном месте внутри папки скилла.
6. Указатель в `AGENTS.md` ссылается на путь `SKILL.md` — `grep` по пути находит его при удалении.
7. Блок в общем файле, если нужен, — с маркерами начала и конца, а не поиск по имени.
8. Хуки во frontmatter скилла — не канал установки: только Claude Code и только после вызова.
9. Перед внедрением — проверка запуском: плагин из папки скиллов через junction `.claude/skills` → `.agents/skills`.
10. Рекомендуемая раскладка папки скилла — по образцу ponytail, сжатая до одного скилла:
	- `SKILL.md` — инструкция, все агенты.
	- `TEMPLATE.md`, `SOURCE.md` — как сейчас.
	- `INSTALL.md` — все точки подключения скилла: что, где, зачем, как снять.
	- `scripts/` — скрипты хуков и проверок, POSIX `sh`.
	- `hooks/hooks.json` — регистрация хуков: Claude Code из папки скиллов; схема совпадает с Codex.
	- `hooks/<агент>-hooks.json` — только для агента со своей схемой, когда заведён его адаптер.
	- `.claude-plugin/plugin.json` — делает папку плагином Claude Code.
	- `.<агент>-plugin/plugin.json` — только когда заведён адаптер агента.
11. Скрипт находит свою папку через `$(dirname "$0")`, корень проекта — через `CLAUDE_PROJECT_DIR`, иначе `git rev-parse --show-toplevel`. Так один скрипт работает у Claude, Codex, Cursor.
12. Обязательный минимум скилла — `description` и указатель в `AGENTS.md`. Остальные точки из вывода 17 — по применимости к скиллу.

---

## Карта классов

| Класс | Найдено | Отброшено | Включено | Причина |
|---|---|---|---|---|
| Официальная документация | 9 | 0 | 9 | Claude Code, Codex, Gemini CLI, Cursor, Copilot, Agent Skills |
| Первичные артефакты продукта | 4 | 0 | 4 | README и INSTALL.md caveman, ponytail, APM, dotagents |
| Трекеры задач | 9 | 6 | 3 | баги Claude Code: сироты плагинов, junction, `.agents/skills` |
| Кейсы и эвалы | 2 | 1 | 1 | Vercel; ETH Zurich — только вторичный пересказ |
| Блоги и агрегаторы | 12 | 10 | 2 | только как контекст и для дат |

---

## Непокрытое

- Научные — тема прикладная, рецензируемых работ по установке скиллов нет.
- Русскоязычные — запрос по Habr не дал релевантного.
- Windsurf, Cline, Kiro — нет в планах пользователя.

---

## Оценка гипотез

- A — свой нейтральный файл установки на скилл плюс регистрация в `settings.json` адаптера.
- B — плагин через маркетплейс: установка в кэш менеджером плагинов агента.
- C — хуки во frontmatter скилла.
- D — плагин из папки скиллов: манифест и `hooks/hooks.json` в папке скилла, грузится на месте.
- Нулевая — нормализация не нужна, достаточно `owner:` в шапке скрипта.

| Свидетельство (вес) | A | B | C | D | Нулевая |
|---|---|---|---|---|---|
| Регистрация хуков у агентов разная [9]–[12] (9) | C | C | N | C | нейтрально |
| Frontmatter-хуки живут после вызова, вне Claude — ошибка [9], [3] (9) | C | нейтрально | N | C | нейтрально |
| Сироты после удаления плагина из маркетплейса [18] (5) | C | N | нейтрально | нейтрально | нейтрально |
| Копия в кэше: правка канона не видна до обновления [23], [24] (9) | C | N | C | C | C |
| `owner:` нельзя поставить в JSON и в `AGENTS.md` (8) | C | нейтрально | нейтрально | C | N |
| Разработчики рекомендуют плагин для скилла с хуками [21], [22], [25] (9) | N | C | N | C | N |
| Канон нейтрален, адаптеры тонкие — `.agents/AGENTS.md` (10) | C | N | N | частично: манифест Claude в каноне | C |

- Сильнейшая — D: одна частичная несовместимость с нормой канона.
- A — вторая: расходится с рекомендацией разработчиков агентов.
- Точка хрупкости: загрузка плагина из папки скиллов через junction `.claude/skills` → `.agents/skills` не проверена. Не заработает — D сводится к A.

---

## Противоречия

- Справочник `.agents/skills/ai-agent-connect/SOURCE.md`, строка Codex: «включается `[features] hooks = true`» — против официальной документации: хуки включены по умолчанию, `hooks = false` выключает [10]. Характер — разные периоды. Не исправлено, вынесено пользователю.
- `.agents/AGENTS.md`: «Скрипты — `.agents/scripts/<имя>.sh`» — против рекомендации стандарта `scripts/` в папке скилла [3]. Характер — разные школы. Решение — за пользователем.

---

## Источники

| № | Источник | Организация | Дата | Класс | Вес | SIFT |
|---|---|---|---|---|---|---|
| 1 | [Codex — Build skills](https://learn.chatgpt.com/docs/build-skills.md) | OpenAI | обращение 2026-10-20 | официальная документация | 9 | пройдена |
| 2 | [Gemini CLI — Agent Skills](https://geminicli.com/docs/cli/skills/) | Google | обращение 2026-10-20 | официальная документация | 9 | частично: через поисковую выдачу |
| 3 | [Agent Skills — Specification](https://agentskills.io/specification) | Agent Skills | обращение 2026-10-20 | стандарт | 9 | пройдена |
| 4 | [Cursor — Agent Skills](https://cursor.com/docs/skills) | Anysphere | обращение 2026-10-20 | официальная документация | 9 | частично: через поисковую выдачу |
| 5 | [GitHub — Adding agent skills](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills) | GitHub | обращение 2026-10-20 | официальная документация | 9 | частично: через поисковую выдачу |
| 6 | [Claude Code — Memory, AGENTS.md](https://code.claude.com/docs/en/memory) | Anthropic | обращение 2026-10-20 | официальная документация | 9 | пройдена |
| 7 | [ponytail — INSTALL.md](https://github.com/DietrichGebert/ponytail) | DietrichGebert | обращение 2026-10-20 | первичный артефакт | 6 | пройдена |
| 8 | [Issue #31005 — AGENTS.md и .agents/skills](https://github.com/anthropics/claude-code/issues/31005) | сообщество Claude Code | 2025–2026 | трекер задач | 5 | частично |
| 9 | [Claude Code — Hooks](https://code.claude.com/docs/en/hooks) | Anthropic | обращение 2026-10-20 | официальная документация | 9 | пройдена |
| 10 | [Codex — Hooks](https://learn.chatgpt.com/docs/hooks) | OpenAI | обращение 2026-10-20 | официальная документация | 9 | пройдена |
| 11 | [Gemini CLI — Hooks reference](https://geminicli.com/docs/hooks/reference/) | Google | обращение 2026-10-20 | официальная документация | 9 | частично: через поисковую выдачу |
| 12 | [Cursor — Hooks](https://cursor.com/docs/agent/hooks) | Anysphere | обращение 2026-10-20 | официальная документация | 9 | пройдена |
| 13 | [Claude Code — Skills](https://code.claude.com/docs/en/skills) | Anthropic | обращение 2026-10-20 | официальная документация | 9 | пройдена |
| 14 | [caveman — INSTALL.md](https://raw.githubusercontent.com/JuliusBrussee/caveman/main/INSTALL.md) | JuliusBrussee | обращение 2026-10-20 | первичный артефакт | 6 | пройдена |
| 15 | [Claude Code — Plugins reference](https://code.claude.com/docs/en/plugins-reference) | Anthropic | обращение 2026-10-20 | официальная документация | 9 | пройдена |
| 16 | [APM — docs](https://microsoft.github.io/apm/llms-full.txt) | Microsoft | обращение 2026-10-20 | первичный артефакт | 7 | пройдена |
| 17 | [dotagents](https://github.com/bcanfield/dotagents) | bcanfield | обращение 2026-10-20 | первичный артефакт | 4 | частично |
| 18 | [Orphaned plugin hooks persist](https://claudeissues.com/issue/21836-bug-orphaned-plugin-hooks-persist-after-plugin-removal-cannot-delete-via-hooks-u) | сообщество Claude Code | 2026 | трекер задач, негативный кейс | 5 | частично: зеркало трекера |
| 19 | [AGENTS.md outperforms skills](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals) | Vercel | 2026-01-27 | кейс, эвал | 6 | частично |
| 21 | [Claude Code — Plugins overview](https://code.claude.com/docs/en/plugins) | Anthropic | обращение 2026-10-20 | официальная документация | 9 | пройдена |
| 22 | [Claude Code — Create a plugin](https://code.claude.com/docs/en/plugins/create) | Anthropic | обращение 2026-10-20 | официальная документация | 9 | пройдена |
| 23 | [Claude Code — Plugin loading reference](https://code.claude.com/docs/en/plugins/loading) | Anthropic | обращение 2026-10-20 | официальная документация | 9 | пройдена |
| 24 | [OpenAI — Build plugins](https://developers.openai.com/plugins/build/plugins) | OpenAI | обращение 2026-10-20 | официальная документация | 9 | пройдена |
| 25 | [ZCode — Hooks](https://zcode.z.ai/en/docs/hooks) | Z.ai | обращение 2026-10-20 | официальная документация | 8 | пройдена |
| 26 | [Kimi CLI — Agent Skills](https://moonshotai.github.io/kimi-cli/en/customization/skills.html) | Moonshot AI | обращение 2026-10-20 | официальная документация | 8 | пройдена |
| 27 | [Kimi Code — Plugins](https://moonshotai.github.io/kimi-code/en/customization/plugins.html) | Moonshot AI | обращение 2026-10-20 | официальная документация | 8 | частично: через поисковую выдачу |
| 28 | [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) | DeepSeek | обращение 2026-10-20 | первичный артефакт; детали — вторичные обзоры | 5 | частично |
| 29 | [ZCode — Skill](https://zcode.z.ai/en/docs/skill) | Z.ai | обращение 2026-10-20 | официальная документация | 8 | пройдена |
| 30 | [ponytail — дерево репозитория, `hooks/claude-codex-hooks.json`, `.claude-plugin/plugin.json`](https://github.com/DietrichGebert/ponytail) | DietrichGebert | обращение 2026-10-20 | первичный артефакт | 6 | пройдена |
| 31 | [caveman — дерево репозитория](https://github.com/JuliusBrussee/caveman) | JuliusBrussee | обращение 2026-10-20 | первичный артефакт | 6 | пройдена |
| 20 | [Junction skills not resolved at start](https://claudeissues.com/issue/41177-skills-in-claude-skills-via-directory-junctions-not-resolved-at-session-start-wi) | сообщество Claude Code | 2026 | трекер задач, негативный кейс | 4 | частично: зеркало трекера |

---

## Реестр искажений

- Подтверждения — проверено: гипотеза C и нулевая проверены на несовместимость.
- Авторитета — проверено: официальные доки сверены с поведением из трекеров.
- Свежести — риск остаётся: форматы хуков и путей меняются от версии к версии.
- Доступности — проверено: взяты официальные доки, а не первые блоги.
- Выжившего — риск остаётся: известны удачные установщики, провальные почти не описаны.
- Монокультура источников — проверено: 5 агентов, 4 установщика, трекеры.
- Англо-центризм — риск остаётся: русскоязычных источников нет.
- Удовлетворительного минимума — риск остаётся: Copilot CLI и Gemini CLI сверены через выдачу, не страницей.

---

## Сводка качества

- Покрытие: официальные доки 5 агентов и стандарта, 4 установщика, негативные кейсы.
- Доказательность: ключевые выводы 1–5 — официальная документация; 6–9 — первичные артефакты и трекеры.
- Разнообразие: США; сторонники и критики скиллов; текущее состояние на 2026-10.

---

## Лог запросов

| Дата | Запрос | Найдено нового |
|---|---|---|
| 2026-10-20 | caveman README, INSTALL.md | установка и удаление по агентам, маркеры, реестр владения |
| 2026-10-20 | ponytail README, INSTALL.md | делегирование плагин-менеджерам, список агентов с `AGENTS.md` |
| 2026-10-20 | agentskills.io SKILL.md open standard specification | поля frontmatter, `scripts/` |
| 2026-10-20 | Codex skills `.agents/skills` | пути Codex, симлинки, `agents/openai.yaml` |
| 2026-10-20 | Gemini CLI agent skills `.agents/skills` | псевдоним `.agents/skills/` |
| 2026-10-20 | GitHub Copilot agent skills locations | `.github/skills`, `.claude/skills`, `.agents/skills` |
| 2026-10-20 | Cursor agent skills directories | `.agents/skills`, совместимость с `.claude/skills` |
| 2026-10-20 | Claude Code skills `.agents/skills` AGENTS.md native | `AGENTS.md` с v2.1.277, `.agents/skills` нет |
| 2026-10-20 | Claude Code skill frontmatter hooks | хуки скилла после вызова |
| 2026-10-20 | Codex hooks.json SessionStart | схема Codex, доверие `/hooks` |
| 2026-10-20 | Microsoft APM | `deployed_files`, матрица целей |
| 2026-10-20 | vercel skills CLI lock file | `skills-lock.json`, симлинки на канон |
| 2026-10-20 | Gemini CLI hooks | события `BeforeTool`, флаги |
| 2026-10-20 | Vercel eval AGENTS.md vs skills | 56% невызовов |
| 2026-10-20 | orphaned hooks after uninstall | сироты плагинов Claude Code |
| 2026-10-20 | Claude Code skills junction Windows | баги junction |
| 2026-10-20 | Habr скиллы агентов `.agents/skills` | нового нет |
| 2026-10-20 | Cursor hooks | `.cursor/hooks.json`, `CLAUDE_PROJECT_DIR` |
| 2026-10-20 | Kimi Code CLI agent skills hooks | пути скиллов Kimi, `[[hooks]]` |
| 2026-10-20 | DeepSeek coding agent harness skills | `dsh`, `.agents/skills` |
| 2026-10-20 | Zhipu GLM coding agent CLI | ZCode |
| 2026-10-20 | ZCode docs skills hooks | проектные хуки не исполняются, плагин |
| 2026-10-20 | Claude Code plugins overview, create, loading | плагин из папки скиллов, загрузка на месте |
| 2026-10-20 | OpenAI build plugins | `.agents/plugins/marketplace.json`, копия в кэш |
| 2026-10-20 | kimi-code hooks plugins | плагины Kimi без хуков при установке |
| 2026-10-20 | deepseek-harness hooks bridge | мост хуков Claude Code, вторично |
| 2026-10-20 | GitHub API: деревья caveman и ponytail | раскладка по агентам, общий файл хуков Claude и Codex, `SubagentStart` |

---

## Доисследование

- Формат хуков проектного уровня Copilot CLI.
- Обход вложенных папок в `.agents/skills/` у Codex.
- Первоисточник исследования ETH Zurich «Evaluating AGENTS.md».

---

## Ограничения

- Сверка Gemini CLI, Copilot и части Cursor — по поисковой выдаче официальных страниц, не полным текстом.
- Поведение агентов не проверено запуском: Codex, Gemini CLI, Cursor, Copilot на машине не стоят.

---

## Актуальность

- Дата последнего запроса — 2026-10-20.
