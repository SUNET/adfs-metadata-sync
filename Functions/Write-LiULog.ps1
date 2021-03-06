#========================================================================== 
# NAME: Write-LiULog.ps1
#
# DESCRIPTION: Loggs to a file/event viewer
#
# 
# AUTHOR: Johan Peterson
# DATE  : 2012-01-02
#
# PUBLISH LOCATION: C:\Published Powershell Scripts\Functions
#
#=========================================================================
#  Version     Date      	Author        	Note 
#  ----------------------------------------------------------------- 
#   1.0        2012-01-02	Johan Peterson	Initial Release
#   1.1        2012-01-03	Johan Peterson	First Publish
#   1.2        2012-01-03	Johan Peterson	Fixed help, added LastWarning, LastError and added parameters -Underline and -UnderlineChar
#   1.3        2012-01-04	Johan Peterson	Added -Verbose support
#   1.4        2012-01-04	Johan Peterson	Added new function Write-VerboseLiULog
#   1.5        2012-02-02	Johan Peterson	Fixed bug with EventLog and added support for not providing -Screen, -File or -EventLog. See help for more info
#   1.6        2012-02-03	Johan Peterson	Added-Support for $Silent
#   1.7        2012-03-28	Johan Peterson	Added parameters SkipDateTime and ForegroundColor
#   1.8        2012-04-12	Johan Peterson	Fixed a bug with Write-VerboseLiULog
#   1.9        2014-06-05	Johan Peterson (adm)	Fixed Write-VerboseLiULog so it will write to file and eventlog if they are set but no params are chosen
#=========================================================================

function Write-LiULog {
[CmdletBinding(DefaultParametersetName="Default")]
param (        
    [Parameter(Mandatory=$false,
                ParameterSetName="Set",
                ValueFromPipelineByPropertyName=$false)]
    [string]
    #The path to the logfile. This needs to be set once in the script. The path will be stored in a global variable 'LogFilePath'
    $SetLogFilePath,
    [Parameter(Mandatory=$false,
                ParameterSetName="Set",
                ValueFromPipelineByPropertyName=$false)]
    [string]
    #The name of the eventlog. This needs to be set once in the script. The name will be stored in a global variable 'EventLogName'
    $SetEventLogName,
    [Parameter(Mandatory=$false,
                ParameterSetName="Set",
                ValueFromPipelineByPropertyName=$false)]
    [string]
    <#The Source that will be used in the eventlog.
    
    Use New-EventLog -LogName <EventLogName> -Source <NewSource> to add a new source to a eventlog.
    
    This needs to be set once in the script. The name will be stored in a global variable 'EventLogSource'#>
    $SetEventLogSource,
    [Parameter(Mandatory=$false,
                ParameterSetName="Get",
                ValueFromPipelineByPropertyName=$false)]
    [switch]
    #Returns the path to the LogFile.
    $GetLogFilePath,
    [Parameter(Mandatory=$false,
                ParameterSetName="Get",
                ValueFromPipelineByPropertyName=$false)]
    [switch]
    #Returns the name of the EventLog that will be used.
    $GetEventLogName,
    [Parameter(Mandatory=$false,
                ParameterSetName="Get",
                ValueFromPipelineByPropertyName=$false)]
    [switch]
    #Returns the Source of the EventLog that will be used.
    $GetEventLogSource,
    
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]
    #The message to be written in the log...
    $Message,
    
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$true)]
    [int]
    #The EventID if EventLog is used
    $EventID,
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$true)]
    [string]
    #Used in LogFile and on Screen to clarify the message. In EventLog the Level on the event is set to EntryType. Default is Information
    [ValidateSet("Information", "Error", "Warning")]
    $EntryType="Information",
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$true)]
    [switch]
    #If used the EntryType will be set as "Error" the message will be thown as an error. 
    $MajorFault,
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$true)]
    [int]
    #Only for EventLog. Task Category on the event is set to Category. If -Verbose is used, Category will be set to 4
    $Category=1,
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$false)]
    [switch]
    #Used in LogFile and on Screen make the message underlined
    $Underline,
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$false)]
    [char]
    #The char used to make the underline (see parameter Underline). Default is '-'
    $UnderlineChar='-',
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$true)]
    [switch]
    #Use this to get output on the screen
    $Screen,
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$true)]
    [switch]
    #Use this to log to file
    $File,
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$true)]
    [switch]
    #Use this to log to EventLog
    $EventLog,
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$true)]
    [switch]
    #Doesn't write Date and Time in the beginning of the row
    $SkipDateTime,
    [Parameter(Mandatory=$false,
                ParameterSetName="Default",
                ValueFromPipelineByPropertyName=$true)]
    [ConsoleColor]
    #Sets the color the screen-text should be written in
    $ForegroundColor = [ConsoleColor]::Gray
)
       
