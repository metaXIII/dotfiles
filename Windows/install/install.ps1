[console]::InputEncoding = [System.Text.Encoding]::UTF8
[console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Installation with winget

function Install-WithWinget {
    param(
        [string]$WingetId
    )
    winget list --id $WingetId --exact -e 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[✅] $WingetId is already installed." -ForegroundColor Green
    }
    else {
        Write-Host "[...] Installation of $WingetId..." -ForegroundColor Cyan
        winget install --id $WingetId --silent --accept-source-agreements --accept-package-agreements
    }
}

Install-WithWinget Git.Git
Install-WithWinget Neovim.Neovim
Install-WithWinget Bitwarden.Bitwarden
Install-WithWinget Brave.Brave
Install-WithWinget Obsidian.Obsidian
Install-WithWinget Spotify.Spotify
Install-WithWinget Microsoft.Powershell
Install-WithWinget JanDeDobbeleer.OhMyPosh
Install-WithWinget Mozilla.Firefox
Install-WithWinget GitHub.cli
Install-WithWinget OpenWhisperSystems.Signal
Install-WithWinget Valve.Steam
Install-WithWinget Proton.ProtonMailBridge
Install-WithWinget Proton.ProtonVPN
Install-WithWinget Docker.DockerDesktop
Install-WithWinget Cyanfish.NAPS2
Install-WithWinget 7zip.7zip
Install-WithWinget Kopia.KopiaUI
Install-WithWinget Proton.ProtonDrive

Write-Host "Installation of winget software done [✅]"

# Scoop installation
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop is not installed. Installation in progress..."
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}
else {
    Write-Host "Scoop is already installed. Skipped Steps."
}

Write-Host "Installation of scoop done [✅]"

Install-Module -Name Terminal-Icons -Scope CurrentUser

# Configuration of Windows Terminal 

$newScheme = [PSCustomObject]@{
    name                = "tokyonight-storm"
    background          = "#24283B"
    black               = "#1D202F"
    blue                = "#7AA2F7"
    brightBlack         = "#414868"
    brightBlue          = "#7AA2F7"
    brightCyan          = "#7DCFFF"
    brightGreen         = "#9ECE6A"
    brightPurple        = "#BB9AF7"
    brightRed           = "#F7768E"
    brightWhite         = "#C0CAF5"
    brightYellow        = "#E0AF68"
    cursorColor         = "#C0CAF5"
    cyan                = "#7DCFFF"
    foreground          = "#C0CAF5"
    green               = "#9ECE6A"
    purple              = "#BB9AF7"
    red                 = "#F7768E"
    selectionBackground = "#364A82"
    white               = "#A9B1D6"
    yellow              = "#E0AF68"
}

$localAppData = $env:LOCALAPPDATA
$terminalPath = Get-ChildItem -Path "$localAppData\Packages\Microsoft.WindowsTerminal*\LocalState\settings.json" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
if ($terminalPath) {
    Write-Host "[...] Windows Terminal configuration found. Adding scheme..." -ForegroundColor Cyan
    $jsonRaw = Get-Content -Raw -Path $terminalPath
    $jsonClean = $jsonRaw -replace '(?m)^\s*//.*$', ''
    $config = $jsonClean | ConvertFrom-Json
    if ($null -eq $config.schemes) {
        $config | Add-Member -MemberType NoteProperty -Name "schemes" -Value @()
    }
    $alreadyExists = $config.schemes | Where-Object { $_.name -eq $newScheme.name }
    if (-not $alreadyExists) {
        $config.schemes += $newScheme
        $config | ConvertTo-Json -Depth 10 | Set-Content -Path $terminalPath -Encoding UTF8
        Write-Host "[✓] 'tokyonight-storm' theme successfully added to Windows Terminal!" -ForegroundColor Green
    }
    else {
        Write-Host "[✓] 'tokyonight-storm' theme is already installed." -ForegroundColor Green
    }
}
else {
    Write-Warning "Could not locate Windows Terminal configuration file."
}

# Ajout du lien vers user_profile.ps1 (For Windows PowerShell v5 & PowerShell v7)

# 1. Récupération dynamique du vrai dossier Documents
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
$documentsPath = (Get-ItemProperty -Path $registryPath).Personal
$resolvedDocuments = [System.Environment]::ExpandEnvironmentVariables($documentsPath)

