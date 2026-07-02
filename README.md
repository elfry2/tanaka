# tanaka
A PowerShell script to effortlessly install common web development tools, to support common workflows, using common techniques. Written with those who prefer to easily work with others in mind. Powered by WinGet.

Code written by Gemini 3.1 Pro Extended. The conversation can be found on [https://share.gemini.google/BAcGlX45guxU](https://share.gemini.google/BAcGlX45guxU).

The script installs:
- Git
- GitHub CLI
- XAMPP 8.2
- Composer
- Visual Studio Code
- NodeJS LTS
- MongoDB LTS
- MongoDB Compass

## Installation
On PowerShell 5.1+ with administrative privileges on Windows, execute (can be pasted at once)
```powershell
git clone https://github.com/elfry2/tanaka
cd tanaka
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
./Install.ps1
```
