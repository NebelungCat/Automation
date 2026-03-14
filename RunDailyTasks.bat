@echo off
REM BAT-файл для запуска PowerShell скрипта с обходом политики выполнения
REM Сохраните этот файл как RunDailyTasks.bat

REM Запуск PowerShell скрипта с bypass политикой выполнения
PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0DailyTasks.ps1"

REM Пауза чтобы увидеть результат (можно удалить при автоматизации)
pause