# 2. Définition des chemins de profils pour les deux versions
$profilePaths = @(
    (Join-Path $resolvedDocuments "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"), # v5
    (Join-Path $resolvedDocuments "PowerShell\Microsoft.PowerShell_profile.ps1")        # v7
)

$sourceLine = ". `$env:USERPROFILE\.config\powershell\user_profile.ps1"

# 3. Boucle pour configurer chaque profil
foreach ($profPath in $profilePaths) {
    $profDir = Split-Path -Parent $profPath
    
    if (-not (Test-Path $profDir)) {
        New-Item -ItemType Directory -Path $profDir -Force | Out-Null
    }

    if (-not (Test-Path $profPath)) {
        New-Item -ItemType File -Path $profPath -Force | Out-Null
    }

    $profileContent = Get-Content -Path $profPath -ErrorAction SilentlyContinue
    if ($profileContent -notcontains $sourceLine) {
        Write-Host "[...] Linking user_profile.ps1 to ($($profDir | Split-Path -Leaf))..." -ForegroundColor Cyan
        Add-Content -Path $profPath -Value $sourceLine -Encoding UTF8
        Write-Host "[✓] Profile successfully linked!" -ForegroundColor Green
    }
    else {
        Write-Host "[✓] user_profile.ps1 is already linked in $($profDir | Split-Path -Leaf)." -ForegroundColor Green
    }
}


# Configuration of Zen.toml
$configDir = Join-Path $HOME ".config\powershell"
$targetFile = Join-Path $configDir "zen.toml"

$tomlContent = @'
console_title_template = '{{ .Shell }} in {{ .Folder }}'
version = 3
final_space = true

[secondary_prompt]
  template = '❯❯ '
  foreground = 'magenta'
  background = 'transparent'

[transient_prompt]
  template = '❯ '
  background = 'transparent'
  foreground_templates = ['{{if gt .Code 0}}red{{end}}', '{{if eq .Code 0}}magenta{{end}}']

[[blocks]]
  type = 'prompt'
  alignment = 'left'
  newline = true

  [[blocks.segments]]
    template = '{{ .Path }}'
    foreground = 'blue'
    background = 'transparent'
    type = 'path'
    style = 'plain'

    [blocks.segments.properties]
      style = 'full'

  [[blocks.segments]]
    template = ' {{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} <cyan>{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}</>'
    foreground = 'p:grey'
    background = 'transparent'
    type = 'git'
    style = 'plain'

    [blocks.segments.properties]
      branch_icon = ''
      commit_icon = '@'
      fetch_status = true

[[blocks]]
  type = 'rprompt'
  overflow = 'hidden'

  [[blocks.segments]]
    template = '{{ .FormattedMs }}'
    foreground = 'yellow'
    background = 'transparent'
    type = 'executiontime'
    style = 'plain'

    [blocks.segments.properties]
      threshold = 5000

[[blocks]]
  type = 'prompt'
  alignment = 'left'
  newline = true

  [[blocks.segments]]
    template = '❯'
    background = 'transparent'
    type = 'text'
    style = 'plain'
    foreground_templates = ['{{if gt .Code 0}}red{{end}}', '{{if eq .Code 0}}magenta{{end}}']
'@

if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

if (-not (Test-Path $targetFile)) {
    Write-Host "[...] Creating zen.toml configuration file..." -ForegroundColor Cyan
    [System.IO.File]::WriteAllText($targetFile, $tomlContent)
    Write-Host "[✓] zen.toml successfully created!" -ForegroundColor Green
}
else {
    Write-Host "[✓] zen.toml already exists." -ForegroundColor Green
}


# Configuration of user_profile.ps1

$configDir = Join-Path $HOME ".config\powershell"
$targetFile = Join-Path $configDir "user_profile.ps1"

$profileContent = @'
# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
$separator = "----------------------------------------------------------------------"
# Prompt
oh-my-posh init pwsh --config $HOME'/.config/powershell/zen.toml' | Invoke-Expression
# Module
Import-Module Terminal-Icons
# Alias
Set-Alias apt scoop
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias grep findstr
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias g git
Set-Alias l ll
Set-Alias touch New-Item
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteCharOrExit
if ($PSVersionTable.PSVersion.Major -ge 7) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}

