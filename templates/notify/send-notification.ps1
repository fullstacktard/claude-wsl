# Claude Code WSL Notification Script
param(
    [string]$Title = "Claude Code Update",
    [string]$Message = "New activity detected"
)

# Create notification using Windows.UI.Notifications
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]

# Clean and escape text for proper display
# Remove escape sequences and control characters (but keep Unicode/emoji)
# Only remove actual control characters (0x00-0x1F and 0x7F), not all non-ASCII
$Title = $Title -replace '\\[nrt]', ' ' -replace '\s+', ' ' -replace '[\x00-\x1F\x7F]', '' -replace '^\s+|\s+$', ''
$Message = $Message -replace '\\[nrt]', ' ' -replace '\s+', ' ' -replace '[\x00-\x1F\x7F]', '' -replace '^\s+|\s+$', ''

# Ensure message isn't empty after cleaning
if ([string]::IsNullOrWhiteSpace($Message)) {
    $Message = "Response ready"
}

# Strip markdown formatting (Windows toast doesn't support markdown)
$Message = $Message -replace '\*\*([^\*]+)\*\*', '$1'  # Remove **bold**
$Message = $Message -replace '\*([^\*]+)\*', '$1'      # Remove *italic*
$Message = $Message -replace '__([^_]+)__', '$1'       # Remove __bold__
$Message = $Message -replace '_([^_]+)_', '$1'         # Remove _italic_
$Message = $Message -replace '`([^`]+)`', '$1'         # Remove `code`
$Message = $Message -replace '\[([^\]]+)\]\([^\)]+\)', '$1'  # Remove [links](url)

# Escape special characters for XML
$TitleEscaped = [System.Security.SecurityElement]::Escape($Title)
$MessageEscaped = [System.Security.SecurityElement]::Escape($Message)

# XML template for toast notification
$template = @"
<toast activationType="protocol">
    <visual>
        <binding template="ToastGeneric">
            <text hint-style="title">$TitleEscaped</text>
            <text hint-maxLines="3">$MessageEscaped</text>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.Default" />
</toast>
"@

$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($template)

# Create and show toast
$toast = New-Object Windows.UI.Notifications.ToastNotification $xml

# Use timestamp to ensure each notification is unique and stacks
$timestamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
$toast.Tag = "ClaudeCode-$timestamp"
# Don't set Group - this allows notifications to stack instead of replacing each other

# Set expiration time to auto-remove from Action Center after 10 seconds
$toast.ExpirationTime = [DateTimeOffset]::Now.AddSeconds(10)

# Suppress from Action Center (notification will show as popup but not be pinned)
$toast.SuppressPopup = $false

# Try multiple app IDs in order of preference
# Use our custom Claude Code app ID first for branded notifications
$appIds = @(
    'Windows.SystemToast.ClaudeCode',  # Custom Claude Code app ID (preferred)
    'Microsoft.WindowsTerminal_8wekyb3d8bbwe!App',  # Windows Terminal
    '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'   # PowerShell (fallback)
)

$success = $false
$usedAppId = $null
foreach ($appId in $appIds) {
    try {
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
        # Success
        $success = $true
        $usedAppId = $appId
        break
    } catch {
        # Try next app ID
        continue
    }
}

if (-not $success) {
    # Fail silently to avoid hook errors
    exit 1
}

# Log which App ID was used (for debugging)
$debugLog = "$env:TEMP\claude-notification-debug.log"
"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Notification sent with App ID: $usedAppId" | Out-File -Append -FilePath $debugLog
