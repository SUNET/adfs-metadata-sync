#========================================================================== 
# NAME: Import-ADFSIssusanceTransformRuleFunctions.ps1
#
# DESCRIPTION: Makes TransformRules from EntityCategories and/or manual 
#              Entities
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
#   1.2        2014-03-19	Johan Peterson (adm)	New TransformsRule Group called Base with only transient-id in
#   1.3        2014-05-23	Johan Peterson (adm)	Added eduPersonScopedAffiliation to hr.liu.se
#   1.4        2015-03-05	Johan Peterson (adm)	Added entity category http://refeds.org/category/research-and-scholarship
#   1.5        2015-04-24	Johan Peterson (adm)	Fixed Get-IssuanceTransformRules so you can use only a EntityId without EntityCategories, also changed Transient-Id to not hardcode sp.swamid.se
#   1.6        2015-04-24	Johan Peterson (adm)	Fixed Get-IssuanceTransformRules so it can handle entity-id not having sp.swamid.se hardcoded
#   1.7        2015-05-13	Johan Peterson (adm)	Added AeTM as ManualSP
#   1.8        2015-05-22	Johan Peterson (adm)	Fixed AeTM
#=========================================================================

function Get-IssuanceTransformRules
{
param (

    [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
    [string[]]$EntityCategories,
    [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
    [string]$EntityId
)

if (Test-Path 'C:\Powershell Scripts\Import-TransformRulesAndAttributes.ps1')
{
. 'C:\Powershell Scripts\Import-TransformRulesAndAttributes.ps1'
}

if (Test-Path 'C:\Powershell Scripts\ADFS\Import-TransformRulesAndAttributes.ps1')
{
. 'C:\Powershell Scripts\ADFS\Import-TransformRulesAndAttributes.ps1'
}

$AllAttributes = Import-AllAttributes
$AllTransformRules = Import-AllTransformRules

$IssuanceTransformRuleCategories = Import-IssuanceTransformRuleCategories
$IssuanceTransformRulesManualSP = Import-IssuanceTransformRulesManualSP

### Transform Entity Categories

$TransformedEntityCategories = @()
$TransformedEntityCategories += "Base"

$AttributesFromAD = @{}
$IssuanceTransformRules = [Ordered]@{}

if ($EntityCategories -ne $null)
{
    if ($EntityCategories.Contains("http://refeds.org/category/research-and-scholarship")) 
    {
        $TransformedEntityCategories += "research-and-scholarship" 
    }

    if ($EntityCategories.Contains("http://www.geant.net/uri/dataprotection-code-of-conduct/v1")) 
    {
        $TransformedEntityCategories += "releaseToCoC" 
    }

    if ($EntityCategories.Contains("http://www.swamid.se/category/research-and-education") -and `
        ($EntityCategories.Contains("http://www.swamid.se/category/eu-adequate-protection") -or `
        $EntityCategories.Contains("http://www.swamid.se/category/nren-service") -or `
        $EntityCategories.Contains("http://www.swamid.se/category/hei-service")))
    {
        $TransformedEntityCategories += "entity-category-research-and-education" 
    }

    if ($EntityCategories.Contains("http://www.swamid.se/category/sfs-1993-1153"))
    {
        $TransformedEntityCategories += "entity-category-sfs-1993-1153" 
    }


###

#Add TransformRules from categories

    
    
    $TransformedEntityCategories | % { 

        if ($_ -ne $null -and $IssuanceTransformRuleCategories.ContainsKey($_))
        {
            foreach ($Rule in $IssuanceTransformRuleCategories[$_].Keys) { 
                if ($IssuanceTransformRuleCategories[$_][$Rule] -ne $null)
                {
                    $IssuanceTransformRules[$Rule] = $IssuanceTransformRuleCategories[$_][$Rule].Rule.Replace("[ReplaceWithSPNameQualifier]",$EntityId)
                    foreach ($Attribute in $IssuanceTransformRuleCategories[$_][$Rule].Attribute) { $AttributesFromAD[$Attribute] = $AllAttributes[$Attribute] }
                }
            }
        }
    }
}

if ($EntityId -ne $null -and $IssuanceTransformRulesManualSP.ContainsKey($EntityId))
{
    foreach ($Rule in $IssuanceTransformRulesManualSP[$EntityId].Keys) { 
        if ($IssuanceTransformRulesManualSP[$EntityId][$Rule] -ne $null)
        {                
            $IssuanceTransformRules[$Rule] = $IssuanceTransformRulesManualSP[$EntityId][$Rule].Rule.Replace("[ReplaceWithSPNameQualifier]",$EntityId)
            foreach ($Attribute in $IssuanceTransformRulesManualSP[$EntityId][$Rule].Attribute) { $AttributesFromAD[$Attribute] = $AllAttributes[$Attribute] }
        }
    }
}

if ($AttributesFromAD.Count)
{
    ### Build the retrieve from AD Rule

    $AttributesFromAD.Keys | ? {$_ -ne ""} | % { 
        $Types = @()
        $Query = @()
        $FirstRule = ""
    }{
        $Types += $_
        $Query += $AttributesFromAD[$_]
    }{
        if ($Types.Count -gt 0 -and $Query.Count -gt 0)
        {
        $FirstRule = @"

@RuleName = "Retrieve Attributes from AD"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
    => add(store = "Active Directory", 
    types = ("$($Types -join '","')"), 
    query = ";$($Query -join ',');{0}", param = c.Value);

"@
        }
    }
}

return $FirstRule.Replace("[ReplaceWithSPNameQualifier]",$EntityId) + $IssuanceTransformRules.Values

}

function Import-IssuanceTransformRuleCategories
{
    ### Create AttributeStore variables
    $IssuanceTransformRuleCategories = @{}

    ### Base Attributes - Released to everyone

    $TransformRules = [Ordered]@{}

    $TransformRules["transient-id"] = $AllTransformRules["transient-id"]

    $IssuanceTransformRuleCategories.Add("Base",$TransformRules)
    
    
    ### Static Attributes

    $TransformRules = [Ordered]@{}

    $TransformRules["o"] = $AllTransformRules["o"]
    $TransformRules["norEduOrgAcronym"] = $AllTransformRules["norEduOrgAcronym"]
    $TransformRules["c"] = $AllTransformRules["c"]
    $TransformRules["co"] = $AllTransformRules["co"]
    $TransformRules["schacHomeOrganization"] = $AllTransformRules["schacHomeOrganization"]
    $TransformRules["transient-id"] = $AllTransformRules["transient-id"]

    $IssuanceTransformRuleCategories.Add("Static",$TransformRules)

    ### research-and-scholarship ###

    $TransformRules = [Ordered]@{}
    $TransformRules["givenName"] = $AllTransformRules["givenName"]
    $TransformRules["surname"] = $AllTransformRules["surname"]
    $TransformRules["displayName"] = $AllTransformRules["displayName"]
    $TransformRules["eduPersonPrincipalName"] = $AllTransformRules["eduPersonPrincipalName"]
    $TransformRules["emailaddress"] = $AllTransformRules["emailaddress"]
    $TransformRules["eduPersonScopedAffiliation"] = $AllTransformRules["eduPersonScopedAffiliation"]
    $TransformRules["eduPersonTargetedID"] = $AllTransformRules["eduPersonTargetedID"]

    $IssuanceTransformRuleCategories.Add("research-and-scholarship",$TransformRules)

    ### GEANT Dataprotection Code of Conduct
    
    $TransformRules = [Ordered]@{}

    $TransformRules["displayName"] = $AllTransformRules["displayName"]
    $TransformRules["emailaddress"] = $AllTransformRules["emailaddress"]
    $TransformRules["eduPersonPrincipalName"] = $AllTransformRules["eduPersonPrincipalName"]
    $TransformRules["eduPersonScopedAffiliation"] = $AllTransformRules["eduPersonScopedAffiliation"]
    $TransformRules["schacHomeOrganization"] = $AllTransformRules["schacHomeOrganization"]


    $IssuanceTransformRuleCategories.Add("ReleaseToCoC",$TransformRules)
    
    ### SWAMID Entity Category Research and Education

    $TransformRules = [Ordered]@{}
    $TransformRules["givenName"] = $AllTransformRules["givenName"]
    $TransformRules["surname"] = $AllTransformRules["surname"]
    $TransformRules["displayName"] = $AllTransformRules["displayName"]
    $TransformRules["commonName"] = $AllTransformRules["commonName"]
    $TransformRules["eduPersonPrincipalName"] = $AllTransformRules["eduPersonPrincipalName"]
    $TransformRules["emailaddress"] = $AllTransformRules["emailaddress"]
    $TransformRules["eduPersonScopedAffiliation"] = $AllTransformRules["eduPersonScopedAffiliation"]

    $IssuanceTransformRuleCategories.Add("entity-category-research-and-education",$TransformRules)

    ### SWAMID Entity Category SFS 1993:1153

    $TransformRules = [Ordered]@{}
    $TransformRules["norEduPersonNIN"] = $AllTransformRules["norEduPersonNIN"]

    $IssuanceTransformRuleCategories.Add("entity-category-sfs-1993-1153",$TransformRules)

    return $IssuanceTransformRuleCategories
}

function Import-IssuanceTransformRulesManualSP
{
    $IssuanceTransformRuleManualSP = @{}

#    #Example
#    ### Amadeus AeTM Boka resor
#        $TransformRules = [Ordered]@{}
#        $TransformRules["transient-id"] = $AllTransformRules["transient-id"]
#        $TransformRules["LoginName"] = $AllTransformRules["LoginName"]
#        
#        $IssuanceTransformRuleManualSP["AeTM"] = $TransformRules
    ###

    $IssuanceTransformRuleManualSP
}