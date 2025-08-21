# 设置 PowerShell 使用 UTF-8 编码
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 加载 PSReadLine 增强
. "D:\BaiduSyncdisk\pwsh_custom\SamplePSReadLineProfile.ps1"
# 加载函数
. "D:\BaiduSyncdisk\pwsh_custom\MyFunctions.ps1"
. "D:\BaiduSyncdisk\pwsh_custom\gitfunc.ps1"
# 加载 git 状态增强
Import-Module posh-git -ErrorAction SilentlyContinue
# 文件图标美化
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

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

oh-my-posh init pwsh | Invoke-Expression



