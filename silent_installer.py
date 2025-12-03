import os
import subprocess
from pathlib import Path
from datetime import datetime

# Only use these flags for .exe installers (Inno Setup)
SILENT_FLAGS = "/VERYSILENT /SUPPRESSMSGBOXES"

def run_installer_silent(installer):
    """Run installer with only the specified silent flags."""
    try:
        if installer.suffix.lower() == ".msi":
            cmd = f'msiexec /i "{installer}" /qn /norestart'
        else:  # All .exe files use the same Inno Setup flags
            cmd = f'"{installer}" {SILENT_FLAGS}'

        print(f"Running: {cmd}")
        result = subprocess.run(cmd, shell=True)
        if result.returncode == 0:
            print(f"  → Installed successfully")
            return True
        else:
            print(f"  → Installer returned non-zero code: {result.returncode}")
            return False
    except Exception as e:
        print(f"  → Failed to run installer: {e}")
        return False

def main():
    print("=== Auto Silent Game Installer (Inno Setup Flags Only) ===")
    drive = input("Enter the external drive letter (e.g., E): ").strip().upper()
    # IMPORTANT_1: Target folder needs to be named: "games"
    games_folder = Path(f"{drive}:\\games")
    if not games_folder.exists():
        print(f"[ERROR] Folder not found: {games_folder}")
        return

    log_file = Path("install_log.txt")
    with log_file.open("a", encoding="utf-8") as log:
        log.write(f"\n=== Run at {datetime.now()} ===\n")
        installers = list(games_folder.rglob("*.exe")) + list(games_folder.rglob("*.msi"))

        if not installers:
            print("No installers found in 'games' folder.")
            return

        print(f"Found {len(installers)} installers. Starting silent installation...\n")
        for i, installer in enumerate(installers, start=1):
            print(f"[{i}/{len(installers)}] Installing: {installer}")
            log.write(f"Installing: {installer}\n")
            success = run_installer_silent(installer)
            log.write(f"Success: {success}\n")

        print("\nAll installers processed.")
        log.write("=== Done ===\n")

if __name__ == "__main__":
    if os.name != "nt":
        print("This script is for Windows only.")
    else:
        main()
