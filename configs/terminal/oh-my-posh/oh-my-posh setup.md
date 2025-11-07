
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

install nerd fonts and icons `(FiraCode Nerd Font)` or `(Meslo LGM NF)`:
```bash
oh-my-posh font install
```
## ----- *Terminal settings:* ----- 

In terminal: 
>settings>appearance  
`Use acrylic Material in tab row` to `enabled`

In terminal change fonts to:
>settings>profiles>defaults>appearance  
`(FiraCode Nerd Font)`  
or  
`(Meslo LGM NF)`

### *For Powershell 7.4:*  (Recomended)  

Autocomplete is already enabled in Powershell 7.4
```bash
winget install Microsoft.PowerShell
```

### *For Windows Powershell:*
which is pre-installed with windows  
[Tab Completion](https://learn.microsoft.com/en-us/windows/package-manager/winget/tab-completion)

```powershell
code $PROFILE
```
add the following line to the profile:
```
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
```

### *Get Predictions / Tab Completion in powershell:*
```powershell
Install-Module -Name PSReadLine -force
```  
print PSReadLineOption (to see the options):
```powershell
Get-PSReadLineOption
```
print PSReadLineKeyHandler (to see the keybindings):
```powershell
Get-PSReadLineKeyHandler
```
Open the profile in vscode:
```powershell
code $PROFILE
```
Add the following line to the profile:
>Options are: None, History, Plugin, HistoryAndPlugin
```powershell
Set-PSReadLineOption -PredictionSource History
```  
>Options are: ListView, InlineView
```powershell
Set-PSReadLineOption -PredictionViewStyle ListView
```


---

# ===== Linux =====
Links:  
https://ohmyposh.dev/docs/installation/linux

install unzip needed for install script:
```bash
apt-get -y install curl unzip
```

create the directory for oh-my-posh:
```bash
mkdir -p '/root/anex/oh-my-posh/'
```

change to the oh-my-posh directory:
```bash
cd '/root/anex/oh-my-posh/'
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
wget -N -P /root/anex/oh-my-posh/ https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json
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

### in case it prompts with an error:
`Installation directory /root/.local/bin is not in your $PATH, add it using`
```bash
export PATH=$PATH:/root/.local/bin
```

### oh-my-posh install.sh
```bash
mkdir -p '/root/anex/oh-my-posh/' && \
cd '/root/anex/oh-my-posh/' && \
export PATH=$PATH:/root/.local/bin && \
apt-get install -y curl wget unzip && \
curl -s https://ohmyposh.dev/install.sh | bash -s && \

oh-my-posh font install && \
wget -N -P '/root/anex/oh-my-posh/' 'https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json' && \
if ! grep -Fxq 'eval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json)"' /root/.bashrc ;
then \
    echo -e '\n\n# oh-my-posh''\nexport PATH=$PATH:/root/.local/bin''\neval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json)"' | tee -a /root/.bashrc
fi &&
exec bash
```