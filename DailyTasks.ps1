# DailyTasks.ps1 - Скрипт автоматизации ежедневных задач (ИСПРАВЛЕННАЯ ВЕРСИЯ)
# Кодировка: UTF-8 with BOM

param(
    [string]$TorrentPath = "D:\Downloads" # ИЗМЕНИТЕ ЭТОТ ПУТЬ НА ВАШ
)

$sourceFile = "C:\Users\Nebelung\Documents\Finance.icash"
$destFolder = "d:\YandexDisk\Архив\iCash"
$logFile = "D:\Downloads\Automation-main\tasks_log.txt"

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    
    if ($Color -eq "Red") { Write-Host $logEntry -ForegroundColor Red }
    elseif ($Color -eq "Green") { Write-Host $logEntry -ForegroundColor Green }
    elseif ($Color -eq "Cyan") { Write-Host $logEntry -ForegroundColor Cyan }
    else { Write-Host $logEntry }
}

Write-Log "=== Начало выполнения задач ===" "Cyan"

# Задача 1: Копирование файла iCash
try {
    if (Test-Path $sourceFile) {
        if (-not (Test-Path $destFolder)) {
            New-Item -ItemType Directory -Force -Path $destFolder | Out-Null
            Write-Log "Папка назначения создана: $destFolder" "Green"
        }

        $dateStamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $fileName = [System.IO.Path]::GetFileName($sourceFile)
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $extension = [System.IO.Path]::GetExtension($fileName)
        $destFile = Join-Path $destFolder "${baseName}_${dateStamp}${extension}"

        Copy-Item -Path $sourceFile -Destination $destFile -Force
        Write-Log "Файл успешно скопирован: $destFile" "Green"
    } else {
        Write-Log "Исходный файл не найден: $sourceFile" "Red"
    }
} catch {
    Write-Log "Ошибка при копировании файла: $($_.Exception.Message)" "Red"
}

# Задача 2: Удаление .torrent файлов (ИСПРАВЛЕНО)
try {
    if (Test-Path $TorrentPath) {
        # Получаем список файлов
        $torrentFiles = Get-ChildItem -Path $TorrentPath -Filter "*.torrent" -File -ErrorAction SilentlyContinue
        
        if ($torrentFiles.Count -gt 0) {
            Write-Log "Найдено файлов .torrent: $($torrentFiles.Count). Начинаем удаление..." "Cyan"
            $deletedCount = 0
            
            foreach ($file in $torrentFiles) {
                try {
                    # ИСПОЛЬЗУЕМ -LiteralPath для корректной обработки спецсимволов в имени файла
                    Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
                    
                    # Двойная проверка удаления
                    if (-not (Test-Path -LiteralPath $file.FullName)) {
                        Write-Log "Успешно удален: $($file.FullName)" "Green"
                        $deletedCount++
                    } else {
                        Write-Log "НЕ УДАЛЕНО (файл остался): $($file.FullName)" "Red"
                    }
                } catch {
                    Write-Log "Ошибка удаления $($file.Name): $($_.Exception.Message)" "Red"
                }
            }
            Write-Log "Всего удалено файлов: $deletedCount из $($torrentFiles.Count)" "Cyan"
        } else {
            Write-Log "Файлы .torrent не найдены в папке: $TorrentPath" "Cyan"
        }
    } else {
        Write-Log "Папка для поиска .torrent не найдена: $TorrentPath" "Red"
    }
} catch {
    Write-Log "Критическая ошибка при удалении .torrent файлов: $($_.Exception.Message)" "Red"
}

Write-Log "=== Завершение выполнения задач ===" "Cyan"