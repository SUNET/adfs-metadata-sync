#========================================================================== 
# NAME: New-RelyingPartyFromMetadata.ps1
#
# DESCRIPTION: Creates ADFS Relying Parties from the SWAMID Metadata
#
# 
# AUTHOR: Johan Peterson (Linköping University)
# DATE  : 2014-03-18
#
# PUBLISH LOCATION: C:\Published Powershell Scripts\ADFS
#
#=========================================================================
#  Version     Date      	Author              	Note 
#  ----------------------------------------------------------------- 
#   1.0        2014-03-18	Johan Peterson (Linköping University)	Initial Release
#   1.1        2014-03-18	Johan Peterson (adm)	First Publish
#   1.2        2014-03-19	Johan Peterson (adm)	Fixed a bug with SamlEndpoint not setting Binding to Artifact correct
#   1.3        2014-03-19	Johan Peterson (adm)	Only releasing TransformsRule Group Base to everyone, not Static Group as before
#   1.4        2014-03-20	Johan Peterson (adm)	Now removes swamid RPs that are not in metadata anymore
#   1.5        2014-03-20	Johan Peterson (adm)	Changed AddOnly to AddRemoveOnly
#   1.6        2014-05-26	Johan Peterson (adm)	Added SupportsShouldProcess and ErrorAction Stop for ADFS cmdlets
#   1.7        2015-05-28	Andreas Karlsson (adm)	Added load-cmdlet function and changed paths of the functions to load
#   1.8        2015-08-06	Andreas Karlsson (adm)	Removed the Snapin-Check for ADFS
#   1.9        2016-04-08	Johan Peterson (adm)	Removed an incorrect row (69) wich didn't do anything :)
#   1.10        2016-04-12	Johan Peterson (adm)	Added support for having PS sciprts in /ADFS or in root folder
#=========================================================================


[CmdletBinding(DefaultParameterSetName='SingleSP',
                SupportsShouldProcess=$true)]
