#!/bin/sh
# hook-md-validate.sh — PostToolUse(Write|Edit): прогоняет md-validate.sh по одному
# изменённому файлу и показывает нарушения агенту.
#
# Проверяется только сам изменённый файл, не всё дерево: иначе каждая правка
# тянет за собой чужие накопленные нарушения и хук превращается в шум.
#
# Область: .md внутри .agents/ и .claude/. Прочее пропускается без проверки.
# Формат для других расширений добавляется расширением case-блока ниже.
#
# Только POSIX sh + утилиты из состава git. jq не используется: file_path
# достаётся из JSON регуляркой, зависимостей у хука нет.
#
# Выход: 0 — нарушений нет либо файл вне области; 2 — нарушения, текст в stderr
# уходит агенту (PostToolUse не блокирует, инструмент уже отработал).

INPUT=$(cat)

FILE=$(printf '%s' "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
[ -n "$FILE" ] || exit 0

# JSON экранирует разделители пути Windows: I:\\Projects\\... → I:/Projects/...
FILE=$(printf '%s' "$FILE" | sed 's#\\\\#/#g; s#\\#/#g')

case "$FILE" in
	*.md) ;;
	*) exit 0 ;;
esac

case "$FILE" in
	*/.agents/*|*/.claude/*) ;;
	*) exit 0 ;;
esac

[ -f "$FILE" ] || exit 0

SCRIPT_DIR=$(dirname "$0")
RESULT=$(sh "$SCRIPT_DIR/md-validate.sh" "$FILE" 2>&1)

case "$RESULT" in
	OK:*) exit 0 ;;
esac

printf 'md-validate — нарушения формата в изменённом файле:\n%s\n' "$RESULT" >&2
exit 2
