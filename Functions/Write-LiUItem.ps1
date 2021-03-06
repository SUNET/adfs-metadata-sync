#========================================================================== 
# NAME: Write-LiUItem.ps1
#
# DESCRIPTION: Writes text to host. Should be used to easily write output
#              like: "Working with 'johpe12'... Done!"
#
# 
# AUTHOR: Johan Peterson (adm)
# DATE  : 2016-02-05
#
# PUBLISH LOCATION: C:\Published Powershell Scripts\Functions
#
#=========================================================================
#  Version     Date      	Author              	Note 
#  ----------------------------------------------------------------- 
#   1.0        2016-02-05	Johan Peterson (adm)	Initial Release
#   1.1        2016-02-05	Johan Peterson (adm)	First publish
#=========================================================================

<#
.Synopsis
   Use this cmdlet to write output while looping whough a collection
.DESCRIPTION
   Writes text to host. Should be used to easily write output like: 
   "Working with '[item]'... Done!"
.EXAMPLE
   Write-LiUItem "Working with" "ComputerX" "..."
   Working with 'ComputerX' ...
   Write-LiUItem -Result Done
    Done!
#>


function Write-LiUItem {
[CmdletBinding(DefaultParameterSetName='Text')]
param (
    [Parameter(Mandatory=$true, 
               Position=0,
               ParameterSetName='Text')]
    [string]
    #The first part of the output (before the item text)
    $PreString,
    [Parameter(Mandatory=$true, 
               Position=1,
               ParameterSetName='Text')]
    [string]
    #The part in the output written inside the quotation marks
    $Item,
    [Parameter(Mandatory=$false, 
               Position=2,
               ParameterSetName='Text')]
    [string]
    #The last part of the output (after the item text)
    $PostString,
    [Parameter(Mandatory=$false, 
               ParameterSetName='Text')]
    [ConsoleColor]
    #The color of the first part of the output (before the item text)
    $PreColor = [System.Console]::ForegroundColor,
    [Parameter(Mandatory=$false, 
               ParameterSetName='Text')]
    [ConsoleColor]
    #The color of the part written inside the quotation marks
    $ItemColor = [ConsoleColor]::Yellow,
    [Parameter(Mandatory=$false, 
               ParameterSetName='Text')]
    [ConsoleColor]
    #The color of first part of the output (before the item text)
    $PostColor = [System.Console]::ForegroundColor,
    [Parameter(ParameterSetName='Result')]
    [ValidateSet("Done", "Warning", "Error", "Skipped", "None")]
    [string]
    #The result output
    $Result
)

    if ($PSCmdlet.ParameterSetName -eq 'Text')
    {
        Write-Host "$PreString `'" -ForegroundColor $PreColor -NoNewline
        Write-Host "$Item`' " -ForegroundColor $ItemColor -NoNewline
        Write-Host "$PostString" -ForegroundColor $PostColor -NoNewline
    }

    if ($PSCmdlet.ParameterSetName -eq 'Result')
    {
        switch ($Result)
        {
            'Done' { Write-Host " Done!" -ForegroundColor Green }
            'Warning' { Write-Host " Warning!" -ForegroundColor Yellow }
            'Error' { Write-Host " Error!" -ForegroundColor Red }
            'Skipped' { Write-Host " Skipped!" -ForegroundColor Cyan }
            'None' { Write-Host " " }
        }
    }
}

