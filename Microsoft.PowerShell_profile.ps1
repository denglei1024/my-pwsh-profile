# 设置 PowerShell 使用 UTF-8 编码
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\gruvbox.omp.json" | Invoke-Expression
# 加载 git 状态增强
Import-Module posh-git -ErrorAction SilentlyContinue
# 文件图标美化
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# 打开当前目录
function Open-CurrentDirectory {
    param (
        [string]$path = (Get-Location)
    )
    Start-Process "explorer.exe" $path
}

Set-Alias open Open-CurrentDirectory

# NOTE: registry keys for IE 8, may vary for other versions
$regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'

function Clear-Proxy
{
    Set-ItemProperty -Path $regPath -Name ProxyEnable -Value 0
    Set-ItemProperty -Path $regPath -Name ProxyServer -Value ''
    Set-ItemProperty -Path $regPath -Name ProxyOverride -Value ''

    [Environment]::SetEnvironmentVariable('http_proxy', $null, 'User')
    [Environment]::SetEnvironmentVariable('https_proxy', $null, 'User')
}

function Set-Proxy
{
    $proxy = 'http://127.0.0.1:7897'

    Set-ItemProperty -Path $regPath -Name ProxyEnable -Value 1
    Set-ItemProperty -Path $regPath -Name ProxyServer -Value $proxy
    Set-ItemProperty -Path $regPath -Name ProxyOverride -Value '<local>'

    [Environment]::SetEnvironmentVariable('http_proxy', $proxy, 'User')
    [Environment]::SetEnvironmentVariable('https_proxy', $proxy, 'User')
}

## Set PSReadLine options and keybindings
$PSROptions = @{
    ContinuationPrompt = '  '
    Colors = @{
        # 关键字、操作符：用 Solarized 的蓝色系，突出但不刺眼
        Operator         = $PSStyle.Foreground.Blue
        # 参数：用 Cyan，清晰区分
        Parameter        = $PSStyle.Foreground.Cyan
        # 选中内容：Solarized Light 下推荐暗灰背景+深蓝前景
        Selection        = $PSStyle.Foreground.White + $PSStyle.Background.DarkGray
        # 预测输入：亮灰前景 + 暗灰背景，更柔和，不会太抢眼
        InLinePrediction = $PSStyle.Foreground.BrightBlack
    }
}

Set-PSReadLineOption @PSROptions
Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Enter' -Function ValidateAndAcceptLine
## Add argument completer for the dotnet CLI tool
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition $commandAst.ToString() |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock



$env:GIT_MERGE_AUTOEDIT = "no"

function gw {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Branch
    )
    git worktree add ..\$Branch $Branch origin master
}