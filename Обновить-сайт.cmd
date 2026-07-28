@echo off
chcp 65001 >nul
rem ===========================================================================
rem  Выложить свежую базу на сайт
rem
rem  Запускать после того, как:
rem    - пересобрали базу скриптом build.ps1, или
rem    - сохранили правки из админки в data\data.js
rem
rem  Админка, презентации и скрипты в репозиторий не попадают — это задано
rem  в .gitignore. Не убирайте оттуда строку admin.html.
rem ===========================================================================

setlocal
cd /d "%~dp0"

git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
  echo Здесь нет git-репозитория. Смотрите README, раздел про публикацию.
  pause & exit /b 1
)

git remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo.
  echo Не задан адрес репозитория на GitHub. Один раз выполните:
  echo    git remote add origin https://github.com/ВАШ_ЛОГИН/almaty-ooh.git
  echo.
  pause & exit /b 1
)

echo Что изменилось:
git status --short
echo.

git add -A
git diff --cached --quiet
if not errorlevel 1 (
  echo Изменений нет — публиковать нечего.
  pause & exit /b 0
)

for /f "tokens=1-3 delims=." %%a in ("%DATE%") do set "STAMP=%%a.%%b.%%c"
git commit -q -m "Обновление базы конструкций %STAMP%"
if errorlevel 1 (
  echo Не удалось сделать коммит.
  pause & exit /b 1
)

echo Отправляю на GitHub...
git push origin main
if errorlevel 1 (
  echo.
  echo Отправка не удалась. Обычные причины: не выполнен вход в GitHub
  echo или нет доступа к репозиторию.
  pause & exit /b 1
)

echo.
echo Готово. Сайт обновится через минуту-две.
pause
exit /b 0
