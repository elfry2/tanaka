# tanaka
A PowerShell script to effortlessly install common web development tools, to support common workflows, using common techniques. Written with those who prefer to easily work with others in mind. Powered by WinGet.

The script installs:
- Git
- GitHub CLI
- XAMPP 8.2
- Visual Studio Code
- NodeJS LTS
- MongoDB LTS
- MongoDB Compass
- Composer

## Installation
Works on PowerShell 5.* on Windows, but you might want [PowerShell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.6).

On PowerShell with administrative privileges on Windows, execute (can be pasted at once)
```powershell
git clone https://github.com/elfry2/tanaka
cd tanaka
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
./Install.ps1
```
