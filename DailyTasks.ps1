# DailyTasks.ps1 - Скрипт автоматизации ежедневных задач
# Кодировка: UTF-8 with BOM

param(
    [string]$TorrentPath = "D:\Downloads"
)

$sourceFile = "C:\Users\Nebelung\Documents\Finance.icash"
$destFolder = "d:\Yandex.Disk\Архив\iCash"
$logFile = "c:\Users\Nebelung\Documents\GitHub\Automation\tasks_log.txt"
$winRarPath = "C:\Program Files\WinRAR\WinRAR.exe"
$password = "AlexCas@12"

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

# Задача 1: Копирование и архивирование iCash
try {
    if (Test-Path $sourceFile) {
        if (-not (Test-Path $destFolder)) {
            New-Item -ItemType Directory -Force -Path $destFolder | Out-Null
        }

        $tempFolder = Join-Path $env:TEMP "iCashBackup_$(Get-Random)"
        New-Item -ItemType Directory -Force -Path $tempFolder | Out-Null
        
        $tempFile = Join-Path $tempFolder (Split-Path $sourceFile -Leaf)
        Copy-Item -Path $sourceFile -Destination $tempFile -Force
        
        $dateStamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $archiveName = "Finance_${dateStamp}.rar"
        $archivePath = Join-Path $destFolder $archiveName

        # Ключ -ep3 исключает пути полностью, -ibck скрывает окно
        $rarArgs = "a", "-p$password", "-ibck", "-ep3", "-y", "`"$archivePath`"", "`"$tempFile`""
        
        Start-Process -FilePath $winRarPath -ArgumentList $rarArgs -Wait -NoNewWindow
        Start-Sleep -Seconds 2

        if (Test-Path $archivePath) {
            Write-Log "Архив успешно создан: $archiveName" "Green"
            Remove-Item -Path $tempFolder -Recurse -Force
        } else {
            Write-Log "Ошибка: Архив не был создан." "Red"
            Remove-Item -Path $tempFolder -Recurse -Force
        }
    } else {
        Write-Log "Исходный файл не найден: $sourceFile" "Red"
    }
} catch {
    Write-Log "Ошибка при работе с iCash: $($_.Exception.Message)" "Red"
}

# Задача 2: Удаление .torrent файлов
try {
    if (Test-Path $TorrentPath) {
        # Получаем список файлов
        $torrentFiles = Get-ChildItem -Path $TorrentPath -Filter "*.torrent" -File -ErrorAction SilentlyContinue
        
        if ($torrentFiles.Count -gt 0) {
            Write-Log "Найдено файлов .torrent: $($torrentFiles.Count). Начинаем удаление..." "Cyan"
            
            $deletedCount = 0
            foreach ($file in $torrentFiles) {
                try {
                    # Используем конвейер для надежного удаления файлов со спецсимволами
                    $file | Remove-Item -Force -ErrorAction Stop
                    
                    # Проверка: действительно ли файл удален
                    if (-not (Test-Path $file.FullName)) {
                        Write-Log "Удален файл: $($file.Name)" "Green"
                        $deletedCount++
                    } else {
                        Write-Log "Не удалось удалить (файл остался): $($file.Name)" "Red"
                    }
                } catch {
                    Write-Log "Ошибка при удалении $($file.Name): $($_.Exception.Message)" "Red"
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
    Write-Log "Ошибка при удалении .torrent файлов: $($_.Exception.Message)" "Red"
}

Write-Log "=== Завершение выполнения задач ===" "Cyan"