$env:HTTPS_PROXY="http://127.0.0.1:10889"
$env:HTTP_PROXY="http://127.0.0.1:10889"

Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme Paradox

Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