# SIG # Begin signature block
# MIIXpgYJKoZIhvcNAQcCoIIXlzCCF5MCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIDVyC21o8wMAArfYSk79uRzA
# heugghLUMIIEhDCCA2ygAwIBAgIQQhrylAmEGR9SCkvGJCanSzANBgkqhkiG9w0B
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
# Ju6ay0SnRVqBlRUa9VEwggSZMIIDgaADAgECAg8WiPA5JV5jjmkUOQfmMwswDQYJ
# KoZIhvcNAQEFBQAwgZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UE
# BxMOU2FsdCBMYWtlIENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29y
# azEhMB8GA1UECxMYaHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRV
# VE4tVVNFUkZpcnN0LU9iamVjdDAeFw0xNTEyMzEwMDAwMDBaFw0xOTA3MDkxODQw
# MzZaMIGEMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVy
# MRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEq
# MCgGA1UEAxMhQ09NT0RPIFNIQS0xIFRpbWUgU3RhbXBpbmcgU2lnbmVyMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6ek939c3CMkeOLJSU0JtIvGxxAYE
# a579gnRQQ33GoLsfTvkCcSax70PYg4xI/OcPl3qa65zepqMOOxxEGHWOeKUXaf5J
# GKTiu1xO/o4qVHpQ8NX2zJHnmXnX3nmU15Yz/g6DviK/YxYso90oG689q+qX0vG/
# BBDnPUhF/R9oZcF/WZlpwCIxDGJup1xlASGwY8QiGCfu5vzSAD1HLqi4hlZdBNwT
# FyVuHN9EDxXNt9ulV3ZCbwBogpnS48He8IuUV0zsCJAiIc4iK5gMQuZCk5SYk+/9
# Btk/vFubVDwgse5q1kd6xauA6TCa3vGkP1VNCgk0inUp0mmtlw9Qv/jKCQIDAQAB
# o4H0MIHxMB8GA1UdIwQYMBaAFNrtZHQUnBQ8q92Zqb1bKE2LPMnYMB0GA1UdDgQW
# BBSOay0za/Qzp5OzE5ql4Ar3EjVqiDAOBgNVHQ8BAf8EBAMCBsAwDAYDVR0TAQH/
# BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAzhjFo
# dHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVROLVVTRVJGaXJzdC1PYmplY3QuY3Js
# MDUGCCsGAQUFBwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRy
# dXN0LmNvbTANBgkqhkiG9w0BAQUFAAOCAQEAujMkQECMfNtYn7NgmLL1wDH+6x9u
# UPYK4OTmga0mh6Lf/bPa9HPzAPspG4kbFT7ba1KTK8SsOYHXPGdXmjk24CgImuM5
# T5uJCX97xWF/WYkyJQpqrho+8KInqLbDuIf3FgRIQT1c2OyfTSAxBNlloe3NaQdT
# Fj3dNgIKiOtA5QYwC7gWS9zvvFUJ/8Y+Ei52s9zOQu/5dlfhtwoFQJhYml1xFpNx
# jGWB6m/ziff7c62057/Zjm+qC08l87jh1d11mGiB+KrA0YDCxMQ5icH2yZ5s13T5
# 2Zf4T8KaCs1ej/gZ6eCln8TwkiHmLXklySL5w/A6hFetOhb0Y5QQHV3QxjCCBJ0w
# ggOFoAMCAQICEFUbaMemqqRVsCxZ4HNzEdowDQYJKoZIhvcNAQEFBQAwgZUxCzAJ
# BgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtlIENpdHkx
# HjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMYaHR0cDov
# L3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNFUkZpcnN0LU9iamVj
# dDAeFw0wOTA1MTgwMDAwMDBaFw0yMDA1MzAxMDQ4MzhaMD8xCzAJBgNVBAYTAk5M
# MQ8wDQYDVQQKEwZURVJFTkExHzAdBgNVBAMTFlRFUkVOQSBDb2RlIFNpZ25pbmcg
# Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9eM8yoP4mc7SAwo6f
# zG1EOYACu4FSXIZsBzA1PCbATPZd0Hm1WreaDoc/p/LbCRhyamrJUhsipHlbycL0
# u5xMj53l7RhNyfGv/lh077x0ku5APlCE9f+7bJP5J0+4NbO9a9MSRWbDfomPp6d1
# pCIsiuY8fUsT+ZYh5gW9A29zI8Mkq0IwpxZ5lybv7ODknJmYPDZB1gD6J0TtDb8k
# lKvCNFGsARanYjruvGdttjgnOal+8W5mmZp9TtfcHJWSc1Ofe1egoaxpY1nHS3hv
# VJaPv8jRrJsLPOESy29reWLl2q7weRRFOJijVns6QjLXkgoqNbrYaZejWBe90KXn
# WvCRAgMBAAGjggE8MIIBODAfBgNVHSMEGDAWgBTa7WR0FJwUPKvdmam9WyhNizzJ
# 2DAdBgNVHQ4EFgQUSYQgmOTmxj4EPhI0zBAg/j1+sqEwDgYDVR0PAQH/BAQDAgEG
# MBIGA1UdEwEB/wQIMAYBAf8CAQAwGAYDVR0gBBEwDzANBgsrBgEEAbIxAQICHTBC
# BgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVROLVVT
# RVJGaXJzdC1PYmplY3QuY3JsMHQGCCsGAQUFBwEBBGgwZjA9BggrBgEFBQcwAoYx
# aHR0cDovL2NydC51c2VydHJ1c3QuY29tL1VUTkFkZFRydXN0T2JqZWN0X0NBLmNy
# dDAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0LmNvbTANBgkqhkiG
# 9w0BAQUFAAOCAQEAJ8bNUo3VGhtbs0gFVcDJT6hbxnTzTUmuQ5vKB6FyIDys5wT1
# lR7EL3RhWsWsKJ0eGZ0BibNZn2jZ4rF7dpTwIguTnda5efwg+ZpgM6vMWBZ4xmhh
# X89exC1b/W1BEvkWp3CJJAUrKkW25YXd6ocxaDuxApY4vbKnG4gz8FJ70+NoPSft
# jSvTIKErkAcdeDbyhBSoLvYsWLmADyq5iLrTqwkBn6ZMFc0okUu71YpiV169lIDn
# daZvXiqnZwP8xD3FXQvbgzBT7uWUh/ErW4SrX6lUIdFeGnvv78S9Y74NdxGkSCjr
# Gn26/xEWSYA92vaUpecqjDhc71awn41IEC3xkTCCBQowggPyoAMCAQICEQD+Jr+h
# hwo90OQDD1qB81+IMA0GCSqGSIb3DQEBBQUAMD8xCzAJBgNVBAYTAk5MMQ8wDQYD
# VQQKEwZURVJFTkExHzAdBgNVBAMTFlRFUkVOQSBDb2RlIFNpZ25pbmcgQ0EwHhcN
# MTQwMjI3MDAwMDAwWhcNMTcwMjI2MjM1OTU5WjCBwTELMAkGA1UEBhMCU0UxDzAN
# BgNVBBEMBjU4MyAzMDEYMBYGA1UECAwPw5ZzdGVyZ8O2dGxhbmRzMRMwEQYDVQQH
# DApMaW5rw7ZwaW5nMR0wGwYDVQQJDBRNw6RzdGVyIE1hdHRpYXMgVsOkZzEgMB4G
# A1UECgwXTGlua8O2cGluZ3MgdW5pdmVyc2l0ZXQxDzANBgNVBAsMBkxpVS1JVDEg
# MB4GA1UEAwwXTGlua8O2cGluZ3MgdW5pdmVyc2l0ZXQwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQC/TutKe3YoYrrzxML/4VZf4/XGChU5hzlVfFWEg8wq
# bJH6NdBQz/h1tCBJtrxdSrF8OkXhIc9V24AkNYQ69xFNccGd3Hu14zP/NkasqIcP
# yrlsKKYXO66gsV3yjN2VVglqVrYlLCO894odEokmm/C7E/b7Wshp/Uxnu0sMbAhm
# 0LuH3Jr1p49q+T1k6Oky0VzcYlLncNYS1EPUbtYki2YQTtaQdrm+9o/yrQithGpv
# 4ejXGnu8R4DxdeWYcPQt8+2VwBn/HimmgJtuKaXtz4x+KuPiOisRLzF5qEHJ6nEv
# eIZ7T8c1HOL145+DrelyX0o9qcICsvA0qOLjZsbvo2dTAgMBAAGjggF8MIIBeDAf
# BgNVHSMEGDAWgBRJhCCY5ObGPgQ+EjTMECD+PX6yoTAdBgNVHQ4EFgQUIIsJzK97
# +vA1XTmw7glRNrd35H8wDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMBgGA1UdIAQRMA8w
# DQYLKwYBBAGyMQECAh0wQgYDVR0fBDswOTA3oDWgM4YxaHR0cDovL2NybC50Y3Mu
# dGVyZW5hLm9yZy9URVJFTkFDb2RlU2lnbmluZ0NBLmNybDB1BggrBgEFBQcBAQRp
# MGcwPQYIKwYBBQUHMAKGMWh0dHA6Ly9jcnQudGNzLnRlcmVuYS5vcmcvVEVSRU5B
# Q29kZVNpZ25pbmdDQS5jcnQwJgYIKwYBBQUHMAGGGmh0dHA6Ly9vY3NwLnRjcy50
# ZXJlbmEub3JnMBsGA1UdEQQUMBKBEGFkQGdyb3Vwcy5saXUuc2UwDQYJKoZIhvcN
# AQEFBQADggEBAClr7Vdar3LLl2OT0brZslT9xSpsX5AXP3i1Ul10PmSf377DYlDd
# FjV5BcIVye0P1smd1DVs2VryU0Fe/DZ3tfBYSMgxSQwhOz29gJwhdG9hbd+A8Vwt
# /wgDaFJpRvvbx/YwO7zRGAqgfE0sZpQ/yW6oYzRlOyLdw49TsZKTC5xps5JsaJKl
# taCSTIWfKJk8hOj7c1SNeIncjb/2v1J5T0bv8DMBYxXUkuH+/LnlUwVCxW+lctgC
# iASg41OINNmGxeTiYjKFVB4aUOIYSdJkmG7IJlF0uGD58Un89gl05OvpvDpmmaCT
# m1V63FXGEwU2X95rhXuFHDo0IvvYSl5cBOgxggQ8MIIEOAIBATBUMD8xCzAJBgNV
# BAYTAk5MMQ8wDQYDVQQKEwZURVJFTkExHzAdBgNVBAMTFlRFUkVOQSBDb2RlIFNp
# Z25pbmcgQ0ECEQD+Jr+hhwo90OQDD1qB81+IMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRYPeec
# GeRZzz1irTm788H9X0gE1DANBgkqhkiG9w0BAQEFAASCAQBjhrJw6dBObUAs6GL9
# FFtA1CqihmgoKYaCEn0QfduD53NMn+XtERke6oLyz89/QZyjgUPGRFjTSxWpl2Wk
# dH+RquMqiUZSiRSvI1R1jV1HVTqD5EUF5gX9psooBIppTSKZRB96uoK/7z1XhjjM
# nZ8/amrNicirXbYdyLjWPmJ1v8bu7kG0RSWsN/0/+g38BSotU6+U3/08RmJZCK1a
# Ad5hfR4Cjdc4PAmEPm1aGUYhmkVqEsNNEDzXGYBaPnyI7dZLo/BLkhqkohy4WZhV
# v30ElrTeVlIchHAQslTnio2Tsu6/sHTEtqCAv+8Kh+D+68KMQBM4AZdczXjMYhDd
# bDYCoYICQzCCAj8GCSqGSIb3DQEJBjGCAjAwggIsAgEAMIGpMIGVMQswCQYDVQQG
# EwJVUzELMAkGA1UECBMCVVQxFzAVBgNVBAcTDlNhbHQgTGFrZSBDaXR5MR4wHAYD
# VQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxITAfBgNVBAsTGGh0dHA6Ly93d3cu
# dXNlcnRydXN0LmNvbTEdMBsGA1UEAxMUVVROLVVTRVJGaXJzdC1PYmplY3QCDxaI
# 8DklXmOOaRQ5B+YzCzAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3
# DQEHATAcBgkqhkiG9w0BCQUxDxcNMTYwMjA1MTM0NDQ1WjAjBgkqhkiG9w0BCQQx
# FgQUwDwUHqYhIfOr1N0+DHUaceWKT0IwDQYJKoZIhvcNAQEBBQAEggEAcQGutw+Z
# U8/M72zaZHl6uJfXs4zL0BrMtGl1+mw0PZ0I1Lxk7mDGKU5vpVYjtTdR48eyJJ09
# AzX1+miC8/+lhToVSeax48O0GNrGY2V3UFXELE5kj4FI2zC7Sf7QB5nNfqyVgMNj
# wSTbbGUibipWFPib6496VRmZdlo2FcGLB3Bugk5LTZz8Ika6xAHbGvwILRmO52Wh
# I8RsK3P23V0KuhnZpkyzBEWCHICXP7T2ghnqi6/mEnlNcHxkvoIiuW3+Jw1ojfjt
# rgBOITmXI61uordaNl6N8UWobpqWlHxUDQL72YQglXwpdxj+GTg0AYD8m+FWSe0h
# fBC01vOU7qZkgw==
# SIG # End signature block
