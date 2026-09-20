# ZeroCraft auto-login.
# Types the saved password into the World of Warcraft login screen and presses Enter, as early
# as the login screen will accept it, then watches Wow.exe's network connections to confirm.
#
# Environment (set by the launcher):
#   ZC_PID    process id of Wow.exe
#   ZC_PW     the account password
#   ZC_WOW    the WoW folder (zerocraft_login.log is written there)
#   ZC_WAIT   seconds to wait after the game window appears before the first try (default 1)
#
# WoW 3.3.5a talks to the auth server on port 3724 and to the realm (world server) on 8085.
# A connection to 8085 means "logged in and at the character screen".
# Keystrokes sent before the login screen has loaded are simply dropped, so we try every second
# until the client contacts the auth server.

$ErrorActionPreference = 'SilentlyContinue'
$log = Join-Path $env:ZC_WOW 'zerocraft_login.log'
$t0 = Get-Date
function L($m) { Add-Content -Path $log -Value (('{0,5:N1}s  ' -f ((Get-Date) - $t0).TotalSeconds) + $m) }
Set-Content -Path $log -Value ('ZeroCraft auto-login started ' + $t0.ToString('yyyy-MM-dd HH:mm:ss'))

Add-Type @"
using System; using System.Runtime.InteropServices;
public static class ZcWin {
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
}
"@

$WM_KEYDOWN = 0x0100; $WM_KEYUP = 0x0101; $WM_CHAR = 0x0102
$VK_RETURN = 0x0D; $VK_BACK = 0x08; $VK_ESCAPE = 0x1B
$SC_RETURN = 0x1C; $SC_BACK = 0x0E; $SC_ESCAPE = 0x01

function Press($h, $vk, $scan) {
  # lParam: repeat count 1, scan code in bits 16-23; key-up also sets the transition bits
  [long]$down = 1 -bor ($scan -shl 16)
  [long]$up = $down -bor 0xC0000000
  [void][ZcWin]::PostMessage($h, $WM_KEYDOWN, [IntPtr]$vk, [IntPtr]$down)
  [void][ZcWin]::PostMessage($h, $WM_CHAR, [IntPtr]$vk, [IntPtr]$down)
  [void][ZcWin]::PostMessage($h, $WM_KEYUP, [IntPtr]$vk, [IntPtr]$up)
  Start-Sleep -Milliseconds 15
}
function TypeText($h, $text) {
  foreach ($ch in $text.ToCharArray()) {
    [void][ZcWin]::PostMessage($h, $WM_CHAR, [IntPtr][int]$ch, [IntPtr]1)
    Start-Sleep -Milliseconds 3
  }
}
function Connected($procId, $port) {
  $c = Get-NetTCPConnection -OwningProcess $procId -RemotePort $port -ErrorAction SilentlyContinue |
       Where-Object { $_.State -eq 'Established' -or $_.State -eq 'SynSent' -or $_.State -eq 'CloseWait' }
  return ($null -ne $c)
}
# wait up to $seconds for a realm connection; returns $true when logged in
function WaitRealm($procId, $seconds) {
  $deadline = (Get-Date).AddSeconds($seconds)
  while ((Get-Date) -lt $deadline) {
    if (Connected $procId 8085) { return $true }
    Start-Sleep -Milliseconds 100
  }
  return $false
}

$p = Get-Process -Id ([int]$env:ZC_PID) -ErrorAction SilentlyContinue
if (-not $p) { $p = Get-Process -Name Wow -ErrorAction SilentlyContinue | Select-Object -First 1 }
if (-not $p) { L 'Wow.exe is not running - nothing to do.'; exit }
$procId = $p.Id

# 1. wait for the game window
$end = (Get-Date).AddSeconds(90)
while (-not $p.HasExited -and $p.MainWindowHandle -eq 0 -and (Get-Date) -lt $end) { Start-Sleep -Milliseconds 100; $p.Refresh() }
if ($p.HasExited) { L 'WoW closed before its window appeared.'; exit }
$h = $p.MainWindowHandle
if ($h -eq 0) { L 'No WoW window appeared within 90 seconds.'; exit }
L 'WoW window found.'

# 2. give the login screen a moment, then start trying
$wait = 1; if (-not [int]::TryParse($env:ZC_WAIT, [ref]$wait)) { $wait = 1 }
if ($wait -lt 0) { $wait = 0 }
Start-Sleep -Seconds $wait

$pw = [string]$env:ZC_PW
$maxTries = 20        # about 20-25 seconds of trying
$rejections = 0
for ($try = 1; $try -le $maxTries; $try++) {
  if ($p.HasExited) { L 'WoW was closed.'; exit }
  if (Connected $procId 8085) { L 'Logged in - at the character screen.'; exit }
  [void][ZcWin]::SetForegroundWindow($h)
  if ($try -gt 1) {
    # dismiss any error dialog and clear whatever half-typed password is in the box
    Press $h $VK_ESCAPE $SC_ESCAPE
    for ($i = 0; $i -lt ($pw.Length + 4); $i++) { Press $h $VK_BACK $SC_BACK }
  }
  TypeText $h $pw
  Start-Sleep -Milliseconds 40
  Press $h $VK_RETURN $SC_RETURN

  # 3. did the client contact the auth server within a second?
  $auth = $false
  $deadline = (Get-Date).AddMilliseconds(1200)
  while ((Get-Date) -lt $deadline) {
    if (Connected $procId 8085) { L ('Logged in - at the character screen (try ' + $try + ').'); exit }
    if (Connected $procId 3724) { $auth = $true; break }
    Start-Sleep -Milliseconds 100
  }
  if (-not $auth) { Start-Sleep -Milliseconds 700; continue }   # login screen not ready yet - try again

  L ('Login sent (try ' + $try + '), waiting for the realm...')
  if (WaitRealm $procId 8) { L 'Logged in - at the character screen.'; exit }
  # authenticated but not on a realm: maybe sitting on the realm list
  [void][ZcWin]::SetForegroundWindow($h)
  Press $h $VK_RETURN $SC_RETURN
  if (WaitRealm $procId 5) { L 'Logged in - at the character screen (picked the realm).'; exit }
  # the auth server answered but no realm followed: usually a rejected password
  $rejections++
  if ($rejections -ge 2) { L 'The server rejected the password twice. Log out of the launcher and log in again with the right password. Not retrying.'; exit }
  L 'The server did not accept the login (a half-typed password?). Trying once more.'
  Start-Sleep -Milliseconds 500
}
L ('Gave up after ' + $maxTries + ' tries. If the game loads slowly on this PC, raise the auto-login wait in Settings.')
