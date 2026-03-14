# PowerShell скрипт для автоматизации ежедневных задач
# Сохраните этот файл как DailyTasks.ps1

# ==================== НАСТРОЙКИ ====================
$sourceFile = "C:\Users\Nebelung\Documents\Finance.icash"
$destinationFolder = "D:\YandexDisk\Архив\iCash\"
$torrentFolder = "C:\Users\Nebelung\Downloads" # Укажите вашу папку с торрентами
# ===================================================

Write-Host "=== Начало выполнения задач ===" -ForegroundColor Green
Write-Host "Дата и время: $(Get-Date)" -ForegroundColor Cyan

# ==================== ЗАДАЧА 1: Копирование файла iCash ====================
Write-Host "`n[Задача 1] Копирование файла Finance.icash..." -ForegroundColor Yellow

try {
    if (Test-Path $sourceFile) {
        # Создаем папку назначения, если она не существует
        if (-not (Test-Path $destinationFolder)) {
            New-Item -ItemType Directory -Path $destinationFolder -Force | Out-Null
            Write-Host "Папка назначения создана: $destinationFolder" -ForegroundColor Gray
        }
        
        # Формируем имя файла с датой для архивации
        $dateStamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
        $fileName = [System.IO.Path]::GetFileName($sourceFile)
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)
        $extension = [System.IO.Path]::GetExtension($sourceFile)
        $destinationFile = "$destinationFolder\$baseName`_$dateStamp$extension"
        
        # Копируем файл
        Copy-Item -Path $sourceFile -Destination $destinationFile -Force
        Write-Host "✓ Файл успешно скопирован: $destinationFile" -ForegroundColor Green
    } else {
        Write-Host "⚠ Исходный файл не найден: $sourceFile" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Ошибка при копировании файла: $_" -ForegroundColor Red
}

# ==================== ЗАДАЧА 2: Удаление .torrent файлов ====================
Write-Host "`n[Задача 2] Удаление файлов .torrent из $torrentFolder..." -ForegroundColor Yellow

try {
    if (Test-Path $torrentFolder) {
        # Находим все .torrent файлы
        $torrentFiles = Get-ChildItem -Path $torrentFolder -Filter "*.torrent" -File
        
        if ($torrentFiles.Count -gt 0) {
            foreach ($file in $torrentFiles) {
                Remove-Item -Path $file.FullName -Force
                Write-Host "✓ Удален: $($file.Name)" -ForegroundColor Gray
            }
            Write-Host "✓ Удалено файлов: $($torrentFiles.Count)" -ForegroundColor Green
        } else {
            Write-Host "ℹ Файлы .torrent не найдены" -ForegroundColor Cyan
        }
    } else {
        Write-Host "⚠ Папка с торрентами не найдена: $torrentFolder" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Ошибка при удалении файлов .torrent: $_" -ForegroundColor Red
}

Write-Host "`n=== Выполнение задач завершено ===" -ForegroundColor Green
Write-Host "Дата и время: $(Get-Date)" -ForegroundColor Cyan
