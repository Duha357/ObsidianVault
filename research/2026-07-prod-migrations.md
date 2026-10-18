---
created: 2026-07-05
updated: 2026-07-05
summary: "Каким должен быть штатный способ накатки миграций на боевую БД и дисциплина порядка «миграция ↔ зависящий код» при общей PostgreSQL на два сервиса (EP-19). Статус: concluded."
---
# Прод-процедура миграций БД (EP-19)

Триггер: инцидент 2026-07-05 — код `gdps-backend` под `User.dEmailConfirmDate` уехал в
прод раньше, чем миграция (владелец — `gdps-backend-admin`) была применена; логин лёг 500.
Foundational-тема: миграции есть почти у всех будущих эпиков (EP-1, 3, 4, 7, 9, 10).

## Контекст (как устроено сейчас)

- Миграции: **node-pg-migrate**, живут в `gdps-backend-admin/migrations/` (тонкие `.ts`-обёртки
  над raw SQL в `migrations/sqls/`). Имена — timestamp-based.
- Владелец схемы де-факто — `gdps-backend-admin`. `gdps-backend` схему только **читает**
  (его Prisma-схема помечена read-only, legacy .NET).
- Общая одна база `GDPS` на оба бэкенда.
- Деплой каждого репо независимо: push в main → GitHub Actions → `rsync` → на сервере
  `docker compose build → down → up`. **Шага миграции в деплое нет** — катится вручную по SSH.
- Прод-образ админ-бэка: `npm prune --omit=dev` в runner-стадии → `ts-node`/`typescript`
  выпилены. `migrate:up` вызывает `--ts-node`.
- Серверный `docker-compose.yml` самого Postgres (`/root/docker/postgree`) **не версионируется** —
  правится руками на сервере.
- Команда будет расти: пушить в прод будут несколько человек (уточнение владельца 2026-07-05).

## Findings

- [high] Проблема двумерна: **(A) механизм** (как катить) и **(B) порядок** (когда относительно
  кода). Инцидент — сбой обоих: ручной механизм (забыли) + нарушенный порядок (код раньше миграции).
