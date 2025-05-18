# Windows Reset and Setup Script

This PowerShell script automates the following tasks:
- Optionally resets Windows to factory settings.
- Installs all `.exe` installer files found in the same folder as the script.
- Creates a new local administrator account (with optional username and password).
- **Copies files from a `system` folder (if present) to the new user's profile folders.**
- Logs all actions to a `setup_log.txt` file in the script's folder.

## How It Works

1. **Prompt for Windows Reset:**  
   The script asks if you want to reset the PC. If you choose "Y", it will initiate a Windows reset (removing all apps and settings). If you choose "N", it skips this step.

2. **Install `.exe` Files:**  
   All `.exe` files in the same directory as the script are installed silently (if the installers support silent mode).

3. **Create Local Admin Account:**  
   You are prompted for a username (default: `default`) and password (leave blank for no password). The script creates this user and adds it to the Administrators group.

4. **Copy User Files from `system` Folder:**  
   If a folder named `system` exists in the script's directory, any subfolders (such as `Desktop`, `Documents`, `Videos`, etc.) and their contents will be copied into the corresponding folders in the new user's profile.

5. **Logging:**  
   All actions and results are logged to `setup_log.txt` in the script's folder.

6. **Summary:**  
   At the end, a summary of actions is displayed.

## How To Use

1. **Preparation:**
   - Place the script (`reset_and_setup.ps1`), all desired `.exe` installer files, and (optionally) a `system` folder with user files in the same folder.
   - Open PowerShell as Administrator.

2. **Execution:**
   - Navigate to the script's folder in PowerShell.
   - Run the script:
     ```powershell
     .\reset_and_setup.ps1
     ```
   - Follow the prompts to reset Windows (optional), install applications, create a local admin account, and (if present) copy user files.

## Important Notes

- **Run as Administrator:**  
  The script must be run with administrative privileges.

- **Windows Reset:**  
  If you choose to reset, all apps and settings will be removed. Data loss may occur.

- **Silent Installers:**  
  The script attempts to install `.exe` files silently. If an installer does not support silent mode, it may not install correctly.

- **Copying User Files:**  
  If a `system` folder is present, its subfolders and files will be copied to the new user's profile. Existing files may be overwritten.

- **Security:**  
  Creating an admin account with no password is insecure. Use a strong password whenever possible.

- **Log File:**  
  Check `setup_log.txt` for a detailed log of all actions.

## Disclaimer

Use this script at your own risk. Always back up important data before running system reset operations.