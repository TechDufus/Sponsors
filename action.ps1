using namespace System.Diagnostics.CodeAnalysis

Param(
    [System.Object] $SponsorsPath,

    [System.Object] $ReadmePath,

    [System.Object] $CommitMessage,

    [System.Object] $CommitterUsername,

    [System.Object] $CommitterEmail,

    [ValidateScript( {
            If (($_ -gt 200) -OR ($_ -le 0)) {
                $false
            }
            Else {
                $true
            }
        })]
    [Int] $PhotoPixelLength = 145
)

Begin {
    $isInstalled = Get-Module -Name powershell-yaml -ListAvailable
    If (-Not($isInstalled)) {
        Install-Module powershell-yaml -Force
    }

    #Region Get-CurrentSponsorsSection
    
    Function Get-CurrentSponsorsSection() {
        [CmdletBinding()]
        Param(
            # Specifies a path to one or more locations.
            [Parameter(Mandatory = $true,
                Position = 0,
                ParameterSetName = "Path",
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true,
                HelpMessage = "Path to one or more locations.")]
            [ValidateNotNullOrEmpty()]
            [System.String[]]
            $Users,

            [Parameter(Mandatory = $true,
                Position = 0,
                ParameterSetName = "Path",
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true,
                HelpMessage = "Platform for sponsors.")]
            [ValidateNotNullOrEmpty()]
            [System.String[]]
            $Platform,

            $PixelLength
        )
    
        Process {
            $Users = $Users.split()
            $OutputSPONSORS = [System.Text.StringBuilder]::new()
            $null = $OutputSPONSORS.AppendLine("## $($Platform) Sponsors")
            $null = $OutputSPONSORS.AppendLine("")
            Switch ($Platform) {
                'GitHub' {
                    $LinkTemplate = '[<img src="https://github.com/{0}.png" alt="{0}" width="{1}"/>](https://github.com/{0})'
                }
                'Twitch' {
                    $LinkTemplate = '[![Twitch](https://img.shields.io/badge/{0}-black?logo=twitch)](https://twitch.tv/{0})'
                }
            }
            $Users | Foreach-Object {
                $null = $OutputSPONSORS.AppendLine($($LinkTemplate -f $_, $PixelLength))
            }
            $null = $OutputSPONSORS.AppendLine("")
            $OutputSPONSORS.ToString()
        }
    }
    #EndRegion Get-CurrentSponsorsSection

    #Region Commit-GitRepo
    
    Function Commit-GitRepo() {
        [CmdletBinding()]
        [SuppressMessage('PSUseApprovedVerbs', '')]
        Param(
            [Parameter(Mandatory)]
            [System.Object[]] $CommitMessage,
        
            [Parameter(Mandatory)]
            [System.Object[]] $CommitterUsername,
        
            [Parameter(Mandatory)]
            [System.Object[]] $CommitterEmail
        )
    
        Process {
            git config --local user.name "$CommitterUsername"
            git config --local user.email "$CommitterEmail"
    
            git add .
            git commit -m "$CommitMessage"
            git push
        }
    }
    #EndRegion Commit-GitRepo
}

Process {    
    $Sponsors = Get-Content -Path $SponsorsPath | ConvertFrom-Yaml
    $ReadMeContent = Get-Content -Path $ReadmePath

    $StartPattern = '<!-- SPONSORS-LIST:START -->'
    $StartIndex = (($ReadMeContent | Select-String -Pattern $StartPattern)[0].LineNumber - 1)

    $EndPattern = '<!-- SPONSORS-LIST:END -->'
    $EndIndex = (($ReadMeContent | Select-String -Pattern $EndPattern)[-1].LineNumber - 1)
    
    #TODO: Create Pre section blanking-out logic if SPONSORS starts the file.
    
    $PreSectionContent = $ReadMeContent[0..($StartIndex - 1)]
    # $CurrentSection = $Sponsors[$StartIndex..$EndIndex]

    # If ([System.String]::IsNullOrWhiteSpace($ReadMeContent[-1])) {
    #     $SubtractIndex = 2
    # } Else {
    #     $SubtractIndex = 1
    # }
    $EndOfFileIndex = ($ReadMeContent.Count - 1)
    
    #If section is the end of the file, we need to blank out the Post section.
    If (($EndIndex) -ge $EndOfFileIndex) {
        $PostSectionContent = [System.String]::Empty
    }
    Else {
        $PostSectionContent = $ReadMeContent[($EndIndex + 1)..$EndOfFileIndex]
    }

    $GeneratedSponsorsSection = [System.Text.StringBuilder]::new()
    $null = $GeneratedSponsorsSection.AppendLine('<!-- SPONSORS-LIST:START -->')
    $null = $GeneratedSponsorsSection.AppendLine("# $($Sponsors.MainHeading)")
    $null = $GeneratedSponsorsSection.AppendLine("")
    

    $Sponsors.Platforms | Foreach-Object {
        $getCurrentSponsorsSectionSplat = @{
            Platform    = $_.Keys
            Users       = $_[$_.Keys]
            PixelLength = $PhotoPixelLength
        }
        $null = $GeneratedSponsorsSection.Append($(Get-CurrentSponsorsSection @getCurrentSponsorsSectionSplat))
    }
    $null = $GeneratedSponsorsSection.Append('<!-- SPONSORS-LIST:END -->')
    $GeneratedSponsorsSection = $GeneratedSponsorsSection.ToString()

    Write-Host "Overwriting ReadMe file."
    $AssembledProfile = $PreSectionContent, $GeneratedSponsorsSection, $PostSectionContent | Out-String
    $AssembledProfile.trim() | Out-File $ReadmePath -Force

    $commitGitRepoSplat = @{
        CommitMessage     = $CommitMessage
        CommitterUsername = $CommitterUsername
        CommitterEmail    = $CommitterEmail
    }
    # Commit-GitRepo @commitGitRepoSplat
}    
