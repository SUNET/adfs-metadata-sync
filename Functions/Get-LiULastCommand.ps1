#========================================================================== 
# NAME: Get-LiULastCommand.ps1
#
# DESCRIPTION: Copies the last (or chosen command from history) PS command to the clipboard
#
# 
# AUTHOR: Johan Peterson (adm)
# DATE  : 2015-06-04
#
# PUBLISH LOCATION: C:\Published Powershell Scripts\Functions
#
#=========================================================================
#  Version     Date      	Author              	Note 
#  ----------------------------------------------------------------- 
#   1.0        2015-06-04	Johan Peterson (adm)	Initial Release
#   1.1        2015-06-04	Johan Peterson (adm)	First release
#   1.2        2015-06-04	Johan Peterson (adm)	Added parametersets and added support for negative id:s
#=========================================================================

<#
.Synopsis
   Copies the last command to the clipboard
.DESCRIPTION
   Copies the last (or chosen command from history) PS command to the clipboard
.EXAMPLE
   Get-LiULastCommand
   Last command (Write-Pretty -Key "I...) is now in clipboard...
.EXAMPLE
   Get-LiULastCommand 5
   Command with id '5' (Get-LiUAnswer "Are y...) is now in clipboard...

   This example copies command with id 5 to the clipboard.
   To list the command history, run Get-History or Get-LiULastCommand -List
.EXAMPLE
   Get-LiULastCommand -4
   Command with id '145' (Write-LiULog "Get-Li...) is now in clipboard...

   This example copies the 4th last command with clipboard.
   To list the command history, run Get-History or Get-LiULastCommand -List
#>

function Get-LiULastCommand {
[CmdletBinding(DefaultParameterSetName = 'Id')]

param (        
    [Parameter(ParameterSetName='Id',
                Mandatory=$false,
                Position=0)]
    [int]$Id,
    #The ID for the command in the command history (Get-History shows all command history)
    [Parameter(ParameterSetName='List',
                Mandatory=$false,
                Position=0)]
    [switch]$List
    #Lists the command history (equals to Get-History)
)
       
#Fix encoding so when piping tp clip.exe it will have the right encoding
if ($OutputEncoding -ne [Console]::OutputEncoding)
{
    $OutputEncoding = [Console]::OutputEncoding 
}


$Command = $null

if ($PSBoundParameters.ContainsKey('Id'))
{
    try 
    {
        if ($Id -ge 0)
        {
            $Command = Get-History -Id $Id | Select -ExpandProperty CommandLine 
            Write-Host "Command with id `'$Id`' " -ForegroundColor Green -NoNewline
        }
        else
        {
            $LastID = Get-History | Select -Last 1 -ExpandProperty Id #This command also gets into history
            $Command = Get-History -Id ($LastID + $Id -1) | Select -ExpandProperty CommandLine #Remove the above command with -1
            Write-Host "Command with id `'$(($LastID + $Id -1))`' " -ForegroundColor Green -NoNewline
        }
    }
    catch
    {
        Write-Warning "Get-History doesn't contain the Id `'$Id`'"
    }
}
elseif ($List.IsPresent)
{
    Get-History
}
else
{
    $Command = Get-History | Select -Last 1 -ExpandProperty CommandLine
    Write-Host "Last command " -ForegroundColor Green -NoNewline
}

if ($Command)
{
    $Command | clip.exe
    if ($Command.Length -ge 20)
    {
        Write-Host "($($Command.Substring(0,20))...)"  -NoNewline
    }
    else
    {
        Write-Host "($Command)" -NoNewline
    }
    Write-Host " is now in clipboard..." -ForegroundColor Green 
}
}



# SIG # Begin signature block
# MIIQwgYJKoZIhvcNAQcCoIIQszCCEK8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUApQUP0wxIITPCSAqBsk4Px9S
# 4Ryggg43MIIEhDCCA2ygAwIBAgIQQhrylAmEGR9SCkvGJCanSzANBgkqhkiG9w0B
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
# BgkqhkiG9w0BCQQxFgQUtamF7mNsyQ3U0iTey00aoU2fh/EwDQYJKoZIhvcNAQEB
# BQAEggEASwlMVas/vQexIa2KSczT7fV/C0DsNBuD7pXYIGTXWCuogR7OJ97vNqw7
# zbWUnkMXJCKhCBkDDAnjCMNrYs0Hs4z3vJyO4pFt81vcyBqjs/K2dQ1jrPOIwBZH
# OQfgbjaBVjP8EfY2bs+/hLAfaUKgfpA9I4ZtlgFyMhYHsgX9aNw346l5NgHc+PK1
# h6cvSD1zWfvR5Ug/tM87kUyWi2VKNW4ZPJPfzNdsPkYgedhw/CbX3X/KORkN+Cva
# oNFCGEq5OGXl/U1ccMgcmTa96qfeoOANeBz5AjLr0FoN9gqIg7kgrnABimDROiv3
# NSC2adZTZ2HYaJVm3KGzmR6znmCijw==
# SIG # End signature block