Begin {
    
    if ($PsCmdlet.ParameterSetName -eq "Set")
    {
        if ($SetLogFilePath -ne [string]::Empty) 
        {
            $FilePath = $SetLogFilePath.SubString(0,$SetLogFilePath.LastIndexOf('\'))
            if (! (Test-Path ($FilePath)))
            {
                Write-Warning "The path `'$FilePath`' doesn't exist! Please create it and try again..."
            }
            else
            {
                Write-Verbose "Setting LogFilePath to `'$SetLogFilePath`'..."
                $global:LogFilePath = $SetLogFilePath                    
            }
        }
        
        if ($SetEventLogName -ne [string]::Empty)
        {
            try
            {
                $TestEventLog = Get-EventLog $SetEventLogName -Newest 1
                
                Write-Verbose "Setting EventLogName to `'$SetEventLogName`'..."
                $global:EventLogName = $SetEventLogName 
            }
            catch
            {
                Write-Warning "The EventLogName provided does not exist! Please try again with another namne..."
            }
        }
        
        if ($SetEventLogSource -ne [string]::Empty)
        { 
            Write-Verbose "Setting EventLogSource to `'$SetEventLogSource`'..."
            $global:EventLogSource = $SetEventLogSource
        }
    }
    elseif ($PsCmdlet.ParameterSetName -eq "Get")
    {
        if ($GetLogFilePath) { Write-Host "LogFilePath: `'$LogFilePath`'" }
        if ($GetEventLogName) { Write-Host "EventLogName: `'$EventLogName`'" }
        if ($GetEventLogSource) { Write-Host "EventLogSource: `'$EventLogSource`'" }
    }
}
Process {
    ### Write main script below ###
    if ($PsCmdlet.ParameterSetName -eq "Default")
    {
        if ($MajorFault) { $EntryType = "Error" }
        if ($verbosePreference -eq "Continue") { $Category = 4 }
        
        $CurrentTime = (Get-Date).ToString()
        
        if (!$Screen.IsPresent -and !$File.IsPresent -and !$EventLog.IsPresent)
        {
            $Screen = $true

            if ($EventLogName -ne $null -and $EventLogSource -ne $null)
            {
                $EventLog = $true
            }

            if ($LogFilePath -ne $null)
            {
                $File = $true
            }
        }
        
        if ($Screen -and -not $MajorFault -and -not $Silent)
        { 
            #Write-Verbose "Logging to Screen..." 
            
            if (!$SkipDateTime) 
            {
                Write-Host "$($CurrentTime): " -ForegroundColor DarkYellow -NoNewline
            }
            
            if ($EntryType -eq "Error")
            { 
                Write-Error $Message
                if ($Underline) { Write-Error "$([string]::Empty.PadLeft($ScreenMessage.Length,$UnderlineChar))" }
            }
            elseif ($EntryType -eq "Warning")
            {
                Write-Warning $Message
                if ($Underline) { Write-Warning "$([string]::Empty.PadLeft($ScreenMessage.Length,$UnderlineChar))" }
            }
            else
            {
                if ($verbosePreference -eq "Continue")
                { 
                    Write-Verbose $Message
                    if ($Underline) { Write-Verbose "$([string]::Empty.PadLeft($ScreenMessage.Length,$UnderlineChar))" }
                }
                else 
                { 
                    Write-Host $Message -ForegroundColor $ForegroundColor
                    if ($Underline) { Write-Host "$([string]::Empty.PadLeft($ScreenMessage.Length,$UnderlineChar))" }
                    
                }
            }
        }
        
        if ($File) 
        {
            if ($LogFilePath -eq [string]::Empty) { Write-Warning "The LogFilePath is not set! Use -SetLogFilePath first!" }
            else
            {
                $FileMessage = ""
                if (!$SkipDateTime) 
                {
                    $FileMessage = "$CurrentTime - "
                }
                 $FileMessage += "$($EntryType): $Message"

                #Write-Verbose "Logging to File `'$LoggFilePath`'..."
                Add-Content -Path $LogFilePath -Value $FileMessage
                if ($Underline) { Add-Content -Path $LogFilePath -Value "$([string]::Empty.PadLeft($FileMessage.Length,$UnderlineChar))" }
            }
        }
        
        if ($EventLog)
        { 
            if ($EventLogName -eq [string]::Empty) { Write-Warning "The SetEventLogName is not set! Use -SetEventLogName first!" }
            elseif ($EventLogSource -eq [string]::Empty) { Write-Warning "The EventLogSource is not set! Use -SetEventLogSource first!" }
            else
            {
                #Write-Verbose "Logging to EventLog `'$EventLogName`' as Source `'$EventLogSource`'..." 
            
                Write-EventLog -LogName $EventLogName -Source $EventLogSource -EventId $EventID -Message $Message -EntryType $EntryType -Category $Category    
            }
        }

        if($EntryType -eq "Warning")
        {
            $global:Warnings++
            $global:LastWarning = $Message
        }
        elseif($EntryType -eq "Error")
        {
            $global:Errors++
            $global:LastError = $Message
        }
        
        if ($MajorFault) { throw $Message }   
    }
}
<#
.SYNOPSIS
Use this cmdlet to add logging to your script. Can log to Screen/File and EventLog

.DESCRIPTION
Start by setting FilePath and/or EventLogName/EventLogSource. The values are stored in global variables and don't need to be set again.

Call Write-LiULog with one or more parameters depending on how much logging needed. 

If a Warning is logged the following global variables will be changed:
$Warnings will increase with 1
$LastWarning will be set to $Message

If an Error is logged the following global variables will be changed:
$Errors will increase with 1
$LastError will be set to $Message

If -MajorFault is provided, EntryType will automatically be set as Error and after logging has been done, the Message will be thrown.

If a variable namned $Silent is used and equals $true in the script calling Write-LiULog, no logging to screen will be done

.EXAMPLE
C:\PS> Write-LiULog -Message "Hello World!"
2012-02-02 16:40:16: Hello World!

-Message parameter are not needed as long as the message is written first

C:\PS> Write-LiULog "Hello World!" -EntryType Warning
WARNING: 2012-02-02 16:41:23: Hello World!

C:\PS> Write-LiULog -SetLogFilePath C:\Logs\myLogfile.txt
C:\PS> Write-LiULog "Hello textfile!" -File -Screen -Underline
2012-02-02 16:46:31: Hello textfile!
------------------------------------
.EXAMPLE
If none of the parameters (-Screen, -File or -EventLog) is provided, all defined ways will be used.
Default will only be the screen, a -SetLogFilePath has been set, the logging will be to screen and file, etc

C:\PS> Write-LiULog -SetLogFilePath C:\Logs\myLogfile.txt
C:\PS> Write-LiULog "Look, I don't use any parameters! :)"
2012-02-02 16:59:46: Look, I don't use any parameters! :)

C:\PS> Get-Content $LogFilePath
2012-02-02 16:46:31 - Information: Hello textfile!
--------------------------------------------------
2012-02-02 16:59:46 - Information: Look, I don't use any parameters! :)

C:\PS> Write-LiULog "Something isn't quite right!" -EntryType Warning
WARNING: 2012-02-02 17:00:45: Something isn't quite right!

C:\PS> Get-Content $LogFilePath
2012-02-02 16:46:31 - Information: Hello textfile!
--------------------------------------------------
2012-02-02 16:59:46 - Information: Look, I don't use any parameters! :)
2012-02-02 17:00:45 - Warning: Something isn't quite right!
C:PS> $Warnings
2
C:PS> $Errors
0
C:PS> $LastWarning
Something isn't quite right!
#>
}

function Write-VerboseLiULog {
[CmdletBinding(SupportsShouldProcess=$true)] 
param (
    [parameter(Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]
    #The message to be written in the log...
    $Message,
    [string]
    #Used in LogFile and on Screen to clarify the message. In EventLog the Level on the event is set to EntryType. Default is Information
    [ValidateSet("Information", "Error", "Warning")]
    $EntryType="Information",
    [switch]
    #Use this to log to EventLog
    $EventLog,
    [switch]
    #Use this to log to file
    $File,
    [int]
    #The EventID if EventLog is used
    $EventID
)
    if ($verbosePreference -eq "Continue")
    { 
        if (!$File.IsPresent -and !$EventLog.IsPresent)
        {
            if ($EventLogName -ne $null -and $EventLogSource -ne $null)
            {
                $EventLog = $true
            }

            if ($LogFilePath -ne $null)
            {
                $File = $true
            }
        }

        if ($EventLog)
        {
            Write-LiULog -Message $Message -EventLog -EventID $EventID -EntryType $EntryType
        }
        
        if($File)
        {
            Write-LiULog -Message $Message -File -EventID $EventID -EntryType $EntryType
        }
        
        Write-LiULog -Message $Message -EntryType $EntryType -Screen
        
    }
<#
.SYNOPSIS
Use this cmdlet to add Verbose-logging to your script. Logging will always be to screen, but can also be done to File and/or EventLog

.DESCRIPTION
Start by setting FilePath and/or EventLogName/EventLogSource with Write-LiULog.

Category will always be set to 4

.EXAMPLE
Scriptfile below (Test-Script.ps1)
---
[CmdletBinding(SupportsShouldProcess=$true)]
param()

Write-VerboseLiULog "This is a verbose message"
---

C:\PS> .\Test-Script.ps1

C:\PS> .\Test-Script.ps1 -Verbose
VERBOSE: This is a verbose message
.EXAMPLE
Scriptfile below (Test-Script.ps1)
---
[CmdletBinding(SupportsShouldProcess=$true)]
param()

Write-LiULog -SetLogFilePath .\myLogfile.txt
Write-VerboseLiULog "This is a verbose message"
---

C:\PS> .\Test-Script.ps1 -File -Verbose
VERBOSE: Setting LogFilePath to '.\myLogfile.txt'...
VERBOSE: 2012-01-04 12:56:50: This is a verbose message

C:\PS> Get-Content .\myLogfile.txt
2012-01-04 12:58:13 - Information: This is a verbose message
#>
}

# SIG # Begin signature block
# MIIQwgYJKoZIhvcNAQcCoIIQszCCEK8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUH/A2FtXDzqenCY6TeoEdJfAN
# FMCggg43MIIEhDCCA2ygAwIBAgIQQhrylAmEGR9SCkvGJCanSzANBgkqhkiG9w0B
# AQUFADBvMQswCQYDVQQGEwJTRTEUMBIGA1UEChMLQWRkVHJ1c3QgQUIxJjAkBgNV
# BAsTHUFkZFRydXN0IEV4dGVybmFsIFRUUCBOZXR3b3JrMSIwIAYDVQQDExlBZGRU
# cnVzdCBFeHRlcm5hbCBDQSBSb290MB4XDTA1MDYwNzA4MDkxMFoXDTIwMDUzMDEw
# NDgzOFowgZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2Fs
# dCBMYWtlIENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8G
# A1UECxMYaHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNF
# UkZpcnN0LU9iamVjdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM6q
# gT+jo2F4qjEAVZURnicPHxzfOpuCaDDASmEd8S8O+r5596Uj71VRloTN2+O5bj4x
# 2AogZ8f02b+U60cEPgLOKqJdhwQJ9jCdGIqXsqoc/EHSoTbL+z2RuufZcDX65OeQ
# w5ujm9M89RKZd7G3CeBo5hy485RjiGpq/gt2yb70IuRnuasaXnfBhQfdDWy/7gbH
# d2pBnqcP1/vulBe3/IW+pKvEHDHd17bR5PDv3xaPslKT16HUiaEHLr/hARJCHhrh
# 2JU022R5KP+6LhHC5ehbkkj7RwvCbNqtMoNB86XlQXD9ZZBt+vpRxPm9lisZBCzT
# bafc8H9vg2XiaquHhnUCAwEAAaOB9DCB8TAfBgNVHSMEGDAWgBStvZh6NLQm9/rE
# JlTvA73gJMtUGjAdBgNVHQ4EFgQU2u1kdBScFDyr3ZmpvVsoTYs8ydgwDgYDVR0P
# AQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wEQYDVR0gBAowCDAGBgRVHSAAMEQG
# A1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9BZGRUcnVz
# dEV4dGVybmFsQ0FSb290LmNybDA1BggrBgEFBQcBAQQpMCcwJQYIKwYBBQUHMAGG
# GWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEFBQADggEBAE1C
# L6bBiusHgJBYRoz4GTlmKjxaLG3P1NmHVY15CxKIe0CP1cf4S41VFmOtt1fcOyu9
# 08FPHgOHS0Sb4+JARSbzJkkraoTxVHrUQtr802q7Zn7Knurpu9wHx8OSToM8gUmf
# ktUyCepJLqERcZo20sVOaLbLDhslFq9s3l122B9ysZMmhhfbGN6vRenf+5ivFBjt
# pF72iZRF8FUESt3/J90GSkD2tLzx5A+ZArv9XQ4uKMG+O18aP5cQhLwWPtijnGMd
# ZstcX9o+8w8KCTUi29vAPwD55g1dZ9H9oB4DK9lA977Mh2ZUgKajuPUZYtXSJrGY
# Ju6ay0SnRVqBlRUa9VEwggSdMIIDhaADAgECAhBVG2jHpqqkVbAsWeBzcxHaMA0G
# CSqGSIb3DQEBBQUAMIGVMQswCQYDVQQGEwJVUzELMAkGA1UECBMCVVQxFzAVBgNV
# BAcTDlNhbHQgTGFrZSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdv
# cmsxITAfBgNVBAsTGGh0dHA6Ly93d3cudXNlcnRydXN0LmNvbTEdMBsGA1UEAxMU
# VVROLVVTRVJGaXJzdC1PYmplY3QwHhcNMDkwNTE4MDAwMDAwWhcNMjAwNTMwMTA0
# ODM4WjA/MQswCQYDVQQGEwJOTDEPMA0GA1UEChMGVEVSRU5BMR8wHQYDVQQDExZU
# RVJFTkEgQ29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEAvXjPMqD+JnO0gMKOn8xtRDmAAruBUlyGbAcwNTwmwEz2XdB5tVq3mg6H
# P6fy2wkYcmpqyVIbIqR5W8nC9LucTI+d5e0YTcnxr/5YdO+8dJLuQD5QhPX/u2yT
# +SdPuDWzvWvTEkVmw36Jj6endaQiLIrmPH1LE/mWIeYFvQNvcyPDJKtCMKcWeZcm
# 7+zg5JyZmDw2QdYA+idE7Q2/JJSrwjRRrAEWp2I67rxnbbY4JzmpfvFuZpmafU7X
# 3ByVknNTn3tXoKGsaWNZx0t4b1SWj7/I0aybCzzhEstva3li5dqu8HkURTiYo1Z7
# OkIy15IKKjW62GmXo1gXvdCl51rwkQIDAQABo4IBPDCCATgwHwYDVR0jBBgwFoAU
# 2u1kdBScFDyr3ZmpvVsoTYs8ydgwHQYDVR0OBBYEFEmEIJjk5sY+BD4SNMwQIP49
# frKhMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMBgGA1UdIAQR
# MA8wDQYLKwYBBAGyMQECAh0wQgYDVR0fBDswOTA3oDWgM4YxaHR0cDovL2NybC51
# c2VydHJ1c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0LmNybDB0BggrBgEFBQcB
# AQRoMGYwPQYIKwYBBQUHMAKGMWh0dHA6Ly9jcnQudXNlcnRydXN0LmNvbS9VVE5B
# ZGRUcnVzdE9iamVjdF9DQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVz
# ZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEFBQADggEBACfGzVKN1RobW7NIBVXAyU+o
# W8Z0801JrkObygehciA8rOcE9ZUexC90YVrFrCidHhmdAYmzWZ9o2eKxe3aU8CIL
# k53WuXn8IPmaYDOrzFgWeMZoYV/PXsQtW/1tQRL5FqdwiSQFKypFtuWF3eqHMWg7
# sQKWOL2ypxuIM/BSe9PjaD0n7Y0r0yChK5AHHXg28oQUqC72LFi5gA8quYi606sJ
# AZ+mTBXNKJFLu9WKYldevZSA53Wmb14qp2cD/MQ9xV0L24MwU+7llIfxK1uEq1+p
# VCHRXhp77+/EvWO+DXcRpEgo6xp9uv8RFkmAPdr2lKXnKow4XO9WsJ+NSBAt8ZEw
# ggUKMIID8qADAgECAhEA/ia/oYcKPdDkAw9agfNfiDANBgkqhkiG9w0BAQUFADA/
# MQswCQYDVQQGEwJOTDEPMA0GA1UEChMGVEVSRU5BMR8wHQYDVQQDExZURVJFTkEg
# Q29kZSBTaWduaW5nIENBMB4XDTE0MDIyNzAwMDAwMFoXDTE3MDIyNjIzNTk1OVow
# gcExCzAJBgNVBAYTAlNFMQ8wDQYDVQQRDAY1ODMgMzAxGDAWBgNVBAgMD8OWc3Rl
# cmfDtnRsYW5kczETMBEGA1UEBwwKTGlua8O2cGluZzEdMBsGA1UECQwUTcOkc3Rl
# ciBNYXR0aWFzIFbDpGcxIDAeBgNVBAoMF0xpbmvDtnBpbmdzIHVuaXZlcnNpdGV0
# MQ8wDQYDVQQLDAZMaVUtSVQxIDAeBgNVBAMMF0xpbmvDtnBpbmdzIHVuaXZlcnNp
# dGV0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv07rSnt2KGK688TC
# /+FWX+P1xgoVOYc5VXxVhIPMKmyR+jXQUM/4dbQgSba8XUqxfDpF4SHPVduAJDWE
# OvcRTXHBndx7teMz/zZGrKiHD8q5bCimFzuuoLFd8ozdlVYJala2JSwjvPeKHRKJ
# JpvwuxP2+1rIaf1MZ7tLDGwIZtC7h9ya9aePavk9ZOjpMtFc3GJS53DWEtRD1G7W
# JItmEE7WkHa5vvaP8q0IrYRqb+Ho1xp7vEeA8XXlmHD0LfPtlcAZ/x4ppoCbbiml
# 7c+Mfirj4jorES8xeahByepxL3iGe0/HNRzi9eOfg63pcl9KPanCArLwNKji42bG
# 76NnUwIDAQABo4IBfDCCAXgwHwYDVR0jBBgwFoAUSYQgmOTmxj4EPhI0zBAg/j1+
# sqEwHQYDVR0OBBYEFCCLCcyve/rwNV05sO4JUTa3d+R/MA4GA1UdDwEB/wQEAwIH
# gDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBEGCWCGSAGG+EIB
# AQQEAwIEEDAYBgNVHSAEETAPMA0GCysGAQQBsjEBAgIdMEIGA1UdHwQ7MDkwN6A1
# oDOGMWh0dHA6Ly9jcmwudGNzLnRlcmVuYS5vcmcvVEVSRU5BQ29kZVNpZ25pbmdD
# QS5jcmwwdQYIKwYBBQUHAQEEaTBnMD0GCCsGAQUFBzAChjFodHRwOi8vY3J0LnRj
# cy50ZXJlbmEub3JnL1RFUkVOQUNvZGVTaWduaW5nQ0EuY3J0MCYGCCsGAQUFBzAB
# hhpodHRwOi8vb2NzcC50Y3MudGVyZW5hLm9yZzAbBgNVHREEFDASgRBhZEBncm91
# cHMubGl1LnNlMA0GCSqGSIb3DQEBBQUAA4IBAQApa+1XWq9yy5djk9G62bJU/cUq
# bF+QFz94tVJddD5kn9++w2JQ3RY1eQXCFcntD9bJndQ1bNla8lNBXvw2d7XwWEjI
# MUkMITs9vYCcIXRvYW3fgPFcLf8IA2hSaUb728f2MDu80RgKoHxNLGaUP8luqGM0
# ZTsi3cOPU7GSkwucabOSbGiSpbWgkkyFnyiZPITo+3NUjXiJ3I2/9r9SeU9G7/Az
# AWMV1JLh/vy55VMFQsVvpXLYAogEoONTiDTZhsXk4mIyhVQeGlDiGEnSZJhuyCZR
# dLhg+fFJ/PYJdOTr6bw6Zpmgk5tVetxVxhMFNl/ea4V7hRw6NCL72EpeXAToMYIB
# 9TCCAfECAQEwVDA/MQswCQYDVQQGEwJOTDEPMA0GA1UEChMGVEVSRU5BMR8wHQYD
# VQQDExZURVJFTkEgQ29kZSBTaWduaW5nIENBAhEA/ia/oYcKPdDkAw9agfNfiDAJ
# BgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAj
# BgkqhkiG9w0BCQQxFgQUMartoeoyksk/OyKMKwgNxG1GQd4wDQYJKoZIhvcNAQEB
# BQAEggEAHqKXriZCPvS0lODbqBs7r+K31W5i12atnLKBREB0bKI8Hev7Mn6wYpNK
# kTNlUd+cFSrgPT+2RzyguQ3dqEqGYk+n0Q+AGtkb4vBI0eseB90BJ8yT0jJjH3/Z
# cFZwAJ/rSpCEM04n06wRvrvxu78oq45+c7Ha2lJS48qRu/mnTqmIOMCMNxXucDSy
# Wm9HPXVS2rZYgN5BHBVUIPISUtbH8vyWaq3pr19t3UaRPQEXD91/J01hQ4poIvGu
# ZN1mo9KEjHKLJnb8kjLfJOrAKqEInbCLW9HLiHQlfmp16SaeWxiE1ZsOXafKlcm5
# 7nxhrT42zDzaZbdlreaVcZLDDZvy3g==
# SIG # End signature block
