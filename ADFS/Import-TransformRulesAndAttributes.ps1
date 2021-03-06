#========================================================================== 
# NAME: Import-TransformRulesAndAttributes.ps1
#
# DESCRIPTION: Defines all SAML2.0 attributes and AD attributes that are
#              used to create TransformRules and Claims
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
#   1.2        2014-03-18	Johan Peterson (adm)	Fixed bug in Static release 
#   1.3        2014-03-18	Johan Peterson (adm)	Added ADFSExternalDNS as static variable to make Transient-Id easier
#   1.4        2014-12-15	Johan Peterson (adm)	Change all eduPersonScopedAffiliation to lowercases
#   1.5        2015-03-05	Johan Peterson (adm)	Added eduPersonTargetedID
#   1.6        2015-04-24	Johan Peterson (adm)	entity-id don't have sp.swamid.se hardcoded anymore
#   1.7        2015-05-13	Johan Peterson (adm)	Added Loginname for Amadeus
#   1.8        2015-05-22	Johan Peterson (adm)	Added samaccountname as attribute
#=========================================================================

function Import-AllAttributes
{
    #All attributes
    $Attributes = @{}
    
    $Attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"] = "givenname"
    $Attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"] = "sn"
    $Attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/displayname"] = "displayname"
    $Attributes["http://schemas.xmlsoap.org/claims/CommonName"] = "cn"
    $Attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"] = "name"
    $Attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"] = "mail"
    $Attributes["urn:mace:dir:attribute-def:eduPersonScopedAffiliation"] = "eduPersonScopedAffiliation"
    $Attributes["urn:mace:dir:attribute-def:norEduPersonNIN"] = "norEduPersonNIN"
    $Attributes["urn:mace:dir:attribute-def:norEduPersonNIN"] = "title"
    $Attributes["http://schemas.xmlsoap.org/claims/samaccountname"] = "samaccountname"
    

    $Attributes
}
#All TransformRules

function Import-AllTransformRules
{
    ### Static values
    
    $schacHomeOrganization = "liu.se"
    $o = "Linköping University"
    $norEduOrgAcronym = "LiU"
    $co = "Sweden"
    $c = "SE"

    $ADFSExternalDNS = "fs.liu.se"

    ###

    $TransformRules = @{}

    $TransformRules["o"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Send static [o]"
    => issue(type = "urn:oid:2.5.4.10", 
    value = "$o",
    Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }

    $TransformRules["norEduOrgAcronym"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Send static [norEduOrgAcronym]"
    => issue(type = "urn:oid:1.3.6.1.4.1.2428.90.1.6", 
    value = "$norEduOrgAcronym",
    Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }

    $TransformRules["c"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Send static [c]"
    => issue(type = "urn:oid:2.5.4.6", 
    value = "$c",
    Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }

    $TransformRules["co"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Send static [co]"
    => issue(type = "urn:oid:0.9.2342.19200300.100.1.43", 
    value = "$co",
    Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }

    $TransformRules["schacHomeOrganization"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Send static [schacHomeOrganization]"
    => issue(type = "urn:oid:1.3.6.1.4.1.25178.1.2.9", 
    value = "$schacHomeOrganization",
    Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }

    $TransformRules["transient-id"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "synthesize transient-id"
    c1:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid"]
     && 
     c2:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/authenticationinstant"]
     => add(store = "_OpaqueIdStore", 
     types = ("http://$ADFSExternalDNS/internal/tpid"),
     query = "{0};{1};{2};{3};{4}", 
     param = "useEntropy", 
     param = "http://$ADFSExternalDNS/adfs/services/trust![ReplaceWithSPNameQualifier]!" + c1.Value, 
     param = c1.OriginalIssuer, 
     param = "", param = c2.Value);

    @RuleName = "issue transient-id"
    c:[Type == "http://$ADFSExternalDNS/internal/tpid"]
     => issue(Type = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/format"] = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/spnamequalifier"] = "[ReplaceWithSPNameQualifier]", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/namequalifier"] = "http://$ADFSExternalDNS/adfs/services/trust");
"@
    Attribute=""
    }

    $TransformRules["givenName"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform givenName"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"]
     => issue(Type = "urn:oid:2.5.4.42", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
    }

    $TransformRules["surname"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform surname"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"]
     => issue(Type = "urn:oid:2.5.4.4", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
    }

    $TransformRules["displayName"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform displayName"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/displayname"]
     => issue(Type = "urn:oid:2.16.840.1.113730.3.1.241", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/displayname"
    }

    $TransformRules["CommonName"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform commonName"
    c:[Type == "http://schemas.xmlsoap.org/claims/CommonName"]
     => issue(Type = "urn:oid:2.5.4.3", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/claims/CommonName"
    }

    $TransformRules["eduPersonPrincipalName"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "compose eduPersonPrincipalName"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name", 
    Value !~ "^.+\\"]
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.6", 
     Value = c.Value + "@liu.se", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    }

     $TransformRules["eduPersonTargetedID"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "compose eduPersonTargetedID"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name", 
    Value !~ "^.+\\"]
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.10", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    }

    $TransformRules["emailaddress"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform emailaddress"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"]
     => issue(Type = "urn:oid:0.9.2342.19200300.100.1.3", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    }

    $TransformRules["eduPersonScopedAffiliation"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform eduPersonScopedAffiliation faculty@liu.se"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)faculty@$schacHomeOrganization"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "faculty@$schacHomeOrganization", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation student@liu.se"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)student@$schacHomeOrganization"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "student@$schacHomeOrganization", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation staff@liu.se"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)staff@$schacHomeOrganization"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "staff@$schacHomeOrganization", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation alum@liu.se"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)alum@$schacHomeOrganization"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "alum@$schacHomeOrganization", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation member@liu.se"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)member@$schacHomeOrganization"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "member@$schacHomeOrganization", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation affiliate@liu.se"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)affiliate@$schacHomeOrganization"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "affiliate@$schacHomeOrganization", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation employee@liu.se"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)employee@$schacHomeOrganization"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "employee@$schacHomeOrganization", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation library-walk-in@liu.se"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)library-walk-in@$schacHomeOrganization"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "library-walk-in@$schacHomeOrganization", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="urn:mace:dir:attribute-def:eduPersonScopedAffiliation"
    }

    $TransformRules["norEduPersonNIN"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform norEduPersonNIN"
    c:[Type == "urn:mace:dir:attribute-def:norEduPersonNIN"]
     => issue(Type = "urn:oid:1.3.6.1.4.1.2428.90.1.5", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="urn:mace:dir:attribute-def:norEduPersonNIN"
    }

    $TransformRules["LoginName"] = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform LoginName"
    c:[Type == "http://schemas.xmlsoap.org/claims/samaccountname"]
     => issue(Type = "LOGINNAME", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:assertion");
"@

    Attribute="http://schemas.xmlsoap.org/claims/samaccountname"
    }

    $TransformRules
}
