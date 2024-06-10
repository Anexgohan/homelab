
## Links:
https://www.youtube.com/watch?v=9U8LCjuQzdc&t

https://ohmyposh.dev/docs

https://ohmyposh.dev/docs/installation/windows

# ===== Windows =====
## ----- Install Oh-My-Posh -----

PowerShell prompt and run the following command:  
manual installation and upgrade:  
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
```
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
```

winget installation and upgrade:
```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget
```
```powershell
winget upgrade JanDeDobbeleer.OhMyPosh -s winget
```

chocolatey installation and upgrade:
```powershell
choco install oh-my-posh
```
```powershell
choco upgrade oh-my-posh
```

Set Environment Path:
```powershell
$env:Path += ";C:\Users\user\AppData\Local\Programs\oh-my-posh\bin"
```

Check oh-my-posh install path:
```powershell
(Get-Command oh-my-posh).Source
```

enable oh-my-posh in PowerShell (temporary for current session):
```powershell
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression
```

## ----- Export the config -----

Export the current configuration to a json file:
```powershell
oh-my-posh config export --format json --output E:\git\repositories\homelab\configs\terminal\oh-my-posh\profiles\json\.anex_oh-my-posh_theme_01.json
```

Export the current configuration to a yaml file:
```powershell
oh-my-posh config export --format yaml --output E:\git\repositories\homelab\configs\terminal\oh-my-posh\profiles\yaml\.anex_oh-my-posh_theme_01.yaml
```

Export the current configuration to a toml file:
```powershell
oh-my-posh config export --format toml --output E:\git\repositories\homelab\configs\terminal\oh-my-posh\profiles\toml\.anex_oh-my-posh_theme_01.toml
```

## ----- Configure -----

Enable oh-my-posh in PowerShell (permanent) (needs to be done only once):
```powershell
New-Item -Path $PROFILE -Type File -Force
```

check profile path:
```powershell
$PROFILE
```

open profile in vscode:
```powershell
code $PROFILE
```
open profile in notepad:
```powershell
notepad $PROFILE
```

create the profile if it does not exist:
```powershell
New-Item -Path $PROFILE -Type File -Force
```

Set the theme in the PowerShell profile:
```powershell
oh-my-posh init pwsh --config 'E:\git\repositories\homelab\configs\terminal\oh-my-posh\.anex_oh-my-posh_theme_01.yaml' | Invoke-Expression
```

Refresh the profile:
```powershell
. $PROFILE
```

change the config to suit your needs:

## Done



