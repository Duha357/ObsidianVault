#!/bin/sh
# hook-plsql-validate.sh — PostToolUse(Write|Edit): прогоняет plsql-validate.sh по
# одному изменённому файлу и показывает нарушения агенту.
#
# Проверяется только сам изменённый файл, не всё дерево: иначе каждая правка
# тянет за собой чужие накопленные нарушения и хук превращается в шум.
#
# Область: `.pks` и `.pkb` в любом месте репозитория. Прочее пропускается.
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
	*.pks|*.pkb) ;;
	*) exit 0 ;;
esac

[ -f "$FILE" ] || exit 0

SCRIPT_DIR=$(dirname "$0")
RESULT=$(sh "$SCRIPT_DIR/plsql-validate.sh" "$FILE" 2>&1)

case "$RESULT" in
	OK:*) exit 0 ;;
esac

printf 'plsql-validate — нарушения формата в изменённом файле:\n%s\n' "$RESULT" >&2
exit 2
