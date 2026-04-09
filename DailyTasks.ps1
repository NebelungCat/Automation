# DailyTasks.ps1 - Скрипт автоматизации ежедневных задач
# Путь проекта: c:\Users\Nebelung\Documents\GitHub\Automation\

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
    
    # Создаем папку для лога если нет
    $logDir = Split-Path $logFile -Parent
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }

    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    
    # Вывод в консоль (если запущено не скрытно, цвета не видны, но текст пишется)
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

        # Создаем временную папку ТОЛЬКО для этого файла
        $tempFolder = Join-Path $env:TEMP "iCashBackup_$(Get-Random)"
        New-Item -ItemType Directory -Force -Path $tempFolder | Out-Null
        
        # Копируем файл внутрь временной папки
        $fileName = Split-Path $sourceFile -Leaf
        $tempFile = Join-Path $tempFolder $fileName
        Copy-Item -Path $sourceFile -Destination $tempFile -Force
        
        # Формируем имя архива
        $dateStamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $archiveName = "Finance_${dateStamp}.rar"
        $archivePath = Join-Path $destFolder $archiveName

        # Аргументы для WinRAR:
        # a - добавить
        # -p"password" - пароль
        # -ibck - фон (без окна)
        # -y - отвечать "да" на все вопросы
        # ВАЖНО: Мы запускаем команду ИЗ папки $tempFolder, поэтому указываем только имя файла.
        # Это гарантирует, что внутри архива будет только файл, без путей.
        $rarArgs = "a -p`"$password`" -ibck -y `"$archivePath`" `"$fileName`""
        
        # Запускаем WinRAR, предварительно меняя рабочую директорию
        $procInfo = New-Object System.Diagnostics.ProcessStartInfo
        $procInfo.FileName = $winRarPath
        $procInfo.Arguments = $rarArgs
        $procInfo.WorkingDirectory = $tempFolder
        $procInfo.UseShellExecute = $false
        $procInfo.CreateNoWindow = $true
        $procInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $procInfo
        $process.Start() | Out-Null
        $process.WaitForExit()

        # Небольшая задержка для надежности записи на диск
        Start-Sleep -Seconds 1

        if (Test-Path $archivePath) {
            Write-Log "Архив успешно создан: $archiveName" "Green"
            # Удаляем временную папку
            Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            Write-Log "Ошибка: Архив не был создан." "Red"
            Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
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
        # Получаем список файлов явно
        $torrentFiles = Get-ChildItem -Path $TorrentPath -Filter "*.torrent" -File -ErrorAction SilentlyContinue
        
        if ($torrentFiles.Count -gt 0) {
            $deletedCount = 0
            foreach ($file in $torrentFiles) {
                try {
                    # Используем LiteralPath для обработки спецсимволов в именах
                    Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
                    Write-Log "Удален файл: $($file.Name)" "Green"
                    $deletedCount++
                } catch {
                    Write-Log "Не удалось удалить $($file.Name): $($_.Exception.Message)" "Red"
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