param (
    [Parameter(ParameterSetName='SingleSP',
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
    $EntityId,
    [Parameter(ParameterSetName='SingleSP',
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=1)]
    $EntityBase,
    [string]$LocalMetadataFile,
    [string[]]$ForcedEntityCategories,
    [Parameter(ParameterSetName='AllSPs')]
    [switch]
    $ProcessWholeMetadata,
    [switch]$ForceUpdate,
    [Parameter(ParameterSetName='AllSPs')]
    [switch]
    $AddRemoveOnly
)

function Add-SPRelyingPartyTrust {
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $sp
    )
    
    $Continue = $true

    ### EntityId
    $entityID = $sp.entityID

    Write-LiULog "Adding $entityId as SP..." -EntryType Information

    ### Name, DisplayName
    $Name = (Split-Path $sp.entityID -NoQualifier).TrimStart('/') -split '/' | select -First 1


    ### SwamID 2.0
    #$Swamid2 = ($sp.base | Split-Path -Parent) -eq "swamid-2.0"

    ### Token Encryption Certificate 
    Write-VerboseLiULog "Getting Token Encryption Certificate..."
    $EncryptionCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $CertificateString = ($sp.SPSSODescriptor.KeyDescriptor | ? use -eq "encryption"  | select -ExpandProperty KeyInfo).X509Data.X509Certificate
    if ($CertificateString -eq $null)
    {
        Write-VerboseLiULog "Certificate with description `'encryption`' not found. Using default certificate..."
        $CertificateString = ($sp.SPSSODescriptor.KeyDescriptor | select -ExpandProperty KeyInfo -First 1).X509Data.X509Certificate
    }
    
    try
    {
        #Kan finnas flera certifikat! Se till att kolla det och kör foreach. Välj det giltiga cert som har längst giltighetstid
        Write-VerboseLiULog "Converting Token Encryption Certificate string to Certificate..."
        $CertificateBytes  = [system.Text.Encoding]::UTF8.GetBytes($CertificateString)
        $EncryptionCertificate.Import($CertificateBytes)
        Write-VerboseLiULog "Convertion of Token Encryption Certificate string to Certificate done!"
    }
    catch
    {
        Write-LiULog "Could not import Token Encryption Certificate!" -EntryType Error
        $Continue = $false
    }

    ### Token Signing Certificate 
    Write-VerboseLiULog "Getting Token Signing Certificate..."
    $SigningCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $CertificateString = ($sp.SPSSODescriptor.KeyDescriptor | ? use -eq "signing"  | select -ExpandProperty KeyInfo).X509Data.X509Certificate
    if ($CertificateString -eq $null)
    {
        Write-VerboseLiULog "Certificate with description `'signing`' not found. Using Token Decryption certificate..."
        $SigningCertificate = $EncryptionCertificate
    }
    else
    {
        try
        {
            Write-VerboseLiULog "Converting Token Signing Certificate string to Certificate..."
            $CertificateBytes  = [system.Text.Encoding]::UTF8.GetBytes($CertificateString)
            $SigningCertificate.Import($CertificateBytes)
            Write-VerboseLiULog "Convertion of Token Signing Certificate string to Certificate done!"
        }
        catch
        {
            Write-LiULog "Could not import Token Signing Certificate!" -EntryType Error
            $Continue = $false
        }
    }

    ### Bindings
    Write-VerboseLiULog "Getting SamlEndpoints..."
    $SamlEndpoints = $sp.SPSSODescriptor.AssertionConsumerService |  % {
        if ($_.Binding -eq "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST")
        {  
            Write-VerboseLiULog "HTTP-POST SamlEndpoint found!"
            New-ADFSSamlEndpoint -Binding POST -Protocol SAMLAssertionConsumer -Uri $_.Location -Index $_.index 
        }
        elseif ($_.Binding -eq "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact")
        {
            Write-VerboseLiULog "HTTP-Artifact SamlEndpoint found!"
            New-ADFSSamlEndpoint -Binding Artifact -Protocol SAMLAssertionConsumer -Uri $_.Location -Index $_.index 
        }
    } 

    if ($SamlEndpoints -eq $null) 
    {
        Write-LiULog "No SamlEndpoints found!" -EntryType Error
        $Continue = $false
    }
    

    ### Get Category
    Write-VerboseLiULog "Getting Entity Categories..."
    $EntityCategories = @()
    $EntityCategories += "Base"
    $EntityCategories += $sp.Extensions.EntityAttributes.Attribute | ? Name -eq "http://macedir.org/entity-category" | select -ExpandProperty AttributeValue | % {
        if ($_ -is [string])
        {
            $_
        }
        elseif ($_ -is [System.Xml.XmlElement])
        {
            $_."#text"
        }
    }
    
    Write-VerboseLiULog "The following Entity Categories found: $($EntityCategories -join ',')"

    if ($ForcedEntityCategories)
    {
        $EntityCategories += $ForcedEntityCategories
        Write-VerboseLiULog "Added Forced Entity Categories: $($ForcedEntityCategories -join ',')"
    }

    #. 'C:\Powershell Scripts\Import-ADFSIssusanceTransformRuleFunctions.ps1'

    if (Test-Path 'C:\Powershell Scripts\ADFS\Import-ADFSIssusanceTransformRuleFunctions.ps1')
    {
    . 'C:\Powershell Scripts\ADFS\Import-ADFSIssusanceTransformRuleFunctions.ps1'
    }

    if (Test-Path 'C:\Powershell Scripts\Import-ADFSIssusanceTransformRuleFunctions.ps1')
    {
    . 'C:\Powershell Scripts\Import-ADFSIssusanceTransformRuleFunctions.ps1'
    }

    $IssuanceTransformRules = Get-IssuanceTransformRules $EntityCategories -EntityId $entityID

    $IssuanceAuthorityRule =
@"
    @RuleTemplate = "AllowAllAuthzRule"
     => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", 
     Value = "true");
"@

    if ((Get-ADFSRelyingPartyTrust -Identifier $entityID) -eq $null)
    {
        ### Lägg till swamid: före namnet.
        ### Om namn finns utan swamid, låt det vara
        ### Om namn finns med swamid, lägg till siffra

        $NamePrefix = "Swamid:"        
        $NameWithPrefix = "$NamePrefix $Name"

        if ((Get-ADFSRelyingPartyTrust -Name $NameWithPrefix) -ne $null)
        {
            $n=1
            Do
            {
                $n++
                $NewName = "$Name ($n)"
            }
            Until ((Get-ADFSRelyingPartyTrust -Name "$NamePrefix $NewName") -eq $null)

            $Name = $NewName
            $NameWithPrefix = "$NamePrefix $Name"
            Write-VerboseLiULog "A RelyingPartyTrust already exist with the same name. Changing name to `'$NameWithPrefix`'..."
        }
        
        if ($Continue)
        {
            try 
            {
                Write-VerboseLiULog "Adding ADFSRelyingPartyTrust `'$entityID`'..."
                #NAME MUST BE UNIQUE?
                
                Add-ADFSRelyingPartyTrust -Identifier $entityID `
                                    -RequestSigningCertificate $SigningCertificate `
                                    -Name $NameWithPrefix `
                                    -EncryptionCertificate $EncryptionCertificate  `
                                    -IssuanceTransformRules $IssuanceTransformRules `
                                    -IssuanceAuthorizationRules $IssuanceAuthorityRule `
                                    -SamlEndpoint $SamlEndpoints `
                                    -ErrorAction Stop

                Write-LiULog "Seccessfully added `'$entityId`'!" -EntryType Information
            }
            catch
            {
                Write-LiULog "Could not add $entityId as SP! Error: $_" -EntryType Error
            }
        }
    }
    else
    {
        Write-LiULog "$entityId already exists as SP!" -EntryType Warning
    }                
}

