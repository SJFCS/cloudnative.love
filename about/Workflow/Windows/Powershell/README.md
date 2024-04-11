# invoke - Powershell Invoke-RestMethod 授权 header

在调用 Invoke-RestMethod 时使用 Powershell，例如:
```
Invoke-RestMethod -Method Get -Uri "https://google.com/api/GetData" -Headers $headers
```
和 $headers存在

```
$headers = @{
    Authorization="Secret $username $password"
    Content='application/json'
    Authorization="Bearer $token"
}
```

https://stackoverflow.com/questions/54191266/powershell-invoke-restmethod-authorization-header