# Consume SWAMID Metadata to ADFS

##To install
* Download Git Repository 'Functions'
* Create C:\Powershell Scripts
* Copy Get-LiUAnswer.ps1 and Write-LiULog.ps1 to C:\Powershell Scripts (from 'Functions')
* Create C:\Powershell Scripts\ADFS
* Copy Import-TransformRulesAndAttributes.ps1, Import-ADFSIssusanceTransformRuleFunctions.ps1 and New-RelyingPartyFromMetadata.ps1 to C:\Powershell Scripts\ADFS

##Parse whole SWAMID metadata
Run New-RelyingPartyFromMetadata.ps1 -ProcessWholeMetadata -ForceUpdate to download and parse the whole SWAMID metadata

---

##Short description of the scripts

###Import-TransformRulesAndAttributes.ps1

Defines all SAML2.0 attributes and AD attributes that are
used to create TransformRules and Claims

* Change Static values to match your University

###Import-ADFSIssusanceTransformRuleFunctions.ps1

Makes TransformRules from EntityCategories and/or manual Entities

* Add your manual SPs in function Import-IssuanceTransformRulesManualSP (last in script)
  to use the scripts to easy get SAML 2 Claim Rules for your RelyingPartyTrust (SP)
* To get the SAML 2 Clain Rules from a manual added SP, run the following commands:
  cd  C:\Powershell Scripts\ADFS
  . .\Import-ADFSIssusanceTransformRuleFunctions.ps1
  Get-IssuanceTransformRules -EntityId <EntityId> #Ex: AeTM

###New-RelyingPartyFromMetadata.ps1

Creates ADFS Relying Parties from the SWAMID Metadata
This is the main script to use as scheduled task or manual update