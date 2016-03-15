# LiU Functions explained
They all have a help included so the easiest way is to run help [liu-function] -example
If LiUId is used in a cmdlet, it is the same as the AD propery [Name]. 
##Get-LiUAnswer
####SYNOPSIS
    Gives a Yes/No question and returns the answer
####SYNTAX
    Get-LiUAnswer [-Message] <String> [[-Caption] <String>] [[-Abort]] [[-DefaultYes]] [<CommonParameters>]
####DESCRIPTION
Use this cmdlet to make a quick question to the user.
####EXAMPLES
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>if (Get-LiUAnswer "Do you want to continue?") {Write-Host "Continuing..."}
    
    
    Choose wisely...
    Do you want to continue?
    [Y] Yes  [N] No  [?] Help (default is "N"): y
    Continuing...
---    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>$Answer = Get-LiUAnswer "Do you want to continue?" -Abort
    
    
    Choose wisely...
    Do you want to continue?
    [Y] Yes  [N] No  [A] Abort  [?] Help (default is "N"): A
    
    C:\PS> if ($Answer -eq 2) {throw "Script aborted!"}
    Script aborted!
    At line:1 char:21
    + if ($Answer -eq 2) {throw "Script aborted!"}
    +                     ~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : OperationStopped: (Script aborted!:String) [], RuntimeException
        + FullyQualifiedErrorId : Script aborted!
---    
    -------------------------- EXAMPLE 3 --------------------------
    
    C:\PS>Get-ChildItem $env:TEMP *.tmp | Get-LiUAnswer -Caption "Delete file?" | Remove-Item -WhatIf
    
    
    Delete file?
    tmp36AC.tmp
    [Y] Yes  [N] No  [A] Yes to ALL  [L] No to ALL  [?] Help (default is "Y"): A
    What if: Performing operation "Remove File" on Target "C:\Users\adm_johpe12\AppData\Local\Temp\tmp36AC.tmp".
    What if: Performing operation "Remove File" on Target "C:\Users\adm_johpe12\AppData\Local\Temp\tmp4423.tmp".
    What if: Performing operation "Remove File" on Target "C:\Users\adm_johpe12\AppData\Local\Temp\tmp4424.tmp".
    ...
##Get-LiULastCommand
    
####SYNOPSIS
    Copies the last command to the clipboard
    
    
####SYNTAX
    Get-LiULastCommand [[-Id] <Int32>] [<CommonParameters>]
    
    Get-LiULastCommand [[-List]] [<CommonParameters>]
    
    
DESCRIPTION
    Copies the last (or chosen command from history) PS command to the clipboard
