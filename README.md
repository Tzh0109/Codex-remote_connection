# Codex 自动代理启动器

社区辅助脚本，非 OpenAI 官方工具。读取当前用户 Windows 手动系统代理，为新启动的进程设置代理环境变量，查找 `OpenAI.Codex` 安装包并启动 `ChatGPT.exe`。不修改注册表、系统代理或用户级环境变量；启动后恢复脚本进程原有变量。

## 安装与使用

1. 安装 Windows 版 Codex，先确认能正常打开。
2. 下载本仓库，将脚本放入自己选择的固定目录。
3. 启动可信的代理软件，开启 Windows 手动系统代理。
4. 完全退出已有 Codex（包括后台进程），再运行脚本。已有进程不会获得新环境变量。
5. 在脚本所在目录打开 PowerShell，运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Start-Codex.ps1"
```

请运行完整文件，不要把多行条件语句逐段粘贴到交互终端。

## 创建快捷方式

桌面右键 → 新建 → 快捷方式，目标填写以下模板；将占位部分换成脚本的实际完整路径，保留英文双引号：

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "<脚本完整路径>"
```

命名为“Codex（自动代理）”。先用可见窗口确认启动成功，再使用隐藏窗口。图标可从本机已安装应用选择，无需上传应用文件。

## 支持范围与限制

- Windows PowerShell 5.1 或更高版本；需可用的 `Get-AppxPackage`。仅查找当前用户注册的 `OpenAI.Codex` 包，支持包内 `app\ChatGPT.exe` 或根目录 `ChatGPT.exe`。
- 读取当前用户 Internet Settings 的 `ProxyEnable` 和 `ProxyServer`，不是 WinHTTP 代理。
- 支持统一 `host:port` 或 `http=host:port;https=host:port`。分协议配置优先取 https，再取 http，并将同一个 HTTP 代理用于所有变量；不同协议必须使用不同代理的配置不适用。
- https 条目表示 HTTPS 目标使用的代理，不代表代理连接本身采用 TLS。仅支持普通 HTTP 代理（包括为 HTTPS 建立 CONNECT 隧道），不支持 SOCKS、带用户名密码的代理、PAC/WPAD、仅 TUN 或自动检测配置。
- 不转换 Windows ProxyOverride；NO_PROXY 固定为 localhost、127.0.0.1、::1。其他绕过规则需自行评估。
- 应用及子进程是否遵循环境变量取决于其实现；不保证全部流量使用代理，也不保证远程控制功能恢复。应用升级改变包名或目录后可能需要更新脚本。

## 排查

将快捷方式目标临时改成以下模板，以保留窗口查看错误：

```text
powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -File "<脚本完整路径>"
```

- 提示启用代理：检查 Windows 手动代理开关及代理软件是否正在运行。PAC 或仅 TUN 模式不属于支持范围。
- 地址格式错误：检查代理是否为普通 HTTP 主机和端口，不要填订阅链接、密码或 SOCKS 地址。
- 找不到安装包：用同一个 Windows 用户确认应用已安装；不要手动接管 WindowsApps 权限。其他安装渠道或未来目录结构可能不兼容。
- 能启动但不联网：完全退出旧进程后重试，检查代理端口、出口和网络；脚本不负责检测代理服务是否可达。
- 路径含空格：完整路径必须加英文双引号。保存文件时确认后缀是 `.ps1` 而非 `.ps1.txt`。

## 安全使用与验证边界

仅使用可信代理。脚本无需管理员权限，不写入凭据，不下载或执行远程代码。Bypass 仅用于本次 PowerShell 启动，不永久修改执行策略；受组织策略管理的设备请遵循组织要求。下载后先检查脚本内容，再决定是否运行。

提交问题前删除用户名、真实路径、代理地址、令牌和日志中的敏感内容。不要提交快捷方式、代理配置、应用数据或凭据。

本版本进行了 PowerShell 语法检查；当前准备环境未找到已安装的 OpenAI.Codex，尚未完成实际应用启动及网络验证。
