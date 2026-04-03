using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# 设置 PowerShell 使用 UTF-8 编码
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 引入模块
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Import-Module posh-git -ErrorAction SilentlyContinue
Import-Module PSReadLine -ErrorAction SilentlyContinue
Import-Module z -ErrorAction SilentlyContinue
Import-Module oh-my-posh -ErrorAction SilentlyContinue

#region 配置 PSReadLine 选项和键绑定
Set-PSReadLineOption -EditMode Windows
# 设置命令预测显示样式为列表视图
Set-PSReadLineOption -PredictionViewStyle ListView
# 设置历史搜索时光标移动到行尾
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
# 设置命令预测来源为历史记录
Set-PSReadLineOption -PredictionSource History
# 设置 UpArrow 和 DownArrow 键的功能为历史搜索
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
# 设置 Ctrl+z 键的功能为撤销
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
# 设置 Enter 键的功能为验证并接受当前行的输入
Set-PSReadLineKeyHandler -Chord 'Enter' -Function ValidateAndAcceptLine
# 设置 Ctrl+d 键的功能为退出 PowerShell
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function ViExit
# 设置 Tab 键的补全功能为菜单补全
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
#endregion

#region dotnet 命令行补全
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition $commandAst.ToString() |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock
#endregion

# 关闭 git merge 自动编辑功能，避免在合并时弹出编辑器
$env:GIT_MERGE_AUTOEDIT = "no"

# 设置代理
function set-proxy {
    $env:http_proxy = "http://127.0.0.1:7897"
    $env:https_proxy = "http://127.0.0.1:7897"
    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy("http://127.0.0.1:7897")
    Write-Host "Proxy enabled: http://127.0.0.1:7897" -ForegroundColor Green
}

# 取消代理设置
function clear-proxy {
    $env:http_proxy = $null
    $env:https_proxy = $null
    [System.Net.WebRequest]::DefaultWebProxy = $null
    Write-Host "Proxy cleared." -ForegroundColor Green
}

# 获取代理设置
function get-proxy {
    if ($env:http_proxy -or $env:https_proxy) {
        Write-Host "Current proxy settings:" -ForegroundColor Cyan
        Write-Host "HTTP Proxy: $env:http_proxy"
        Write-Host "HTTPS Proxy: $env:https_proxy"
    } else {
        Write-Host "No proxy is currently set." -ForegroundColor Cyan
    }
}

# 设置 grep 命令的别名为 Select-String，方便在 PowerShell 中使用类似 Unix 的 grep 功能
Set-Alias grep Select-String

# 创建或更新文件的最后修改时间，类似于 Unix 的 touch 命令
function touch {
    param (
        [string]$path
    )
    if (!(Test-Path $path)) {
        New-Item -ItemType File -Path $path
    } else {
        (Get-Item $path).LastWriteTime = Get-Date
    }
}

# 打开当前目录或指定目录的文件资源管理器
function open {
    param (
        [string]$path = (Get-Location)
    )
    Start-Process "explorer.exe" $path
}

# 列出当前目录下的所有文件和文件夹，显示详细信息
function ll {
    Get-ChildItem
}

# 删除指定目录，如果不指定目录，则删除当前目录下的所有文件和文件夹，类似于 Unix 的 rm -rf 命令
function rmrf {
    param (
        [string]$path = (Get-Location)
    )
    Remove-Item -Path $path -Recurse -Force
}

# 列出已安装模块
function list-modules {
    Get-InstalledModule
}

# 设置 oh-my-posh 主题
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\avit.omp.json" | Invoke-Expression
