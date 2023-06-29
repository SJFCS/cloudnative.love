# OTP
OTP是“一次性密码”（One-Time Password）的缩写，指的是一种只能使用一次的密码。在网络安全中，OTP通常用于增强身份验证和保护账户安全。


OTP的原理是在每次身份验证时生成一个新的、不可预测的密码，并将其发送给用户。用户在身份验证时需要输入这个密码，这个密码只能使用一次，之后就会失效。这样可以有效地减少密码被窃取或猜测的风险，提高账户的安全性。


常见的OTP算法包括HOTP（HMAC-based One-Time Password Algorithm）和TOTP（Time-based One-Time Password Algorithm）。HOTP基于哈希函数，TOTP基于时间戳和哈希函数。OTP可以通过手机应用程序、硬件设备或短信等方式生成和传递，也可以通过第三方服务提供商来实现。