function Processes-RelyingPartyTrust {
param (
    $sp
)

    if ((Get-ADFSRelyingPartyTrust -Identifier $sp.EntityID) -eq $null)
    {
        Write-VerboseLiULog "$($sp.EntityID) not in ADFS database."
        Add-SPRelyingPartyTrust $sp
    }
    else
    {
        $Name = (Split-Path $sp.entityID -NoQualifier).TrimStart('/') -split '/' | select -First 1

        if ($ForceUpdate)
        {
            if ((Get-ADFSRelyingPartyTrust -Name $Name) -ne $null)
            {
                Write-LiULog "$($sp.EntityID) added manual in ADFS database, aborting force update!" -EntryType Warning
            }
            else
            {
                Write-VerboseLiULog "$($sp.EntityID) in ADFS database, forcing update!"
                #Update-SPRelyingPartyTrust $_
                Write-VerboseLiULog "Deleting $($sp.EntityID)..."
                try
                {
                    Remove-ADFSRelyingPartyTrust -TargetIdentifier $sp.EntityID -Confirm:$false -ErrorAction Stop
                    Write-VerboseLiULog "Deleting $($sp.EntityID) done!"
                    Add-SPRelyingPartyTrust $sp
                }
                catch
                {
                    Write-LiULog "Could not delete $($sp.EntityID)... Error: $_" -EntryType Error
                }
            }
        }
        else
        {
            if ($AddRemoveOnly -eq $true)
            {
                Write-VerboseLiULog "Skipping RP due to -AddRemoveOnly switch..."
            }
            elseif (Get-LiUAnswer "$($sp.EntityID) already exists. Do you want to update it?")
            {
                if ((Get-ADFSRelyingPartyTrust -Name $Name) -ne $null)
                {
                    $Continue = Get-LiUAnswer "$($sp.EntityID) added manual in ADFS database, still forcing update?"
                }
                else
                {
                    $Continue = $true
                }

                if ($Continue)
                {
                        
                    Write-VerboseLiULog "$($sp.EntityID) in ADFS database, updating!"
                
                    #Update-SPRelyingPartyTrust $_
                    Write-VerboseLiULog "Deleting $($sp.EntityID)..."
                    try
                    {
                        Remove-ADFSRelyingPartyTrust -TargetIdentifier $sp.EntityID -Confirm:$false -ErrorAction Stop
                        Write-VerboseLiULog "Deleting $($sp.EntityID) done!"
                        Add-SPRelyingPartyTrust $sp
                    }
                    catch
                    {
                        Write-LiULog "Could not delete $($sp.EntityID)... Error: $_" -EntryType Error
                    }
                }
            }
        }
    }
}


# Tries to load Cmd-Let 
function Load-CmdLet($CmdLetName)
{
    $ScriptsPath = @()
    $ScriptsPath += "."
    $ScriptsPath += "C:\Published Powershell Scripts\Functions"
    $ScriptsPath += "C:\ServiceFront\Scripts"
    

    if (!$CmdLetName.EndsWith('.ps1')) { $CmdLetName += ".ps1" }

    $ScriptsPath | % { 
        $ReturnObj = $null 
    }{ 
        if (Test-Path "$_\$CmdLetName") { $ReturnObj = "$_\$CmdLetName" }
    }{ 
        if ($ReturnObj -ne $null) { $ReturnObj }  else { throw "$CmdLetName cmdlet missing!" }
    }
}

