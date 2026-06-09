# pulseaudio.ps1 - Control script for PulseAudio Windows daemon
# Usage: .\pulseaudio.ps1 [<command>] [-Follow] [-Lines N]   (or: pulseaudio <command>  via pulseaudio.cmd)
# Commands: start | stop | restart | status | logs | menu | help
# No command -> opens interactive menu

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [ValidateSet('start','stop','restart','status','logs','menu','help')]
    [string]$Command = 'menu',

    [switch]$Follow,
    [int]$Lines = 50
)

$ErrorActionPreference = 'Stop'

# --- Config -------------------------------------------------------------
$PulseExe = 'C:\Program Files (x86)\PulseAudio\bin\pulseaudio.exe'
$LogDir   = Join-Path $env:LOCALAPPDATA 'PulseAudio'
$LogFile  = Join-Path $LogDir 'pulseaudio.log'
$ErrFile  = Join-Path $LogDir 'pulseaudio.err'
$PidFile  = Join-Path $LogDir 'pulseaudio.pid'
# ------------------------------------------------------------------------

function Ensure-LogDir {
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
}

function Get-PulseProcess {
    Get-Process -Name pulseaudio -ErrorAction SilentlyContinue
}

function Test-PortListening {
    [bool](Get-NetTCPConnection -LocalPort 4713 -State Listen -ErrorAction SilentlyContinue)
}

function Tail-Logs {
    param([switch]$FollowMode, [int]$LineCount = 50)
    if (-not (Test-Path $ErrFile)) {
        Write-Host "No log file yet at $ErrFile"
        return
    }
    if ($FollowMode) {
        Get-Content -Path $ErrFile -Wait -Tail $LineCount
    } else {
        Get-Content -Path $ErrFile -Tail $LineCount
    }
}

function Cmd-Start {
    Ensure-LogDir

    $existing = Get-PulseProcess
    if ($existing) {
        Write-Host ("Already running. PID: {0}" -f ($existing.Id -join ', ')) -ForegroundColor Yellow
        return
    }

    if (-not (Test-Path $PulseExe)) {
        Write-Error "pulseaudio.exe not found at: $PulseExe"
        return
    }

    Set-Content -Path $LogFile -Value ("# Started at {0}" -f (Get-Date -Format o)) -Encoding ASCII
    Set-Content -Path $ErrFile -Value ''                                            -Encoding ASCII

    $proc = Start-Process `
        -FilePath $PulseExe `
        -ArgumentList '--use-pid-file=false','-vvv' `
        -WindowStyle Hidden `
        -RedirectStandardOutput $LogFile `
        -RedirectStandardError  $ErrFile `
        -PassThru

    $proc.Id | Out-File -Encoding ASCII $PidFile
    Write-Host ("Started. PID: {0}" -f $proc.Id) -ForegroundColor Green
    Write-Host ("Log:    {0}" -f $LogFile)
    Write-Host ("Err:    {0}" -f $ErrFile)
}

function Cmd-Stop {
    $procs = Get-PulseProcess
    if (-not $procs) {
        Write-Host "Not running." -ForegroundColor Yellow
        return
    }
    foreach ($p in $procs) {
        Stop-Process -Id $p.Id -Force
        Write-Host ("Stopped PID {0}" -f $p.Id) -ForegroundColor Green
    }
    if (Test-Path $PidFile) { Remove-Item $PidFile -Force }
}

function Cmd-Restart {
    Cmd-Stop
    Start-Sleep -Milliseconds 500
    Cmd-Start
}

function Cmd-Status {
    $procs = Get-PulseProcess
    if (-not $procs) {
        Write-Host "Status: STOPPED" -ForegroundColor Red
    } else {
        Write-Host "Status: RUNNING" -ForegroundColor Green
        $procs |
            Select-Object Id,
                @{N='RSS_MB';   E={[math]::Round($_.WorkingSet64/1MB,1)}},
                @{N='StartTime';E={$_.StartTime}} |
            Format-Table -AutoSize
    }

    if (Test-PortListening) {
        Write-Host "Port 4713: LISTENING" -ForegroundColor Green
    } else {
        Write-Host "Port 4713: NOT LISTENING" -ForegroundColor Red
    }
}

function Cmd-Logs {
    Tail-Logs -FollowMode:$Follow -LineCount $Lines
}

