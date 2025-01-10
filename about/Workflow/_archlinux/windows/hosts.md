attrib -s -h -r %windir%\System32\drivers\etc\hosts
icacls "%windir%\System32\drivers\etc\hosts" /grant "%USERNAME%:(F)"
start "%windir%\System32\drivers\etc\hosts"