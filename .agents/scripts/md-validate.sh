#!/bin/sh
# md-validate.sh — проверка .md документов на соответствие форматам .agents/rules/md-*-text.
#
# Запуск:
#   sh .agents/scripts/md-validate.sh <файл|директория>
#   sh .agents/scripts/md-validate.sh --rules
#   sh .agents/scripts/md-validate.sh .agents
#
# Коды возврата: 0 — нарушений нет; 1 — нарушения найдены либо аргумент неверен.
#
# Только POSIX sh + утилиты из состава git (grep, sed, awk, find).
# Node, Python, jq не используются намеренно: один и тот же запуск на Windows
# (Git Bash) и Linux (sh). См. .agents/AGENTS.md, раздел "Правила".

TARGET="$1"

if [ -z "$TARGET" ]; then
	echo "md-validate: не задан аргумент." >&2
	echo "Использование: sh .agents/scripts/md-validate.sh <файл|директория|--rules>" >&2
	exit 1
fi

# Реестр правил: единственный источник — фронтматтеры .agents/rules/*/RULE.md.
# Раздел-дубль в .agents/AGENTS.md намеренно отсутствует, список печатается здесь.
if [ "$TARGET" = "--rules" ]; then
	ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
	for f in "$ROOT"/.agents/rules/*/RULE.md; do
		[ -e "$f" ] || continue
		fm=$(awk 'NR > 1 && /^---$/ { exit } NR > 1 { print }' "$f")
		desc=$(echo "$fm" | grep "^description:" | sed 's/^description:[[:space:]]*//')
		paths=$(echo "$fm" | awk '
			/^paths:/ { p = 1; next }
			p && /^[^[:space:]]/ { p = 0 }
			p && /^[[:space:]]*-/ { sub(/^[[:space:]]*-[[:space:]]*/, ""); gsub(/"/, ""); printf "%s%s", sep, $0; sep = " " }
		')
		[ -n "$paths" ] || paths="всегда"
		echo "${f#"$ROOT"/}"
		echo "	область: $paths"
		echo "	задаёт: $desc"
	done
	exit 0
fi

if [ ! -e "$TARGET" ]; then
	echo "md-validate: путь не найден: $TARGET" >&2
	exit 1
fi

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
OUT="${TMPDIR:-/tmp}/md-validate.$$"
: > "$OUT"

if [ -f "$TARGET" ]; then
	FILES="$TARGET"
else
	FILES=$(find "$TARGET" -name "*.md" -not -path "*/.git/*" | sort)
fi

CHECKED=0

for f in $FILES; do
	CHECKED=$((CHECKED + 1))
	base=$(basename "$f")
	dirname_only=$(basename "$(dirname "$f")")

	# Отступ списка пробелами вместо табуляции.
	# Пропускаются: YAML-фронтматтер (там пробелы обязательны) и блоки кода.
	awk -v F="$f" '
		NR == 1 && $0 == "---" { infm = 1; next }
		infm && $0 == "---" { infm = 0; next }
		infm { next }
		/^```/ { inblock = !inblock; next }
		inblock { next }
		/^ +[-*]/ || /^ +[0-9]+\./ { print F ":" NR ": отступ списка пробелами, требуется табуляция" }
	' "$f" >> "$OUT"

	# CRLF.
	if head -c 8000 "$f" | grep -q "$(printf '\r')"; then
		echo "$f:1: файл содержит CRLF, требуется LF" >> "$OUT"
	fi

	# Ссылки на пути .agents/... ведут на существующие файлы.
	# Примеры внутри блоков кода пропускаются, шаблонные пути с <> и * тоже.
	awk '
		/^```/ { inblock = !inblock; next }
		inblock { next }
		{ print NR "|" $0 }
	' "$f" | grep "\`\.agents/" | while IFS= read -r hit; do
		lineno=${hit%%|*}
		echo "$hit" | tr '`' '\n' | grep "^\.agents/" | while IFS= read -r p; do
			case "$p" in
				*"<"*|*">"*|*"*"*) continue ;;
			esac
			if [ ! -e "$ROOT/$p" ]; then
				echo "$f:$lineno: ссылка на несуществующий путь: $p" >> "$OUT"
			fi
		done
	done

	# Дальше — только документы со свойствами.
	[ "$(head -n 1 "$f")" = "---" ] || continue
	fm=$(awk 'NR > 1 && /^---$/ { exit } NR > 1 { print }' "$f")

	# description начинается с "При работе с".
	desc=$(echo "$fm" | grep "^description:" | sed 's/^description:[[:space:]]*//')
	if [ -n "$desc" ]; then
		case "$desc" in
			"При работе с"*|">"*) : ;;
			*) echo "$f:3: description не начинается с 'При работе с'" >> "$OUT" ;;
		esac
	fi

	# name совпадает с именем папки для файлов, набранных капсом.
	case "$base" in
		[A-Z]*.md)
			nm=$(echo "$fm" | grep "^name:" | sed 's/^name:[[:space:]]*//')
			if [ -n "$nm" ] && [ "$nm" != "$dirname_only" ]; then
				echo "$f:2: name '$nm' не совпадает с именем папки '$dirname_only'" >> "$OUT"
			fi
			;;
	esac
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
