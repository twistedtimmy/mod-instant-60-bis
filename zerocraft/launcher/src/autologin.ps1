# ZeroCraft auto-login.
# Types the saved password into the World of Warcraft login screen and presses Enter, as early
# as the login screen will accept it, then watches Wow.exe's network connections to confirm.
#
# Environment (set by the launcher):
#   ZC_PID    process id of Wow.exe
#   ZC_PW     the account password
#   ZC_WOW    the WoW folder (zerocraft_login.log is written there)
#   ZC_WAIT   seconds to wait after the game window appears before the first try (default 1)
#   ZC_RELOG  1 = the server was just restarted under a running client: wait for the client to
#             drop its old connection, dismiss the "disconnected" dialog, then log in again
#   ZC_ENTERWORLD  1 = after reaching the character screen, press Enter to enter the world
#                  with the last played character
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
$relog = ($env:ZC_RELOG -eq '1')
$enterWorld = ($env:ZC_ENTERWORLD -eq '1')

# once at the character screen: optionally walk straight into the world, then finish
function Finish($how) {
  L ('Logged in - at the character screen' + $how + '.')
  if ($enterWorld) {
    Start-Sleep -Milliseconds 2500          # let the character list arrive and select the last character
    [void][ZcWin]::SetForegroundWindow($h)
    Press $h $VK_RETURN $SC_RETURN
    Start-Sleep -Seconds 3
    if (Connected $procId 8085) { L 'Entered the world.' } else { L 'Pressed Enter World but the realm connection dropped.' }
  }
  exit
}

if ($relog) {
  # Never type while the client might still be in the world (Enter would open chat).
  # Wait until its old realm connection is gone, which is when the "disconnected" dialog shows.
  $end = (Get-Date).AddSeconds(60)
  while ((Connected $procId 8085) -and (Get-Date) -lt $end) { Start-Sleep -Milliseconds 300 }
  if (Connected $procId 8085) { L 'The client is still connected to a realm - not a restart? Nothing to do.'; exit }
  Start-Sleep -Milliseconds 1500
  [void][ZcWin]::SetForegroundWindow($h)
  Press $h $VK_RETURN $SC_RETURN             # Okay on "You have been disconnected from the server."
  Start-Sleep -Milliseconds 2500             # the login screen rebuilds itself after that
  L 'Dismissed the disconnect dialog.'
}

$maxTries = 20        # about 20-25 seconds of trying
if ($relog) { $maxTries = 90 }   # the server may still be booting
$rejections = 0
for ($try = 1; $try -le $maxTries; $try++) {
  if ($p.HasExited) { L 'WoW was closed.'; exit }
  if (Connected $procId 8085) { Finish '' }
  [void][ZcWin]::SetForegroundWindow($h)
  if ($try -gt 1) {
    # clear whatever half-typed password is in the box. NEVER press Escape here: on the login
    # screen Escape is "Exit Game". If an error dialog is up, the Enter below dismisses it and
    # the next try types into the password box.
    for ($i = 0; $i -lt ($pw.Length + 4); $i++) { Press $h $VK_BACK $SC_BACK }
  }
  TypeText $h $pw
  Start-Sleep -Milliseconds 40
  Press $h $VK_RETURN $SC_RETURN

  # 3. did the client contact the auth server within a second?
  $auth = $false
  $deadline = (Get-Date).AddMilliseconds(1200)
  while ((Get-Date) -lt $deadline) {
    if (Connected $procId 8085) { Finish (' (try ' + $try + ')') }
    if (Connected $procId 3724) { $auth = $true; break }
    Start-Sleep -Milliseconds 100
  }
  if (-not $auth) { Start-Sleep -Milliseconds 700; continue }   # login screen not ready yet - try again

  L ('Login sent (try ' + $try + '), waiting for the realm...')
  if (WaitRealm $procId 10) { Finish '' }
  # authenticated but not on a realm: maybe sitting on the realm list
  [void][ZcWin]::SetForegroundWindow($h)
  Press $h $VK_RETURN $SC_RETURN
  if (WaitRealm $procId 6) { Finish ' (picked the realm)' }
  # The auth server answered but no realm followed. Right after a server restart the realm
  # shows as offline for a little while, so try again a few times before blaming the password.
  $rejections++
  if ($rejections -ge 4) { L 'Logged in to the auth server four times but never reached the realm. Either the realm is still down or the password is wrong - log out of the launcher and back in. Not retrying.'; exit }
  L 'The realm is not accepting logins yet (or the password was refused). Trying again in 10s.'
  Start-Sleep -Seconds 10
}
L ('Gave up after ' + $maxTries + ' tries. If the game loads slowly on this PC, raise the auto-login wait in Settings.')
