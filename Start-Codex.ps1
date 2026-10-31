#requires -Version 5.1
$ErrorActionPreference = 'Stop'
$names = @('HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY', 'NO_PROXY')
$saved = @{}
foreach ($name in $names) { $saved[$name] = [Environment]::GetEnvironmentVariable($name, 'Process') }
try {
    $settings = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
    if ($settings.ProxyEnable -ne 1 -or -not $settings.ProxyServer) {
        throw 'Enable a manual Windows HTTP proxy before launching.'
    }
    $server = ([string]$settings.ProxyServer).Trim()
    if ($server.Contains('=')) {
        $entries = @{}
        foreach ($entry in $server.Split(';')) {
            if ($entry -match '^\s*(http|https)\s*=\s*(.+?)\s*$') {
                $entries[$matches[1].ToLowerInvariant()] = $matches[2]
            }
        }
        if ($entries.ContainsKey('https')) { $server = $entries['https'] }
        elseif ($entries.ContainsKey('http')) { $server = $entries['http'] }
        else { throw 'No compatible HTTP proxy entry found.' }
    }
    if ($server -notmatch '^[a-zA-Z][a-zA-Z0-9+.-]*://') { $server = 'http://' + $server }
    $uri = $null
    if (-not [Uri]::TryCreate($server, [UriKind]::Absolute, [ref]$uri)) { throw 'Invalid proxy address.' }
    if ($uri.Scheme -ne 'http' -or -not $uri.Host -or $uri.Port -lt 1 -or $uri.UserInfo -or $uri.Query -or $uri.Fragment -or $uri.AbsolutePath -ne '/') {
        throw 'Use an HTTP proxy host and port without credentials, path, query or fragment.'
    }
    $proxy = $uri.GetLeftPart([UriPartial]::Authority)
    $packages = @(Get-AppxPackage -Name OpenAI.Codex | Sort-Object Version -Descending)
    $exe = $null
    foreach ($package in $packages) {
        foreach ($relative in @('app\ChatGPT.exe', 'ChatGPT.exe')) {
            $candidate = Join-Path $package.InstallLocation $relative
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $exe = $candidate; break }
        }
        if ($exe) { break }
    }
    if (-not $exe) { throw 'OpenAI.Codex / ChatGPT.exe not found for the current Windows user.' }
    $env:HTTP_PROXY = $proxy
    $env:HTTPS_PROXY = $proxy
    $env:ALL_PROXY = $proxy
    $env:NO_PROXY = 'localhost,127.0.0.1,::1'
    Start-Process -FilePath $exe -WorkingDirectory (Split-Path -Parent $exe)
}
finally {
    foreach ($name in $names) { [Environment]::SetEnvironmentVariable($name, $saved[$name], 'Process') }
}
