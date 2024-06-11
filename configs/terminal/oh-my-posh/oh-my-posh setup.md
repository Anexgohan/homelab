
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
oh-my-posh init pwsh --config 'E:\git\repositories\homelab\configs\terminal\oh-my-posh\profiles\json\anex.omp.json' | Invoke-Expression
```

Refresh the profile:
```powershell
. $PROFILE
```

change the config to suit your needs:

---

# ===== Linux =====
Links:  
https://ohmyposh.dev/docs/installation/linux

install unzip needed for install script:
```bash
apt install unzip -y
```

download the install script:
```bash
curl -s https://ohmyposh.dev/install.sh | bash -s
```

install nerd fonts and icons (FiraCode Nerd Font) or (Meslo LGM NF):
```bash
oh-my-posh font install
```

Refresh the profile::
```bash
exec bash
```
---
download the local config from github:  

wget
```bash
wget -P /root/anex/oh-my-posh/ https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json
```

curl
```bash
curl -L -o /root/anex/oh-my-posh/anex.omp.json https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json
```
---
in .bashrc add the following line (add one of the following lines only):
for Local Config:
```bash  
eval "$(oh-my-posh init bash --config /path/to/file/anex.omp.json)"
```

for Remote Config:
```bash
eval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json)"
```

Refresh the profile::
```bash
exec bash
```


# ===== Linux All-in-One Command =====
```bash
mkdir -p '/root/anex/oh-my-posh/' &&
cd '/root/anex/oh-my-posh/' &&
apt-get install unzip -y &&
curl -s https://ohmyposh.dev/install.sh | bash -s &&
# oh-my-posh font install &&
wget -N -P '/root/anex/oh-my-posh/' 'https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json' &&
echo -e '\n\n# oh-my-posh''\neval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json)"' | tee -a /root/.bashrc &&
exec bash
```