- [high] Корень безопасности порядка — **expand-contract (parallel change)**: изменения разбиваются
  на обратно совместимые фазы. Expand (добавить nullable-колонку/таблицу/индекс) → код переходит →
  Contract (удалить старое) только после того, как код перестал этим пользоваться. Порядок выката:
  для добавления — миграция первой, потом код; для удаления — сначала код, потом drop-миграция.
  (источники: [PlanetScale](https://planetscale.com/blog/backward-compatible-databases-changes),
  [Jasmin Fluri](https://medium.com/@jasminfluri/expand-and-contract-method-for-database-changes-414d236f236f),
  [Enol Casielles](https://www.enolcasielles.com/en/blog/database-migrations-strategy))
- [high] Правило **N/N-1**: новый код совместим со старой схемой, старый — с новой. Если так, то
  **порядок деплоя двух коммитов перестаёт быть критичным** — прямое решение жалобы владельца
  «два коммита подряд выглядят странно». (источник: PlanetScale, выше)
- [high] Наша миграция инцидента (`ADD COLUMN ... NULL`) сама по себе безопасна (expand). Сломал
  не тип изменения, а **очерёдность выката**.
- [moderate] Общая одна база на несколько сервисов — признанная «главная боль координации»:
  cutover, который в database-per-service затронул бы один сервис, требует согласованного деплоя
  нескольких. Идеал микросервисов — database-per-service, но у нас база общая **сознательно**.
  (источник: [Jared Hatfield](https://medium.com/@jaredhatfield/database-migration-patterns-6b5ede23d06e),
  [nairihar](https://nairihar.medium.com/monorepo-from-hate-to-love-97a866811ccc))
- [moderate] Вынос миграций/Postgres в **отдельный репозиторий не убирает** координацию — только
  переносит владельца и добавляет пайплайн. Дешевле — явно назначить единого владельца схемы
  (у нас уже `gdps-backend-admin`) и записать это. (источники те же)
- [high] Механизм для docker-compose (канон): **выделенный migration-сервис** с
  `condition: service_completed_successfully` либо one-off-контейнер перед стартом app; для
  свежих Compose — init-containers. (источники:
  [Alec Brunelle / DEV](https://dev.to/aleccool213/running-sql-migrations-before-booting-docker-compose-services-3d3d),
  [O's World / init-containers](https://ooo.run/en/post/docker-compose-init-containers.html))
- [high] Авто-миграции в проде несут риск → шаг обязан **падать громко и НЕ поднимать новый код**,
  если миграция провалилась. Отдельный шаг в CI/CD предпочтительнее миграции-на-старте для
  критичных сред. (источник: [notiz.dev / Prisma](https://notiz.dev/blog/prisma-migrate-deploy-with-docker/))
- [high] Командная дисциплина (несколько пушащих): (1) timestamp-порядок файлов — уже есть;
  (2) применённую миграцию **не редактируют**, только новая поверх; (3) PR-ревью для миграций,
  трогающих общие таблицы; (4) up-down-up прогон каждой миграции. node-pg-migrate берёт
  advisory-lock → защита от гонки двух параллельных деплоев. (источники:
  [ByteCrate](https://bytecrate.dev/managing-ef-core-migrations-large-teams-sql-server/),
  [JetBrains](https://blog.jetbrains.com/idea/2025/02/database-migrations-in-the-real-world/))
- [high] **ts-node-блокер**: `npm run migrate:up` в прод-контейнере не заработает —
  devDependencies выпилены `npm prune --omit=dev`, а команда использует `--ts-node`. Нужно
  компилировать миграции в JS на этапе build (или отдельный migrate-stage с devDeps). Катить
  raw SQL напрямую через `psql` — не вариант: теряется таблица учёта `pgmigrations` и advisory-lock.

## Hypotheses

- H1: Автоматический шаг миграции в `deploy.yml` админ-бэка (one-off/dedicated-сервис) — лучший
  механизм под наш стек (docker compose + Actions + слабый сервер). — **подтверждается** (канон
  для docker-compose + подтверждён выбором владельца 2026-07-05).
- H2: Дисциплина expand-contract + N/N-1 + roll-forward снимает опасность «двух коммитов» и делает
  порядок деплоя некритичным. — **подтверждается** источниками.
- H3: Отдельный репозиторий под Postgres/схему — избыточен; достаточно единого владельца схемы. —
  **подтверждается** (координация не уходит, пайплайнов больше). Требует финального решения владельца.

## Open questions

- [x] Где живёт схема-владелец → **оставить в `gdps-backend-admin`**, записать явно в ADR
      (решение владельца 2026-07-05).
- [x] Версионировать серверный `postgree/docker-compose.yml` в git → **да, в корневой репо, в рамках
      этого же плана EP-19** (решение владельца 2026-07-05).
- [ ] Реализация ts-node-блокера: компиляция миграций в JS в образе vs отдельный migrate-stage
      с devDeps. → решается в плане (деталь реализации, не блокирует ADR).
- [ ] Откат: закрепить roll-forward-only (down только для expand-фаз, без потери данных)? →
      предложение ADR, финализируется при написании ADR.
- [ ] Куда записать межрепозиторное правило порядка → `conventions.md` (чек-лист «фича с миграцией»).

## Session log

- 2026-07-05 — Открыто исследование. Собран контекст (deploy.yml обоих бэков, Dockerfile,
  migrations.md, package.json, compose админ-бэка). Найден ts-node-блокер. Проведён веб-обзор по
  4 осям: expand-contract, где живут миграции при общей БД, командный workflow, автоприменение в
  docker-compose. Владелец выбрал: автоматический механизм; оформление research-log → ADR → план.
  Уточнения владельца: пушить будут несколько человек; «два коммита подряд странны»; мысль про
  отдельный репо Postgres; всё должно быть автоматизировано при клонировании. Findings/гипотезы
  занесены. H1/H2 подтверждены, H3 подтверждена (нужно финальное решение по open questions).
- 2026-07-05 — Владелец закрыл две развилки: схема остаётся в `gdps-backend-admin`; серверный
  Postgres-compose версионируем в корневом репо в рамках EP-19. Насыщение достигнуто →
  `status: concluded`. Заполнено Conclusion. Дальше: ADR (механизм + дисциплина) → план реализации.

## Conclusion

Решение по EP-19 (для ADR и плана):

1. **Механизм (A):** штатная накатка — **автоматический шаг в `deploy.yml` `gdps-backend-admin`**
   выделенным migration-контейнером (docker compose, one-off / `service_completed_successfully`),
   между `rsync` и `up`, под тем же `concurrency`. Шаг **падает громко** и **не поднимает новый код**,
   если миграция провалилась. Ручной SSH-путь — только аварийный runbook.
2. **ts-node-блокер:** миграции компилируются в JS в образе (или отдельный migrate-stage с devDeps);
   raw SQL через `psql` не катаем (сохраняем `pgmigrations` + advisory-lock node-pg-migrate).
3. **Порядок (B):** дисциплина **expand-contract + N/N-1 + roll-forward**. Expand-миграция — до
   зависящего кода; contract (drop) — только после ухода кода; откат down — только для expand-фаз
   без потери данных. При обратной совместимости порядок двух коммитов перестаёт быть опасным.
4. **Владелец схемы:** единственный — `gdps-backend-admin` (записать явно). `gdps-backend` схему
   только читает. Отдельный репо под схему/Postgres — отклонён (координацию не убирает).
5. **Команда:** applied-миграции immutable; PR-ревью для миграций, трогающих общие таблицы;
   timestamp-порядок (уже есть); advisory-lock (уже есть).
6. **Смежное:** серверный `postgree/docker-compose.yml` завести в git (корневой репо) — сейчас
   не версионируется.
7. **Документация:** межрепо-правило порядка → чек-лист «фича с миграцией» в `conventions.md`;
   обновить `migrations.md` и раздел деплоя в `build-and-run.md`.

Рождает: **ADR** (пункты 1–5, механизм + дисциплина) и **план PLAN-2026-07-prod-migrations**
(реализация пунктов 1, 2, 6, 7).