#Not needed for ADFS 3.0
#if ((Get-PSSnapin | ? name -eq "Microsoft.Adfs.PowerShell") -eq $null)
#{
#    Add-PSSnapin "Microsoft.Adfs.PowerShell"
#}

# Import commandlets
$CmdLet =  Load-CmdLet Write-LiULog
. $CmdLet
$CmdLet =  Load-CmdLet Get-LiUAnswer
. $CmdLet


Write-VerboseLiULog "Script started" -EntryType Information

#Getting Metadata

if ($LocalMetadataFile)
{
    try
    {
        [xml]$MetadataXML = Get-Content $LocalMetadataFile
        Write-VerboseLiULog "Successfully loaded local MetadataFile..." -EntryType Information
    }
    catch
    {
        Write-LiULog "Could not load LocalMetadataFile!" -MajorFault
    }
}

if ($MetadataXML -eq $null)
{
    
    try
    {
        Write-VerboseLiULog "Downloading Metadata from SWAMID..." -EntryType Information
        $Metadata = Invoke-WebRequest http://md.swamid.se/md/swamid-2.0.xml
        Write-VerboseLiULog "Successfully downloaded Metadata from SWAMID!" -EntryType Information
    }
    catch
    {
        Write-LiULog "Could not download Metadata from SWAMID!" -MajorFault
    }

    try
    {
        Write-VerboseLiULog "Parsing downloaded Metadata XML..." -EntryType Information
        $MetadataXML = [xml]$Metadata.Content
        Write-VerboseLiULog "Successfully parsed downloaded Metadata XML!" -EntryType Information
    }
    catch
    {
        Write-LiULog "Could not parse downloaded Metadata from SWAMID!" -MajorFault
    }
}

#Getting Metadata Done!

if ($ProcessWholeMetadata)
{
    Write-LiULog "Processing whole Metadata file..." -EntryType Information

    $MetadataXML.EntitiesDescriptor.EntityDescriptor | ? {$_.SPSSODescriptor -ne $null -and $_.Extensions -ne $null} | % {
        $SwamidSPs = @()
    }{
        Write-VerboseLiULog "Working with `'$($_.EntityID)`'..."

        $SwamidSPs += $_.EntityId
        Processes-RelyingPartyTrust $_

    }{
        # Checking if any Swamid Relying Party Trusts show be removed
        
        Write-LiULog "Checking for Relying Parties removed from Swamid Metadata..."

        $CurrentSwamidSPs = Get-ADFSRelyingPartyTrust | ? {$_.Name -like "Swamid: *"} | select -ExpandProperty Identifier

        $RemoveSPs = Compare-Object $CurrentSwamidSPs $SwamidSPs | ? SideIndicator -eq "<=" | select -ExpandProperty InputObject

        Write-VerboseLiULog "Found $($RemoveSPs.Count) RPs that should be removed."

        if ($ForceUpdate)
        {
            foreach ($rp in $RemoveSPs)
            {
                Write-VerboseLiULog "Removing `'$($rp)`'..."
                try 
                {
                    Remove-ADFSRelyingPartyTrust -TargetIdentifier $rp -Confirm:$false -ErrorAction Stop
                    Write-VerboseLiULog "Done!"
                }
                catch
                {
                    Write-LiULog "Could not remove `'$($rp)`'! Error: $_" -EntryType Error
                }
            }
        }
        else
        {
            # $RemoveSPs | Get-LiUAnswer -Caption "Do you want to remove Relying Party trust that are not in Swamid metadata?" | Remove-ADFSRelyingPartyTrust -Confirm:$false 
            foreach ($rp in ($RemoveSPs | Get-LiUAnswer -Caption "Do you want to remove Relying Party trust that are not in Swamid metadata?"))
            {
                Write-VerboseLiULog "Removing `'$($rp)`'..."
                try 
                {
                    Remove-ADFSRelyingPartyTrust -TargetIdentifier $rp -Confirm:$false -ErrorAction Stop
                    Write-VerboseLiULog "Done!"
                }
                catch
                {
                    Write-LiULog "Could not remove `'$($rp)`'! Error: $_" -EntryType Error
                }
            }
        }
    }
}
else
{
    Write-VerboseLiULog "Working with `'$EntityID`'..."
    $sp = $MetadataXML.EntitiesDescriptor.EntityDescriptor | ? {$_.entityId -eq $EntityId -and $_.base -eq $EntityBase}

    Processes-RelyingPartyTrust $sp
}

Write-VerboseLiULog "Script ended!"