function Cmd-Menu {
    while ($true) {
        Clear-Host
        $procs   = Get-PulseProcess
        $running = [bool]$procs
        $listen  = Test-PortListening

        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host " PulseAudio Control" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""

        if ($running) {
            $pidList = $procs.Id -join ', '
            Write-Host " Status: " -NoNewline
            Write-Host "RUNNING " -ForegroundColor Green -NoNewline
            Write-Host "(PID $pidList)"
            Write-Host " Port:   " -NoNewline
            if ($listen) {
                Write-Host "4713 listening" -ForegroundColor Green
            } else {
                Write-Host "4713 not yet listening" -ForegroundColor Yellow
            }
            Write-Host ""
            Write-Host " [1] Restart"
            Write-Host " [2] Tail logs (Ctrl+C to return)"
            Write-Host " [q] Stop and exit menu"
            Write-Host " [e] Exit menu (PulseAudio keeps running in background)"
        } else {
            Write-Host " Status: " -NoNewline
            Write-Host "STOPPED" -ForegroundColor Red
            Write-Host ""
            Write-Host " [1] Start"
            Write-Host " [2] Start and tail logs"
            Write-Host " [e] Exit menu"
        }

        Write-Host ""
        Write-Host " Shell commands:" -ForegroundColor DarkGray
        Write-Host "   pulseaudio start" -ForegroundColor DarkGray
        Write-Host "   pulseaudio stop" -ForegroundColor DarkGray
        Write-Host "   pulseaudio status" -ForegroundColor DarkGray
        Write-Host "   pulseaudio logs -Follow" -ForegroundColor DarkGray
        Write-Host "   pulseaudio restart" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host " Choice: " -NoNewline
        $key = $Host.UI.RawUI.ReadKey('IncludeKeyDown,NoEcho')
        $choice = $key.Character.ToString().ToLower()
        Write-Host $choice    # echo the keystroke so the user sees what they pressed

        # Handle exit choices outside the switch to avoid any
        # return-from-switch quirks across PowerShell versions.
        if ($choice -eq 'e' -or $choice -eq 'exit') { return }
        if ($choice -eq 'q' -or $choice -eq 'quit') {
            # Always invoke Cmd-Stop — it kills ALL pulseaudio.exe by name,
            # so any orphan/stale instance gets cleaned even if the running
            # state we read at the top of the loop missed it.
            Cmd-Stop
            Start-Sleep -Milliseconds 400
            return
        }

        if ($running) {
            switch ($choice) {
                '1' { Cmd-Restart; Start-Sleep -Milliseconds 800 }
                '2' {
                    Write-Host ""
                    Write-Host "--- Tailing $ErrFile (Ctrl+C to return) ---" -ForegroundColor Cyan
                    try { Tail-Logs -FollowMode -LineCount 50 } catch { }
                }
                default { }
            }
        } else {
            switch ($choice) {
                '1' { Cmd-Start; Start-Sleep -Milliseconds 800 }
                '2' {
                    Cmd-Start
                    Start-Sleep -Milliseconds 500
                    Write-Host ""
                    Write-Host "--- Tailing $ErrFile (Ctrl+C to return) ---" -ForegroundColor Cyan
                    try { Tail-Logs -FollowMode -LineCount 50 } catch { }
                }
                default { }
            }
        }
    }
}

function Cmd-Help {
@"
pulseaudio.ps1 - PulseAudio control (invoke as 'pulseaudio' via pulseaudio.cmd)

  (no args)            Open interactive menu (state-aware)
  start                Launch pulseaudio hidden, log to file
  stop                 Kill all pulseaudio.exe processes
  restart              Stop + start
  status               Show running state and listening port
  logs                 Show last $Lines lines of log
  logs -Follow         Tail log in real-time (Ctrl+C to exit)
  logs -Lines 200      Show last N lines
  menu                 Same as no args
  help                 This screen

Files:
  exe : $PulseExe
  log : $LogFile      (stdout - usually empty)
  err : $ErrFile      (stderr - the verbose log)
  pid : $PidFile

Examples:
  pulseaudio                Open menu
  pulseaudio start          Start in background
  pulseaudio status         Check state
  pulseaudio logs -Follow   Tail log continuously
"@
}

switch ($Command) {
    'start'   { Cmd-Start }
    'stop'    { Cmd-Stop }
    'restart' { Cmd-Restart }
    'status'  { Cmd-Status }
    'logs'    { Cmd-Logs }
    'menu'    { Cmd-Menu }
    'help'    { Cmd-Help }
}
