# tanaka
A PowerShell script to effortlessly install common web development tools, to support common workflows, using common techniques. Written with those who prefer to easily work with others in mind. Powered by WinGet.

Code written by Gemini Pro. The conversation can be found on [https://gemini.google.com/share/92662e71bea4](https://gemini.google.com/share/92662e71bea4).

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
On PowerShell 5.1+ with administrative privileges on Windows, execute (can be pasted at once)
```powershell
git clone https://github.com/elfry2/tanaka
cd tanaka
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
./Install.ps1
```
