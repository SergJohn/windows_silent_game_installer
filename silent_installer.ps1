# Windows Silent Game Installer - PowerShell version
# Compatible with PowerShell 2.0 (Windows 7+)

# Only use these flags for .exe installers (Inno Setup)
$SILENT_FLAGS = "/VERYSILENT /SUPPRESSMSGBOXES"

function Run-InstallerSilent {
    param(
        [string]$InstallerPath
    )

    $ext = [System.IO.Path]::GetExtension($InstallerPath).ToLower()

    if ($ext -eq ".msi") {
        $cmd = "msiexec"
        $args = @("/i", "`"$InstallerPath`"", "/qn", "/norestart")
    } else {
        # All .exe files use the same Inno Setup flags
        $cmd = "`"$InstallerPath`""
        $args = $SILENT_FLAGS -split " "
    }

    Write-Host "Running: $cmd $($args -join ' ')"

    try {
        if ($ext -eq ".msi") {
            $proc = Start-Process -FilePath $cmd -ArgumentList $args -Wait -PassThru
        } else {
            $proc = Start-Process -FilePath $InstallerPath -ArgumentList $args -Wait -PassThru
        }

        if ($proc.ExitCode -eq 0) {
            Write-Host "  -> Installed successfully"
            return $true
        } else {
            Write-Host "  -> Installer returned non-zero code: $($proc.ExitCode)"
            return $false
        }
    } catch {
        Write-Host "  -> Failed to run installer: $_"
        return $false
    }
}

# ===== Main =====
Write-Host "=== Auto Silent Game Installer (Inno Setup Flags Only) ==="

$drive = Read-Host "Enter the external drive letter (e.g., E)"
$drive = $drive.Trim().ToUpper()

# IMPORTANT_1: Target folder needs to be named: "games"
$gamesFolder = "${drive}:\games"

if (-not (Test-Path $gamesFolder)) {
    Write-Host "[ERROR] Folder not found: $gamesFolder"
    exit 1
}

$logFile = "install_log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value ""
Add-Content -Path $logFile -Value "=== Run at $timestamp ==="

# Recursively find all .exe and .msi installers
$installers = @(Get-ChildItem -Path $gamesFolder -Recurse -Include "*.exe","*.msi" -ErrorAction SilentlyContinue)

if ($installers.Count -eq 0) {
    Write-Host "No installers found in 'games' folder."
    exit 0
}

Write-Host "Found $($installers.Count) installers. Starting silent installation..."
Write-Host ""

for ($i = 0; $i -lt $installers.Count; $i++) {
    $installer = $installers[$i]
    $num = $i + 1
    Write-Host "[$num/$($installers.Count)] Installing: $($installer.FullName)"
    Add-Content -Path $logFile -Value "Installing: $($installer.FullName)"

    $success = Run-InstallerSilent -InstallerPath $installer.FullName
    Add-Content -Path $logFile -Value "Success: $success"
}

Write-Host ""
Write-Host "All installers processed."
Add-Content -Path $logFile -Value "=== Done ==="
