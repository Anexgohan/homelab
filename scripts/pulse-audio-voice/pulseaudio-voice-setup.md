# Claude Code `/voice` over SSH via PulseAudio (Windows mic → Linux LXC)

Setup notes for capturing audio from a Windows machine's microphone on a remote Linux session, so that Claude Code's `/voice` command works on a headless server.

## Problem

Claude Code's `/voice` calls SoX (`sox -d`) which records from the *local* default audio device. On a remote SSH session into a Linux box (here, an LXC), there is no microphone attached — installing SoX is not enough.

## Architecture

```
[Windows mic .101]
  -> PulseAudio server on Windows (TCP :4713)
  -> LAN
  -> Linux LXC .237: ALSA default -> pulse plugin -> PULSE_SERVER -> back to .101
  -> SoX -d picks up the routed device
  -> /voice records normally
```

Audio travels over TCP, so no `/dev/snd` passthrough or LXC device mapping is needed.

## Hosts in this setup

| Host          | Role                | Address          |
| ------------- | ------------------- | ---------------- |
| Windows (mic) | PulseAudio server   | 192.168.100.101  |
| Linux LXC     | Claude Code, SoX    | 192.168.100.237  |

## Windows side (192.168.100.101)

### 1. Install PulseAudio

Used pgaskin's Windows build: https://github.com/pgaskin/pulseaudio-win32

Installed to `C:\Program Files (x86)\PulseAudio\`.

### 2. Configure modules

Edit `C:\Program Files (x86)\PulseAudio\etc\pulse\default.pa` (Notepad as Administrator).

Disable the unix-socket module (does not work on Windows and causes startup error):

```text
#load-module module-native-protocol-unix
```

Add the TCP listener and waveOut source/sink with `record=1`:

```text
load-module module-native-protocol-tcp auth-ip-acl=192.168.100.0/24 port=4713
load-module module-waveout sink_name=output source_name=input record=1
```

`auth-ip-acl` restricts who can connect; scope it to the LAN you trust.

In `C:\Program Files (x86)\PulseAudio\etc\pulse\daemon.conf` set:

```text
exit-idle-time = -1
```

### 3. Run PulseAudio

Two ways: the control script (recommended for day-to-day) and a raw foreground run (useful for first-time verification or debugging).

#### Control script (recommended)

A pair of scripts at `C:\Users\Anex\Scripts\pulse\` provides start/stop/status/logs control plus a state-aware interactive menu:

- `pulseaudio.ps1` — main logic
- `pulseaudio.cmd` — thin wrapper that sets `-NoProfile -ExecutionPolicy Bypass` and passes args through

Files written by the script live in `%LOCALAPPDATA%\PulseAudio\`:

- `pulseaudio.log` — stdout (usually empty)
- `pulseaudio.err` — stderr (the `-vvv` log, this is the interesting one)
- `pulseaudio.pid` — last started PID

Usage (from any shell, or double-click `pulseaudio.cmd` for the menu):

```text
pulseaudio                Open state-aware interactive menu
pulseaudio start          Launch hidden, log to file
pulseaudio stop           Kill all pulseaudio.exe processes
pulseaudio restart        Stop + start
pulseaudio status         Show running state and listening port
pulseaudio logs           Show last 50 lines of stderr log
pulseaudio logs -Follow   Tail log in real-time (Ctrl+C to exit)
pulseaudio logs -Lines N  Show last N lines
```

Menu when stopped:

```
[1] Start
[2] Start and tail logs
[q] Quit menu
```

Menu when running:

```
[1] Stop
[2] Restart
[3] Tail logs (Ctrl+C to return)
[q] Quit menu (leave running)
```

The `start` action launches `pulseaudio.exe --use-pid-file=false -vvv` via `Start-Process -WindowStyle Hidden`, so no console window persists. A single-instance guard prevents double-launch (which previously left two PIDs binding the same port).

Optional: add `C:\Users\Anex\Scripts\pulse\` to your user PATH so `pulseaudio` works as a bare command from anywhere.

#### Raw foreground run (first-time verification / debugging)

From a regular cmd/PowerShell window:

```cmd
cd "C:\Program Files (x86)\PulseAudio\bin"
.\pulseaudio.exe --use-pid-file=false -vvv
```

Look for these confirmations in the log:

- `Loaded "module-native-protocol-tcp" (... port=4713)`
- `Created source N "input"` (or `wavein`)
- `Daemon startup complete.`

The `WaveIn overflow!` warnings are benign before a client connects. Ignore `Secure directory creation not supported on this platform` and `Failed to allocate shared posix-shm memory pool` — also benign on Windows.

Leave the terminal open while testing. Once you trust the setup, switch to the control script.

#### Autostart at login (optional)

Drop a shortcut to `pulseaudio.cmd` (target: `pulseaudio.cmd start`) into `shell:startup`. PulseAudio comes up hidden when you log in. Use the menu later to stop / restart / view logs.

### 4. Windows Firewall

PulseAudio's installer usually adds a rule. Verify:

```powershell
Get-NetFirewallRule -DisplayName "PulseAudio (TCP-In)" | Format-List DisplayName,Action,Enabled,Profile
$r = Get-NetFirewallRule -DisplayName "PulseAudio (TCP-In)"
$r | Get-NetFirewallPortFilter        # should show TCP 4713
$r | Get-NetFirewallAddressFilter     # RemoteAddress should be Any or your LAN
$r | Get-NetFirewallApplicationFilter # Program should match installed pulseaudio.exe
```

The active network profile must be in the rule's profile list:

```powershell
Get-NetConnectionProfile | Select-Object Name,NetworkCategory
```

If no rule exists, create one as Administrator:

```powershell
New-NetFirewallRule -DisplayName "PulseAudio TCP" `
  -Direction Inbound -Protocol TCP -LocalPort 4713 `
  -RemoteAddress 192.168.100.0/24 -Action Allow `
  -Profile Private,Domain
```

