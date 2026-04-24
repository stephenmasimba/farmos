param(
    [string] $BackupRoot = 'c:\wamp64\www\farmos\db_backups\daily',
    [string[]] $Databases = @('farmos'),
    [switch] $AllDatabases,
    [int] $KeepDays = 30,
    [string] $MySqlUser = 'root',
    [string] $MySqlPassword = '',
    [switch] $InstallScheduledTask,
    [string] $TaskName = 'FarmOS Daily DB Backup',
    [string] $RunAt = '02:00'
)

$ErrorActionPreference = 'Stop'

function Resolve-MySqlExePath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ExeName,
        [Parameter(Mandatory = $true)]
        [string] $WampGlob
    )

    $cmd = Get-Command $ExeName -ErrorAction SilentlyContinue
    if ($null -ne $cmd -and $null -ne $cmd.Source -and $cmd.Source -ne '') {
        return $cmd.Source
    }

    $candidate = Get-ChildItem -Path $WampGlob -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Select-Object -First 1 -ExpandProperty FullName

    if ($null -ne $candidate -and $candidate -ne '') {
        return $candidate
    }

    throw "$ExeName not found. Ensure MySQL is enabled in WAMP and mysql bin folder is available."
}

function Get-PowerShellExe {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($null -ne $pwsh -and $null -ne $pwsh.Source -and $pwsh.Source -ne '') {
        return $pwsh.Source
    }

    return (Get-Command powershell -ErrorAction Stop).Source
}

function Parse-RunAt {
    param([string] $Value)
    $dt = [DateTime]::MinValue
    if (-not [DateTime]::TryParseExact($Value, 'HH:mm', $null, [Globalization.DateTimeStyles]::None, [ref] $dt)) {
        throw "Invalid RunAt. Expected HH:mm, got: $Value"
    }
    return $dt
}

if ($env:MYSQL_USER -and $env:MYSQL_USER -ne '') {
    $MySqlUser = $env:MYSQL_USER
}
if ($env:MYSQL_PASSWORD) {
    $MySqlPassword = $env:MYSQL_PASSWORD
}

$mysql = Resolve-MySqlExePath -ExeName 'mysql' -WampGlob 'c:\wamp64\bin\mysql\*\bin\mysql.exe'
$mysqldump = Resolve-MySqlExePath -ExeName 'mysqldump' -WampGlob 'c:\wamp64\bin\mysql\*\bin\mysqldump.exe'

if ($InstallScheduledTask) {
    $runAtTime = Parse-RunAt -Value $RunAt
    $psExe = Get-PowerShellExe

    $actionArgs = @(
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        $PSCommandPath
    )

    $action = New-ScheduledTaskAction -Execute $psExe -Argument ($actionArgs -join ' ')
    $trigger = New-ScheduledTaskTrigger -Daily -At $runAtTime.TimeOfDay
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
    Write-Output "Scheduled task installed: $TaskName (Daily at $RunAt)"
    exit 0
}

New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

$dateFolder = Get-Date -Format 'yyyyMMdd'
$outDir = Join-Path $BackupRoot $dateFolder
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$logFile = Join-Path $outDir 'backup.log'
"Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $logFile -Encoding utf8

$authArgs = @("-u$MySqlUser")
if ($MySqlPassword -ne '') {
    $authArgs += "-p$MySqlPassword"
}

if ($AllDatabases) {
    $exclude = @('information_schema', 'performance_schema', 'mysql', 'sys', 'phpmyadmin')
    $dbs = & $mysql @authArgs -N -e 'SHOW DATABASES;' |
        Where-Object { $_ -and ($exclude -notcontains $_) }
    $Databases = @($dbs)
}

$Databases = @($Databases | Where-Object { $_ -and $_ -ne '' } | Sort-Object -Unique)
if ($Databases.Count -eq 0) {
    throw 'No databases selected for backup.'
}

foreach ($db in $Databases) {
    $file = Join-Path $outDir ($db + '.sql')
    $errFile = Join-Path $outDir ($db + '.err.log')

    $dumpArgs = @()
    $dumpArgs += $authArgs
    $dumpArgs += @(
        '--databases',
        $db,
        '--single-transaction',
        '--routines',
        '--events',
        '--triggers',
        '--hex-blob',
        '--set-gtid-purged=OFF',
        '--default-character-set=utf8mb4'
    )

    "Dumping: $db -> $file" | Tee-Object -FilePath $logFile -Append | Out-Null

    try {
        & $mysqldump @dumpArgs 1> $file 2> $errFile
        if ($LASTEXITCODE -ne 0) {
            throw "mysqldump failed for $db (exit $LASTEXITCODE). See $errFile"
        }
    } catch {
        "ERROR: $($_.Exception.Message)" | Tee-Object -FilePath $logFile -Append | Out-Null
        throw
    }
}

if ($KeepDays -gt 0) {
    $cutoff = (Get-Date).AddDays(-1 * $KeepDays)
    Get-ChildItem -Path $BackupRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $cutoff } |
        ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
}

"Completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Tee-Object -FilePath $logFile -Append | Out-Null
"Backups: $($Databases -join ', ')" | Tee-Object -FilePath $logFile -Append | Out-Null