function aze($number) {
    if ($number) {
        git add .
        m("fix")
        git rebase -i HEAD~$number
        git push -f
    }
    else {
        git add . 
        m("fix")
        git rebase -i HEAD~2 
        git push -f
    }
}

function backup($argument) {
    $date = Get-date -Format 'yyyy_MM_dd'
    if ($argument -eq "wsl") {
        $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
        $documentsPath = (Get-ItemProperty -Path $registryPath).Personal
        $resolvedDocuments = [System.Environment]::ExpandEnvironmentVariables($documentsPath)
        $directory = Join-Path $resolvedDocuments "BackUp\"
        if (-not (Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }

        $fileName = Join-Path $directory ("fedora_back_up-" + $date + ".tar")
        
        if (Test-Path -path $fileName) {
            Write-Output "file exist -- Abort back up WSL"
        }
        else {
            $count_backup = Get-ChildItem $directory -File | Measure-Object | ForEach-Object { $_.Count }
            if ($count_backup -gt 4 ) {
                Write-Output "WSL ------- There is more than 5 saves"
                $files = Get-ChildItem $directory -File | Sort-Object LastWriteTime
                $concerned_file = $files[0].Name
                Remove-Item -Force -Recurse -Verbose (Join-Path $directory $concerned_file)
                Write-Output "Back up was successfully removed"
                Write-Output $separator
                Write-Output ""
                wsl --export FedoraLinux-44 $fileName
            }
            else {
                wsl --export FedoraLinux-44 $fileName
            }
            Write-Output "WSL Export Successfully Finished"
            Write-Output $separator
        }
    }
    else {
        Write-Output "no argument specified"
    }
}
function bye() {
    shutdown -s -t 0
}
function checkout($branchName) {
    git checkout $branchName
}
function config() {
    code $env:USERPROFILE/.config
}
function create($subject, $content) {
    if ($subject -eq "branch") {
        pull
        git checkout -b $content
    }
}
function dev() {
    git checkout develop
}
function fix() {
    git pull --rebase origin master 
    git push -f
}
function gitconfig() {
    vim $HOME/.gitconfig
}
function gg() {
    git push -f
}
function gs() {
    git status
}
function la() {
    Get-ChildItem -Force
}
function m($message, $commitMessage) {
    if ($commitMessage) {
        git add .
        git commit -am $message -m $commitMessage 
        git push    
    }
    else {
        git add . 
        git commit -am $message 
        git push
    }
}
function master() {
    git checkout master
}
function open($path) {
    explorer $path
}
function pull() {
    git pull
}
function re() {
    git checkout HEAD -- ./*
}
function rebase($number) {
    if ($number) {
        git rebase -i HEAD~$number
        git push -f
    }
    else {
        git rebase -i HEAD~2
        git push -f
    }
}
function reboot() {
    shutdown /f /s /t 0
}
function rmf($path) {
    Remove-Item -Force -Recurse -Verbose $path
}
function status() {
    git status
}
function uninstall($app) {
    winget uninstall $app
    winget install $app
}
function update() {
    Write-Output "back up WSL"
    Write-Output $separator
    backup "wsl"
    Write-Output "back up WSL"
    Write-Output $separator
    Write-Output "upgrade via Winget"
    winget upgrade --all
    Write-Output "upgrade via scoop"
    Write-Output $separator
    apt update *
}
function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
'@

if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

if (-not (Test-Path $targetFile)) {
    Write-Host "[...] Creating user_profile.ps1 profile file..." -ForegroundColor Cyan
    Set-Content -Path $targetFile -Value $profileContent -Encoding UTF8
    Write-Host "[✓] user_profile.ps1 successfully created!" -ForegroundColor Green
}
else {
    Write-Host "[✓] user_profile.ps1 already exists." -ForegroundColor Green
}


Write-Host "Missing Manual Installation of : "
Write-Host "Nvidia App" -ForegroundColor Red
Write-Host "VSCode" -ForegroundColor Red
Write-Host "Romstation" -ForegroundColor Red
Write-Host "Vmware Workstation" -ForegroundColor Red