####EXAMPLES
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>Get-LiULastCommand
    
    
    Last command (Write-Pretty -Key "I...) is now in clipboard...
    
    
    
---    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>Get-LiULastCommand 5
    
    
    Command with id '5' (Get-LiUAnswer "Are y...) is now in clipboard...
    
    This example copies command with id 5 to the clipboard.
    To list the command history, run Get-History or Get-LiULastCommand -List
    
    
    
---    
    -------------------------- EXAMPLE 3 --------------------------
    
    C:\PS>Get-LiULastCommand -4
    
    
    Command with id '145' (Write-LiULog "Get-Li...) is now in clipboard...
    
    This example copies the 4th last command with clipboard.
    To list the command history, run Get-History or Get-LiULastCommand -List
##Read-LiULine
    
####SYNOPSIS
    Used to quickly collect lines of text into a variable or the pipeline
    
    
####SYNTAX
    Read-LiULine [[-LinePrefix] <Object>] [<CommonParameters>]
    
    
####DESCRIPTION
    A nice way to use this cmdlet is to paste lines from a text file or an email to process them in a foreach-loop.
####EXAMPLES

    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>$Users = Read-LiULine
    
    
    [1] Enter line: johpe12
    [2] Enter line: tesjo625
    [3] Enter line:
    PS C:\> $Users
    johpe12
    tesjo625
    
    
    
---    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>$Users = Read-LiULine -LinePrefix "User #{0}"
    
    
    User #1: johpe12
    User #2: tesjo625
    ...
##Test-LiULockFile
    
####SYNOPSIS
    Creates a lockfile to prevent that the same script is run more than once at the same time.
    
    
####SYNTAX
    Test-LiULockFile [[-LockFile] <String>] [<CommonParameters>]
    
    
####DESCRIPTION
    The lockfile contains the PID of the process that runs the script. If the lockfile doesn't exist, it will be created,
    if the lockfile exists with a PID that doesn't match any running processes, the PID will be overwritten.
    
    The cmdlet will return a hashtable with two keys, "IsLocked" and "Message".
    If "IsLocked" is $false that means that the script IS NOT running in another instance, and the lockfile is now updated with the scripts PID.
    If "IsLocked" is $true the script IS running in another instance, and the current script should be terminated.
####EXAMPLES
-------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>Test-LiULockFile
    
    Name                           Value                                                                                                                                                                                
    ----                           -----                                                                                                                                                                                
    Message                        New lockfile created sucessfully...                                                                                                                                                  
    IsLocked                       False 
    
    C:\PS> Test-LiULockFile
    
    Name                           Value
    ----                           -----
    Message                        Script is already running with pid: 3340...
    IsLocked                       True
    
    
    
---    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>$ScriptLock = Test-LiULockFile
    
    C:\PS> if ($ScriptLock["IsLocked"]) { Write-Warning $ScriptLock["Message"]; break }
##Write-LiULog
    
####SYNOPSIS
    Use this cmdlet to add logging to your script. Can log to Screen/File and EventLog
    
    
####SYNTAX
    Write-LiULog [[-Message] <String>] [-EventID <Int32>] [-EntryType <String>] [-MajorFault] [-Category <Int32>] [-Underline] [-UnderlineChar <Char>] [-Screen] [-File] [-EventLog] [-SkipDateTime] [-ForegroundColor {Black | DarkBlue 
    | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White}] [<CommonParameters>]
    
    Write-LiULog [-SetLogFilePath <String>] [-SetEventLogName <String>] [-SetEventLogSource <String>] [<CommonParameters>]
    
    Write-LiULog [-GetLogFilePath] [-GetEventLogName] [-GetEventLogSource] [<CommonParameters>]
    
    
####DESCRIPTION
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
####EXAMPLES
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>Write-LiULog -Message "Hello World!"
    
    
    2012-02-02 16:40:16: Hello World!
    
    -Message parameter are not needed as long as the message is written first
    
    C:\PS> Write-LiULog "Hello World!" -EntryType Warning
    WARNING: 2012-02-02 16:41:23: Hello World!
    
    C:\PS> Write-LiULog -SetLogFilePath C:\Logs\myLogfile.txt
    C:\PS> Write-LiULog "Hello textfile!" -File -Screen -Underline
    2012-02-02 16:46:31: Hello textfile!
    ------------------------------------
    
    
    
---    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>If none of the parameters (-Screen, -File or -EventLog) is provided, all defined ways will be used.
    
    
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

##Export-PSCredential
    
####SYNOPSIS
    Exports Credentials to a encrypted XML-File
    
    
####SYNTAX
    Export-PSCredential [[-Credential] <Object>] [[-Path] <String>] [<CommonParameters>]
    
 
####DESCRIPTION
    Encrypt SecureString password using Data Protection API
    Only the current user account can decrypt this cipher

####EXAMPLES
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>$Cred = Get-Credential TestUser
    
    
    cmdlet Get-Credential at command pipeline position 1
    Supply values for the following parameters:
    
    C:\PS> Export-PSCredential $Cred
    UserName     Password
    --------     --------
    TestUser     System.Security.SecureString
    
    
    
---    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>Export-PSCredential TestUser
    
    
    UserName     Password
    --------     --------
    TestUser     System.Security.SecureString
##Import-PSCredential
    
####SYNOPSIS
    Imports credentials from a encrypted XML-File
    
    
####SYNTAX
    Import-PSCredential [[-Path] <String>] [<CommonParameters>]
    
    
####DESCRIPTION
    Decrypts a password to a SecureString using Data Protection API
    Only the current user account can decrypt this cipher
####EXAMPLES
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>$Cred = Import-PSCredential
    
    
    C:\PS> $Cred
    UserName     Password
    --------     --------
    TestUser     System.Security.SecureString
##Get-UserAccountControlFlags
    
####SYNOPSIS
    Extracts userAccountFlags from a user or a userAccountControl value
    
    
####SYNTAX
    Get-UserAccountControlFlags [-LiUID] <String> [<CommonParameters>]
    
    Get-UserAccountControlFlags [-UserAccountControl] <Int32> [<CommonParameters>]
    
    
####DESCRIPTION
    Takes a LiU-ID or a userAccountControl value and returns a array with the flags
###EXAMPLES
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>Get-UserAccountFlags johpe12
    
    
    NORMAL_ACCOUNT
    DONT_EXPIRE_PASSWORD
    
    
    
---    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>(Get-UserAccountFlags 66048) -join ' | '
    
    
    NORMAL_ACCOUNT | DONT_EXPIRE_PASSWORD
	
	
##Write-LiUProgress

####SYNOPSIS
    This cmdlet shows a progressbar with minimal of execution time

####SYNTAX
    Write-LiUProgress [-UpdateFrequence <Int32>] -Items <Int32> [-Caption <String>] [<CommonParameters>]
    Write-LiUProgress [-Update] [-Message <String>] [-GetCurrentIteration] [-GetProcessedTime] [<CommonParameters>]

####DESCRIPTION
    Iterating through thousands of objects and writing output on the screen for each object will drastically
    increase the execution time. Still you want to see how long the operations has taken. With this cmdlet
    you can call it every iteration, but output to the screen will only happend every second (or any Updatefrequence
    chosen)

###EXAMPLES
		-------------------------- EXAMPLE 1 --------------------------

    PS C:\>Set the -UpdateFrequence and -Items once just before the loop starts processing,

    then call -Update on every iteration.

    1..100 | % {
    Write-LiUProgress -UpdateFrequence 1 -Items 100
    }{
    Write-LiUProgress -Update
    sleep -Milliseconds 200
    }