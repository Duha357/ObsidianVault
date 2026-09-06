---
name: plsql-common-text
description: При работе с правилом формата PL/SQL, шаблоном пакета, шапкой функции или процедуры, генерацией кода строкой, сомнением в оформлении файла `.pks` или `.pkb`.
owner: .agents/rules/plsql-common-text/RULE.md
---

## Правила

После открытия текущего документа — прочитай и постоянно применяй при работе с целевой сущностью! Если дальнейшими инструкциями или пользователем не указано иное.

- Текущий `## Правила` наследует все `## Правила` в `AGENTS.md` уровнем выше в папочной иерархии текущего проекта.
- Любое несоответствие целевой сущности текущего документа, разделам текущего документа и (если есть) разделам унаследованным текущим документом — не исправлять. Явно сообщить!
- Спорные случаи не решать самому. Явно сообщить! Предложить варианты решения.
- Перед выдачей проверять соответствие разделам текущего документа и (если есть) разделам унаследованным текущим документом.
- Сверять оформление с ближайшим образцом, при расхождении образца и правила — с правилом.
- Держать образцы парами: плохо и хорошо на один случай.
- Добавлять новый случай парой, не одиночным примером.
- **Не:**
	- Дублировать унаследованные правила в текущем разделе `## Правила`.
- **Исключение:**
	- Заданные эталоном `## Правила` дублировать допускается.

---

## Эталоны

Пакет, файл заголовок:

```sql
create or replace package {Замена. Имя пакета.}
/**
* @package {Замена. Путь пакета в документации. По умолчанию: название модуля. Всегда уточняется.}
* {Замена. Описание пакета.}
*/
is

  {Замена. Глобальные переменные.}

{Замена. Функции и процедуры.}

end {Замена. Имя пакета.};
```

Пакет, файл тело:

```sql
create or replace package body {Замена. Имя пакета.}
is

{Замена. Функции и процедуры.}

begin
  -- Initialization
  null;
end {Замена. Имя пакета.};
```

Функция:

```sql
--====================================================================
-- {Замена. Уровень доступа.}
-- Purpose: {Замена. Описание.}
{Замена. Блок `-- Important: `. Если требуется.}
--====================================================================
  function {Замена. Имя функции.}(
    {Замена. Параметры функции. Запятая в начале.}
  ) return {Замена. Тип возвращаемого значения.}
  is
    {Замена. Локальные переменные.}
    {Замена. Локальные функции и процедуры.}
  begin
    {Замена. Определение функции.}
  end;
```

Процедура:

```sql
--====================================================================
-- {Замена. Уровень доступа.}
-- Purpose: {Замена. Описание.}
{Замена. Блок `-- Important: `. Если требуется.}
--====================================================================
  procedure {Замена. Имя процедуры.}(
    {Замена. Параметры процедуры. Запятая в начале.}
  )
  as
    {Замена. Локальные переменные.}
    {Замена. Локальные функции и процедуры.}
  begin
    {Замена. Определение процедуры.}
  end;
```

---

## Примеры: плохо

Вложенность:

```sql
  function GetName(
    idpDocument in number
  ) return varchar2
  is
        result varchar2(100);
  begin
        result := DOC_DocumentAPI.GetName(idpDocument);
        return result;
  end;
```

Ключевое слово тела:

```sql
  function GetName(
    idpDocument in number
  ) return varchar2
  as
  begin
    return null;
  end;

  procedure SetName(
    idpDocument in number
  )
  is
  begin
    null;
  end;
```

Параметры:

```sql
  function Find(idpDocument in number, spCode in varchar2) return number
  is
  begin
    return null;
  end;

  function FindNext(
    idpDocument in number,
    spCode in varchar2
  ) return number
  is
  begin
    return null;
  end;
```

Возвращаемое значение:

```sql
  function GetName(
    idpDocument in number
  ) return varchar2
  is
    svRes varchar2(100);
  begin
    svRes := DOC_DocumentAPI.GetName(idpDocument);
    return svRes;
  end;
```

Шапка подпрограммы:

```sql
  -- Старая функция, не использовать
  function GetNameOld(
    idpDocument in number
  ) return varchar2
  is
    result varchar2(100);
  begin
    result := DOC_DocumentAPI.GetName(idpDocument);
    return result;
  end;
```

Именование переменных:

```sql
  gModule varchar2(30) := 'DOC';

  function Find(
    p_doc_id in number
  ) return number
  is
    code    varchar2(30);
    tmpDate date;
    IsFound number;
  begin
    return null;
  end;
```

Перечисление:

```sql
    type TCodes is table of varchar2(30) index by binary_integer;

    svCodes TCodes;
```

Константы:

```sql
    nvMaxSize number := 1024;
```

Новый параметр:

```sql
  function Find(
    idpDocument in number
   ,bpOnlyActive in number
   ,spCode in varchar2
  ) return number
```

Генерация кода:

```sql
    svPLSQL := 'begin'
      || chr(10)
      || '  BTS_HttpPKG.Send(:1);'
      || chr(10)
      || 'end;'
    ;
```

---

## Примеры: хорошо

Вложенность:

```sql
  function GetName(
    idpDocument in number
  ) return varchar2
  is
    result varchar2(100);
  begin
    result := DOC_DocumentAPI.GetName(idpDocument);

    return result;
  end;
```

Ключевое слово тела:

```sql
  function GetName(
    idpDocument in number
  ) return varchar2
  is
  begin
    return null;
  end;

  procedure SetName(
    idpDocument in number
  )
  as
  begin
    null;
  end;
```

Параметры:

```sql
  function Find(
    idpDocument in number
   ,spCode      in varchar2
  ) return number
  is
  begin
    return null;
  end;
```

Возвращаемое значение:

```sql
  function GetName(
    idpDocument in number
  ) return varchar2
  is
    result varchar2(100);
  begin
    result := DOC_DocumentAPI.GetName(idpDocument);

    return result;
  end;
```

Шапка подпрограммы:

```sql
--====================================================================
-- @public
-- Purpose: Имя документа по идентификатору.
-- Important: DEPRECATED!!!
-- Important: GetName не динамический — внутри хардкод.
--====================================================================
  function GetNameOld(
    idpDocument in number
  ) return varchar2
  is
    result varchar2(100);
  begin
    result := DOC_DocumentAPI.GetName(idpDocument);

    return result;
  end;
```

Именование переменных:

```sql
  sgModule varchar2(30) := 'DOC';

  function Find(
    idpDocument in number
  ) return number
  is
    svCode    varchar2(30);
    dvClosed  date;
    bvIsFound number;
  begin
    return null;
  end;
```

Перечисление:

```sql
    type TCodes is table of varchar2(30) index by binary_integer;

    savCodes TCodes;
```

Константы:

```sql
    nvMaxSize constant number := 1024;
```

Новый параметр:

```sql
  function Find(
    idpDocument  in number
   ,spCode       in varchar2
   ,bpOnlyActive in number := 0
  ) return number
```

Генерация кода:

```sql
    svPLSQL := chr(10)
      || 'begin'
      || chr(10)
      || '  BTS_HttpPKG.Send(:1);'
      || chr(10)
      || 'end;'
    ;
```
