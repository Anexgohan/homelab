
# ----- oh-my-posh ----- #
# local:  
# oh-my-posh init pwsh --config 'E:\git\repositories\homelab\configs\terminal\oh-my-posh\profiles\json\anex.omp.json' | Invoke-Expression

# Github:  
oh-my-posh init pwsh --config 'E:\git\repositories\homelab\configs\terminal\oh-my-posh\profiles\json\anex.omp.json' | Invoke-Expression

# Tab Completion:  
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
# Predictions:  
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
# Terminal Icons:  
Import-Module -Name Terminal-Icons

# ----- end of oh-my-posh ----- #