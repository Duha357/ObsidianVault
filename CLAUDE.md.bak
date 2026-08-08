@AGENTS.md
# Claude-механика

Всё общее — ожидаемые инструкции от текущего файла — в `AGENTS.md` (импортирован выше). Здесь только механика Claude Code.

## Правила

- Канон — `.agents/*`
- Все `.claude` файлы, обнаруживаются через junctions:
	- `.claude/skills` → `.agents/skills`
	- `.claude/rules` → `.agents/rules`
- Создание/Изменения/Удаления, предназначенные для `.claude/*`, делать в `.agents/*`
- Разрешения/Ограничения для `.claude/*`, работают для `.agents/*`
- Через junction, `.claude/*` и `.agents/*`, это одни и те же файлы. Но работаем, только с `.agents/*`