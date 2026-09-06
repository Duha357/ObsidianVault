#!/bin/sh
# plsql-validate.sh — проверка файлов `.pks` и `.pkb` на соответствие
# `.agents/rules/plsql-common-text/RULE.md`.
#
# Запуск:
#   sh .agents/scripts/plsql-validate.sh <файл|директория>
#   sh .agents/scripts/plsql-validate.sh code
#
# Коды возврата: 0 — нарушений нет; 1 — нарушения найдены либо аргумент неверен.
#
# Только POSIX sh + утилиты из состава git (grep, sed, awk, find).
# Node, Python, jq не используются намеренно: один и тот же запуск на Windows
# (Git Bash) и Linux (sh). См. .agents/AGENTS.md, раздел "Правила".
#
# Проверяется механическое: отступы, имя файла, парность спецификации и тела,
# `is`/`as`, положение запятой в параметрах, `chr(10)` в генерируемом коде.
# Смысловое — именование переменных, шапки, кросс-модульные вызовы — глазами.

TARGET="$1"

if [ -z "$TARGET" ]; then
	echo "plsql-validate: не задан аргумент." >&2
	echo "Использование: sh .agents/scripts/plsql-validate.sh <файл|директория>" >&2
	exit 1
fi

if [ ! -e "$TARGET" ]; then
	echo "plsql-validate: путь не найден: $TARGET" >&2
	exit 1
fi

OUT="${TMPDIR:-/tmp}/plsql-validate.$$"
: > "$OUT"

if [ -f "$TARGET" ]; then
	FILES="$TARGET"
else
	FILES=$(find "$TARGET" \( -name "*.pks" -o -name "*.pkb" \) -not -path "*/.git/*" | sort)
fi

CHECKED=0
TAB=$(printf '\t')

for f in $FILES; do
	CHECKED=$((CHECKED + 1))
	base=$(basename "$f")
	stem=${base%.*}
	dir=$(dirname "$f")

	# Отступ табуляцией: правило требует 2 пробела на уровень.
	grep -n "^[ ]*$TAB" "$f" | while IFS= read -r hit; do
		echo "$f:${hit%%:*}: отступ табуляцией, требуется 2 пробела" >> "$OUT"
	done

	# Имя файла: не длиннее 30 символов до расширения, префикс модуля, постфикс роли.
	if [ ${#stem} -gt 30 ]; then
		echo "$f:1: имя длиннее 30 символов до расширения: $stem" >> "$OUT"
	fi
	case "$stem" in
		*_*) ;;
		*) echo "$f:1: нет префикса модуля \`{Модуль}_\`: $stem" >> "$OUT" ;;
	esac
	case "$stem" in
		*PKG|*DPI|*API) ;;
		*) echo "$f:1: нет постфикса роли PKG/DPI/API: $stem" >> "$OUT" ;;
	esac

	# Спецификация и тело лежат в одной папке. Объектные типы тела не имеют.
	if grep -qi "^[ \t]*create or replace package" "$f"; then
		case "$base" in
			*.pks) [ -f "$dir/$stem.pkb" ] || echo "$f:1: нет парного тела $stem.pkb в той же папке" >> "$OUT" ;;
			*.pkb) [ -f "$dir/$stem.pks" ] || echo "$f:1: нет парной спецификации $stem.pks в той же папке" >> "$OUT" ;;
		esac
	fi
	# Функции — `is`, процедуры — `as`. Запятая в списке параметров — в начале строки.
	# Генерируемый код начинается с `chr(10)`, а не сразу с литерала.
	awk -v F="$f" '
		{ low = tolower($0) }

		# Объявление подпрограммы: запоминаем вид и входим в список параметров.
		low ~ /^[ \t]*function[ \t]+[a-z0-9_]/ { kind = "function"; inparams = (low ~ /\(/) && (low !~ /\)/); }
		low ~ /^[ \t]*procedure[ \t]+[a-z0-9_]/ { kind = "procedure"; inparams = (low ~ /\(/) && (low !~ /\)/); }

		inparams && low ~ /,[ \t]*$/ { print F ":" NR ": запятая в конце строки параметра, требуется в начале" }
		inparams && low ~ /\)/ { inparams = 0 }

		# Ключевое слово тела подпрограммы.
		kind != "" && low ~ /^[ \t]*(is|as)[ \t]*$/ {
			kw = low; sub(/^[ \t]*/, "", kw); sub(/[ \t]*$/, "", kw)
			if (kind == "function" && kw == "as") print F ":" NR ": процедурное `as` у функции, требуется `is`"
			if (kind == "procedure" && kw == "is") print F ":" NR ": функциональное `is` у процедуры, требуется `as`"
			kind = ""
		}

		# Генерируемый код: литерал сразу после присваивания, без ведущего chr(10).
		low ~ /:=[ \t]*'"'"'[ \t]*(begin|declare)\>/ { print F ":" NR ": генерируемый код начинается с литерала, требуется chr(10) первым слагаемым" }
	' "$f" >> "$OUT"
done

VIOLATIONS=$(wc -l < "$OUT" | tr -d ' ')

if [ "$VIOLATIONS" -eq 0 ]; then
	rm -f "$OUT"
	echo "OK: $CHECKED файлов"
	exit 0
fi

sort "$OUT"
rm -f "$OUT"
echo "НАРУШЕНИЙ: $VIOLATIONS, файлов проверено: $CHECKED" >&2
exit 1