## Linux side (192.168.100.237)

### 1. Install client tools

```bash
apt install -y pulseaudio-utils libasound2-plugins
```

`pulseaudio-utils` provides `pactl`, `parecord`. `libasound2-plugins` provides the ALSA-to-PulseAudio bridge that lets SoX's `-d` (default ALSA device) flow into PulseAudio.

### 2. ALSA default -> pulse

Create `/root/.asoundrc`:

```text
pcm.!default {
    type pulse
}
ctl.!default {
    type pulse
}
```

### 3. Persist PULSE_SERVER

Append to `/root/.bashrc`:

```bash
export PULSE_SERVER=tcp:192.168.100.101:4713
```

Restart Claude Code (or any shell that needs it) so the env is inherited.

## Verification

Run these in order on .237. Each should pass before moving on.

### TCP reachability

```bash
nc -zv 192.168.100.101 4713
# expected: shadow-pc.lan [192.168.100.101] 4713 (?) open

# alt (bash-native, no nc):
timeout 5 bash -c 'exec 3<>/dev/tcp/192.168.100.101/4713 && echo CONNECTED'
```

If neither connects: Windows Firewall, wrong subnet in `auth-ip-acl`, or pulseaudio not running.

### PulseAudio handshake

```bash
pactl info
```

Should print server identity, default sink (`waveout`), default source (`wavein`). If this works but recording fails later, the issue is on the ALSA/SoX side, not the network.

### Capture from Windows mic via PulseAudio directly

```bash
parecord --channels=1 --rate=16000 --format=s16le /tmp/mic-test.wav
# speak for a few seconds, Ctrl+C
sox /tmp/mic-test.wav -n stat
```

Look at `RMS amplitude` and `Maximum amplitude`. Silence-level captures sit near 0.0001; real speech is 0.01 or higher.

### Capture via SoX -d (what /voice actually does)

```bash
sox -d -c 1 -r 16000 /tmp/sox-test.wav trim 0 3
sox /tmp/sox-test.wav -n stat
```

The `sox WARN alsa: can't encode 0-bit Unknown or not applicable` line is harmless.

If this captures audio with sane levels, `/voice` will work.

### Run /voice

Inside Claude Code:

```
/voice
```

Expected: `Voice mode enabled (hold). Hold Space to record. Dictation language: en`.

## Troubleshooting

| Symptom                                                | Likely cause                                              | Fix                                                            |
| ------------------------------------------------------ | --------------------------------------------------------- | -------------------------------------------------------------- |
| pulseaudio.exe exits with "Failed to load module-native-protocol-unix" | UNIX sockets not supported on Windows | Comment out `load-module module-native-protocol-unix`           |
| `nc -zv` returns nothing / hangs                       | Windows Firewall silently dropping                        | Add `PulseAudio (TCP-In)` rule; verify scope and active profile |
| `nc` opens but `pactl info` fails                      | `auth-ip-acl` excludes the client                         | Add client subnet to ACL or use cookie auth                    |
| `parecord` works, `sox -d` does not                    | ALSA pulse plugin missing or `.asoundrc` not in effect    | Install `libasound2-plugins`; check the right home dir         |
| Two `pulseaudio.exe` processes                         | Leftover instance from earlier launch                     | `pulseaudio stop` (kills all); the start guard prevents recurrence |
| `/voice` errors after restart                          | `PULSE_SERVER` not inherited by Claude Code               | Confirm with `printenv PULSE_SERVER`; restart Claude Code      |
| Audio is very quiet (RMS < 0.001)                      | Windows mic level low or wrong source                     | Adjust mic level in Windows Sound settings                     |

## Security notes

- `auth-ip-acl` is the weakest auth PulseAudio offers. On a trusted LAN this is fine; on anything shared, switch to cookie auth (copy `~/.config/pulse/cookie` from Windows to `~/.config/pulse/cookie` on Linux) or tunnel over SSH (`ssh -L 4713:localhost:4713 ...` and set `PULSE_SERVER=tcp:127.0.0.1:4713`).
- The PulseAudio Windows build is unmaintained. Treat it as load-bearing-but-fragile; do not expose 4713 beyond the LAN.

## Why a second-by-second walkthrough exists

This setup has many points of silent failure (Windows-side unix socket attempt, firewall drops, wrong ALSA default, env not inherited by Claude Code). Each verification step above isolates one layer, so when something breaks later, the first failing step tells you exactly which layer regressed.
