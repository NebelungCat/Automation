# DailyTasks.ps1 - Скрипт автоматизации ежедневных задач
# Кодировка: UTF-8 with BOM

param(
    [string]$TorrentPath = "D:\Downloads"
)

$sourceFile = "C:\Users\Nebelung\Documents\Finance.icash"
$destFolder = "d:\YandexDisk\Архив\iCash"
$logFile = "D:\Downloads\Automation-main\tasks_log.txt"
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

        # Создаем временную папку для чистого копирования
        $tempFolder = Join-Path $env:TEMP "iCashBackup_$(Get-Random)"
        New-Item -ItemType Directory -Force -Path $tempFolder | Out-Null
        
        # Копируем файл во временную папку
        $fileName = Split-Path $sourceFile -Leaf
        $tempFile = Join-Path $tempFolder $fileName
        Copy-Item -Path $sourceFile -Destination $tempFile -Force
        
        # Формируем имя и путь архива
        $dateStamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $archiveName = "Finance_${dateStamp}.rar"
        $archivePath = Join-Path $destFolder $archiveName

        # Аргументы для WinRAR:
        # a - добавить
        # -p"пароль" - установка пароля
        # -ibck - работать в фоне (скрыто)
        # -ep1 - исключить базовую папку из имен (важно!)
        # -y - отвечать Yes на все запросы
        # -m5 - максимальное сжатие
        $argsList = @(
            "a",
            "-p`"$password`"",
            "-ibck",
            "-ep1", 
            "-y",
            "-m5",
            "`"$archivePath`"",
            "`"$fileName`""
        )

        # Запускаем WinRAR из временной папки, чтобы в архив попало только имя файла
        $procInfo = New-Object System.Diagnostics.ProcessStartInfo
        $procInfo.FileName = $winRarPath
        $procInfo.Arguments = ($argsList -join " ")
        $procInfo.WorkingDirectory = $tempFolder
        $procInfo.UseShellExecute = $false
        $procInfo.CreateNoWindow = $true
        $procInfo.RedirectStandardOutput = $true
        $procInfo.RedirectStandardError = $true
        
        $process = [System.Diagnostics.Process]::Start($procInfo)
        $process.WaitForExit()

        # Небольшая задержка для завершения записи на диск
        Start-Sleep -Seconds 1

        if (Test-Path $archivePath) {
            Write-Log "Архив успешно создан: $archiveName" "Green"
            # Удаляем временную папку
            Remove-Item -Path $tempFolder -Recurse -Force
        } else {
            Write-Log "Ошибка: Архив не был создан после завершения процесса." "Red"
            Remove-Item -Path $tempFolder -Recurse -Force
        }
    } else {
        Write-Log "Исходный файл не найден: $sourceFile" "Red"
    }
} catch {
    Write-Log "Ошибка при работе с iCash: $($_.Exception.Message)" "Red"
    if (Test-Path $tempFolder) { Remove-Item -Path $tempFolder -Recurse -Force }
}

# Задача 2: Удаление .torrent файлов
try {
    if (Test-Path $TorrentPath) {
        $torrentFiles = Get-ChildItem -Path $TorrentPath -Filter "*.torrent" -File
        if ($torrentFiles.Count -gt 0) {
            $deletedCount = 0
            foreach ($file in $torrentFiles) {
                try {
                    Remove-Item -Path $file.FullName -Force -ErrorAction Stop
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