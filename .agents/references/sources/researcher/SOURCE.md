---
name: researcher
description: При работе с `.agents/skills/researcher/SKILL.md`, картой источников, выбором класса источника, поиском доменных точек входа, аудитом баланса подборки.
---

## Содержание

- [[#Содержание]]
- [[#Назначение]]
- [[#Условия]]
- [[#Правила]]
- [[#Форматы]]
- [[#Расширенные классы источников]]
- [[#Каталог доменных источников]]
- [[#Слои знания]]
- [[#Формулировки для запросов]]

---

## Назначение

- Даёт точки входа по классам источников и по доменам.
- На выходе — стартовый набор площадок для шага 2 «Карта источников».
- Сокращает время до первой релевантной находки: перечень площадок не изобретается заново.
- Даёт формулировки, которыми поднимается знание, не записанное в гайдах и инструкциях: оно даёт преимущество перед равными и перед экспертами.
- Ломается на домене, которого нет в каталоге: экосистема определяется методом «2.3. Автоопределение экосистемы».
- **Не:**
	- Перечисляет все источники: это точки входа, не предел.
	- Заменяет верификацию: вес и проверенность считаются отдельно.

[[#Содержание|↑ Назад]]

---

## Условия

- Спорные случаи не решать самому. Явно сообщить!
- Применяется на шаге 2 «Карта источников».
- Применяется при аудите баланса подборки.
- Условие наступило, если режим исследования стандартный или глубокий.
- **Не:**
	- Применяется в быстром режиме: справочники в нём не читаются.

[[#Содержание|↑ Назад]]

---

## Правила

Применять сразу. Если дальнейшими инструкциями или пользователем не указано иное.

- Любое несоответствие правилам не исправляется. Явно сообщить!
- Брать раздел по теме исследования.
- Определять источники методом «2.3. Автоопределение экосистемы», если домена или класса в таблицах нет.
- Прогонять каждый взятый источник через «3.4. Верификация SIFT».
- Присваивать вес по «3.3. Вес источника».
- Заполнять колонку «Применимость» при аудите баланса: да, нет или частично.
- Предлагать дополнение каталога пользователем отдельно, после исследования.
- Подставлять формулировки из таблицы в запросы на шагах «4.2. Десять типов запросов» и «4.3. Охота за неочевидным».
- Переформулировать запрос синонимом из той же группы, если выдача не даёт нового.
- Фиксировать найденное по слою «Асоциальное» как знание, без применения.

[[#Содержание|↑ Назад]]

---

## Форматы

Применять сразу. Если дальнейшими инструкциями или пользователем не указано иное.

- `.md` документов:
	- `.agents/rules/md-doc/RULE.md`
- Текстов:
	- `.agents/rules/ai-output/RULE.md`

[[#Содержание|↑ Назад]]

---

## Расширенные классы источников

| Класс                             | Роль       | Примеры                                                                                                     | Когда применять                 | Применимость |
| --------------------------------- | ---------- | ----------------------------------------------------------------------------------------------------------- | ------------------------------- | ------------ |
| Профессиональные ассоциации       | сообщество | IGDA, отраслевые союзы                                                                                      | тема про практику отрасли       |              |
| Конференции                       | первичный  | доклады, сборники трудов (proceedings), панели                                                              | нужен передний край             |              |
| Исследовательские институты       | первичный  | RAND, Brookings, McKinsey Global Institute, OECD, World Bank, NBER                                          | нужен обзор с методологией      |              |
| Аналитические агентства           | агрегатор  | Gartner, Forrester, IDC, Statista, CB Insights                                                              | нужен рынок и прогноз           |              |
| Научные журналы Q1/Q2             | первичный  | Scopus, Web of Science, SCImago                                                                             | нужен рецензируемый результат   |              |
| Открытые научные индексы          | индекс     | OpenAlex, Crossref, DOAJ, Zenodo, OSF, CORE, PubMed Central                                                 | нужен полный охват публикаций   |              |
| Отзывы публикаций                 | индекс     | Retraction Watch, уведомления издателей                                                                     | проверка научного источника     |              |
| Диссертации                       | первичный  | ProQuest, EThOS, РГБ, eLibrary                                                                              | тема узкая, статей мало         |              |
| Патенты                           | первичный  | Google Patents, WIPO, USPTO, EPO                                                                            | нужен технический задел         |              |
| Стандарты                         | первичный  | ISO, IEC, NIST, ГОСТ, RFC, OWASP                                                                            | тема нормируется                |              |
| Официальная статистика            | первичный  | Росстат, ЕМИСС (fedstat.ru), Eurostat, OECD Data, World Bank Data, UNdata, IMF Data                         | нужны числа                     |              |
| Право и регулирование             | первичный  | pravo.gov.ru, EUR-Lex, govinfo, картотека арбитражных дел                                                   | тема про право                  |              |
| Безопасность и уязвимости         | индекс     | NVD, OSV (osv.dev), GitHub Advisory Database, CISA KEV, MITRE ATT&CK                                        | тема про риски и защиту         |              |
| Первичные артефакты продукта      | первичный  | заметки о выпуске, changelog, трекеры задач, реестры пакетов (npm, PyPI, crates.io), постмортемы инцидентов | нужен факт о поведении продукта |              |
| Отраслевые отчёты                 | агрегатор  | серии «State of …»                                                                                          | нужен срез практики             |              |
| Серая литература                  | первичный  | препринты, отчёты, внутренние документы                                                                     | официальных данных мало         |              |
| Архивы                            | индекс     | Archive.org, Wayback Machine                                                                                | источник изменился или исчез    |              |
| Государственные реестры и закупки | первичный  | реестры юридических лиц, порталы закупок                                                                    | нужен факт о субъекте           |              |

[[#Содержание|↑ Назад]]

---

## Каталог доменных источников

| Домен                           | Первичные источники                                                                    | Индексы и агрегаторы                                                 | Сообщества и медиа                                                                   |
| ------------------------------- | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| IT и разработка                 | документация AWS, Google Cloud, Microsoft Learn, заметки о выпуске, трекеры задач, RFC | ACM DL, IEEE Xplore, Thoughtworks Tech Radar, CNCF                   | GitHub, Stack Overflow, Hacker News, Habr, InfoQ, Martin Fowler                      |
| AI и ML                         | OpenAI, Anthropic, Google DeepMind, arXiv (cs.LG, cs.CL)                               | Papers With Code, Hugging Face, труды NeurIPS, ICML, ICLR            | LessWrong, Alignment Forum                                                           |
| Product Management              | —                                                                                      | Reforge, Product School                                              | Lenny's Newsletter, Mind the Product, Product Coalition                              |
| Маркетинг                       | —                                                                                      | Ahrefs, Semrush, CXL                                                 | HubSpot, Neil Patel, Demand Curve, Marketing Examples                                |
| Продажи                         | Salesforce Research                                                                    | Gong                                                                 | HubSpot Blog, Winning by Design, Pavilion                                            |
| HR и управление людьми          | SHRM, Gallup Workplace                                                                 | McKinsey People & Org, HeadHunter Research (RU)                      | Josh Bersin                                                                          |
| Финансы                         | регуляторы SEC и ЦБ РФ, отчётность эмитентов                                           | Bloomberg, Cbonds (RU), CFA Institute                                | FT, McKinsey CFO                                                                     |
| Право                           | pravo.gov.ru, EUR-Lex, govinfo, обзоры ВС РФ, картотека арбитражных дел                | Westlaw, LexisNexis, КонсультантПлюс (RU), Гарант (RU)               | —                                                                                    |
| Образование                     | ERIC                                                                                   | Higher Ed Dive                                                       | EdSurge, ResearchGate Education                                                      |
| Сообщества и community building | —                                                                                      | CMX Hub, Orbit                                                       | FeverBee, Community Club, Led by Community                                           |
| Мероприятия                     | —                                                                                      | MPI, PCMA                                                            | EventMB, Event Manager Blog                                                          |
| Публичные выступления           | National Communication Association, Speech Communication Association                   | TED Research                                                         | Toastmasters International                                                           |
| Game Dev                        | Steamworks Docs, документация Unreal и Unity, постмортемы разработчиков                | GDC Vault, SteamDB, Newzoo, Video Game Insights (Sensor Tower), IGDA | Game Developer (ранее Gamasutra), 80.lvl, DTF (RU), Habr, itch.io devlogs, r/gamedev |

[[#Содержание|↑ Назад]]

---

## Слои знания

| Слой | Признак | Что даёт |
|---|---|---|
| Экспертное | Знакомо практикующим специалистам. В гайдах и инструкциях явно не записано, понятно при объяснении. | Существенное преимущество перед равными. |
| Неочевидное | Узкоспециализированное, скрытое или редко встречающееся. Большинство не знает, включая специалистов в теме. | Преимущество перед экспертами. |
| Асоциальное | Обход социальных, кодовых и других ограничений системы. Применение бывает незаконным, неэтичным или даёт нечестное преимущество. | Фиксируется как знание, не для использования. |

[[#Содержание|↑ Назад]]

---

## Формулировки для запросов

| Слой | Группа | Формулировки |
|---|---|---|
| Экспертное | Советы (Tips) | Efficiency hacks, Fast wins, Hints, Lifehacks, Pro-level tips, Quick wins, Shortcuts, Tricks |
| Экспертное | Оптимизация (Optimizations) | Loss minimization tactics, Low-friction methods, Process improvements, Quality-savers, Resource management, Resources-savers, Smart defaults |
| Экспертное | Экономия времени (Time-savers) | Fast-track strategies, Productivity boosts, Speedruns |
| Экспертное | Обходные пути (Workarounds) | Alternative methods, Creative uses, Edge-case solutions |
| Экспертное | Скрытые возможности (Hidden features) | Power-user features |
| Неочевидное | Инсайдерское знание (Insider knowledge) | Advanced tips, Behavioral nudges, Expert-only shortcuts, Insider tricks, Little-known tricks, Secret receipts, Subtle cues, Unspoken rules |
| Неочевидное | Лазейки (Loopholes) | Backdoor methods, Bypass routes, Grey area tactics, Growth hacks, Indirect paths, Non-standard techniques, Stealth tactics, Unintended uses |
| Неочевидное | Стратегии на случай сбоев (Contingency strategies) | Contingency tactics, Damage control, Fallback methods, Risk tactics |
| Неочевидное | Слепые зоны (Blind spots) | Hidden opportunities, Implicit assumptions, Non-obvious opportunities, Overlooked features, Undiscovered methods |
| Неочевидное | Скрытые механики (Hidden mechanics) | Ghost features, Hidden flags, Implicit mechanics, Shadow processes, Under-the-hood tweaks, Undocumented features |
| Неочевидное | Незадокументированное поведение (Undocumented behavior) | Bugs, Contextual triggers, Corner cases, Quirks (Engine, Platform, Profession), Side effects, Underdocumented behavior |
| Асоциальное | Тёмные паттерны: обман и подмена (Deception) | Bait-and-switch, Deceptive UX, Privacy zuckering, Scam patterns, Sneaky redirects |
| Асоциальное | Тёмные паттерны: принуждение (Forced action) | Forced action, Forced continuity, Forced subscriptions, Friction traps, Lock-in tactics, Obstruction tactics, Roach motel |
| Асоциальное | Тёмные паттерны: ложный дефицит и срочность (Fake scarcity and urgency) | Artificial scarcity, Fake urgency |
| Асоциальное | Тёмные паттерны: перехват внимания (Attention hijacking) | Attention hijacking, Attention traps, Clickbait |
| Асоциальное | Тёмные паттерны: фальшивое соцдоказательство (Fake social proof) | Fake social proof, Friend spam |
| Асоциальное | Тёмные паттерны: давление и манипуляция (Pressure and manipulation) | Exploitative flows, Manipulative tactics, Pressure tactics |
| Асоциальное | Тёмные паттерны: стыд и вина (Shame and guilt) | Confirmshaming, Guilt-tripping |
| Асоциальное | Тёмные паттерны: конверсия и удержание (Conversion and retention) | Conversion tricks, Retention tricks |
| Асоциальное | Технические эксплойты (Exploits) | Abuse vectors, Cheat codes, Glitches, Hacks, Hacky solutions |

[[#Содержание|↑ Назад]]
