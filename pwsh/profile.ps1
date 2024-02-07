<#
    # Initial setup notes

    ## Open profiles in VSCode
    @(
        $PROFILE.AllUsersAllHosts,
        $PROFILE.AllUsersCurrentHost,
        $PROFILE.CurrentUserAllHosts,
        $PROFILE.CurrentUserCurrentHost
    ) | Foreach-object {code -add $_}

    ## Modules
    Install-Module -Name PowerShellGet -Force ; exit
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module PSReadLine
    Install-Module PSReadline -AllowPrerelease -Force
    PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
    Install-Module Microsoft.PowerShell.SecretManagement -Scope CurrentUser -Force
    Install-Module Microsoft.PowerShell.SecretStore -Scope CurrentUser -Force
    Install-Module PSGitHub

    AWS.Tools.Backup
    AWS.Tools.Common
    AWS.Tools.EC2
    AWS.Tools.Installer
    posh-git
    JiraPS
#>


Write-Host 'Loading profile...' -ForegroundColor Cyan


# Module Imports
$modulesToLoad = @(
    'posh-git'
)
foreach ($module in $modulesToLoad) {
    try {
        Import-Module $module -ErrorAction Stop
    }
    catch {
        Write-Host "Module $module has failed to load." -ForegroundColor DarkRed
    }
}


# PSReadline
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -Colors @{ InlinePrediction = '#2F7004' } #green
Set-PSReadLineOption -PredictionViewStyle ListView #you may prefer InlineView


# Get-Syntax
function Get-Syntax {
    <#
        .SYNOPSIS
        Get beautiful syntax for any cmdlet
    #>
    [CmdletBinding()]
    param (
        $Command,
        [switch]
        $PrettySyntax
    )
    $check = Get-Command -Name $Command
    $params = @{
        Name   = if ($check.CommandType -eq 'Alias') {
            Get-Command -Name $check.Definition
        }
        else {
            $Command
        }
        Syntax = $true
    }
    $pretty = $true
    if ($pretty -eq $true) {
        (Get-Command @params) -replace '(\s(?=\[)|\s(?=-))', "`r`n "
    }
    else {
        Get-Command @params
    }
}


# Get-PwshProfilePaths
function Get-PwshProfilePaths {
    $Profile.AllUsersAllHosts
    $Profile.AllUsersCurrentHost
    $Profile.CurrentUserAllHosts
    $Profile.CurrentUserCurrentHost
}


# Custom prompt function
function prompt {
    <#
        .SYNOPSIS
        Custom prompt function.
        .EXAMPLE
        [2022-JUL-30 21:18][..project-starters\aws\aws-backup-automation][main ≡]
        >>
    #>
    $global:promptDateTime = [datetime]::Now
    $Global:promptDate = $global:promptDateTime.ToString('yyyy-MMM-dd').ToUpper()
    $Global:promptTime = $global:promptDateTime.ToString('HH:mm')

    # truncate the current location if too long
    $currentDirectory = $executionContext.SessionState.Path.CurrentLocation.Path
    $consoleWidth = [Console]::WindowWidth
    $maxPath = [int]($consoleWidth / 4.5)
    if ($currentDirectory.Length -gt $maxPath) {
        $currentDirectory = '..' + $currentDirectory.SubString($currentDirectory.Length - $maxPath)
    }
    $global:promptPath = $currentDirectory

    $InGitRepo = Write-VcsStatus
    if ($InGitRepo) {
        Write-Host "[$global:promptDate $global:promptTime]" -ForegroundColor Green -NoNewline
        Write-Host "[$global:promptPath]" -ForegroundColor Magenta -NoNewline
        Write-Host $InGitRepo.Trim() -NoNewline
        "`r`n>>"
    }
    else {
        Write-Host "[$global:promptDate $global:promptTime]" -ForegroundColor Green -NoNewline
        Write-Host "[$global:promptPath]" -ForegroundColor Magenta -NoNewline
        "`r`n>>"
    }
}