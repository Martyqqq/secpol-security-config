function Invoke-secpolconf {

    # Get the current user's desktop path
    $DesktopPath = [Environment]::GetFolderPath("Desktop")
    
    # Define the folder name and full path
    $PoliciesFolderPath = Join-Path -Path $DesktopPath -ChildPath "POLICIES"
    
    # Check if the folder already exists; if not, create it
    if (-not (Test-Path -Path $PoliciesFolderPath)) {
        New-Item -ItemType Directory -Path $PoliciesFolderPath | Out-Null
    }

    # Define the output file paths
    $BackupFilePath = Join-Path -Path $PoliciesFolderPath -ChildPath "original_secpol.ini"
    $NewIniFilePath = Join-Path -Path $PoliciesFolderPath -ChildPath "new_secpol.ini"
    $DatabaseFilePath = Join-Path -Path $PoliciesFolderPath -ChildPath "newpolicies.db"

    # Export the local security policy
    try {
        secedit.exe /export /areas SECURITYPOLICY /cfg $BackupFilePath
    } catch {
        Write-Error "`nFailed to execute secedit.exe."
        return
    }

    # Create a second copy of the original policy
    try {
        Copy-Item -Path $BackupFilePath -Destination $NewIniFilePath -Force
    } catch {
        Write-Error "`nFailed to create a new database policy file."
        return
    }

    # Modify the second copy
    try {
        # Read the file content into a variable
        $PolicyContent = Get-Content -Path $NewIniFilePath

        # Password Policies
        $PolicyContent = $PolicyContent -replace 'MinimumPasswordAge\s*=\s*\d+', 'MinimumPasswordAge = 2'
        $PolicyContent = $PolicyContent -replace 'MaximumPasswordAge\s*=\s*\d+', 'MaximumPasswordAge = 30'
        $PolicyContent = $PolicyContent -replace 'MinimumPasswordLength\s*=\s*\d+', 'MinimumPasswordLength = 12'
        $PolicyContent = $PolicyContent -replace 'PasswordComplexity\s*=\s*\d+', 'PasswordComplexity = 1'
        $PolicyContent = $PolicyContent -replace 'PasswordHistorySize\s*=\s*\d+', 'PasswordHistorySize = 10'

        # Account Lockout Policies
        $PolicyContent = $PolicyContent -replace 'LockoutBadCount\s*=\s*\d+', 'LockoutBadCount = 5'
        $PolicyContent = $PolicyContent -replace 'ResetLockoutCount\s*=\s*\d+', 'ResetLockoutCount = 30'
        $PolicyContent = $PolicyContent -replace 'LockoutDuration\s*=\s*\d+', 'LockoutDuration = 30'

        # Just following order so this might be all over the place lol
        $PolicyContent = $PolicyContent -replace 'ClearTextPassword\s*=\s*\d+', 'ClearTextPassword = 0'
        $PolicyContent = $PolicyContent -replace 'LSAAnonymousNameLookup\s*=\s*\d+', 'LSAAnonymousNameLookup = 0'
        $PolicyContent = $PolicyContent -replace 'EnableGuestAccount\s*=\s*\d+', 'EnableGuestAccount = 0'

        # Audit Policies
        $PolicyContent = $PolicyContent -replace 'AuditSystemEvents\s*=\s*\d+', 'AuditSystemEvents = 3'
        $PolicyContent = $PolicyContent -replace 'AuditLogonEvents\s*=\s*\d+', 'AuditLogonEvents = 3'
        $PolicyContent = $PolicyContent -replace 'AuditObjectAccess\s*=\s*\d+', 'AuditObjectAccess = 3'
        $PolicyContent = $PolicyContent -replace 'AuditPrivilegeUse\s*=\s*\d+', 'AuditPrivilegeUse = 3'
        $PolicyContent = $PolicyContent -replace 'AuditPolicyChange\s*=\s*\d+', 'AuditPolicyChange = 3'
        $PolicyContent = $PolicyContent -replace 'AuditAccountManage\s*=\s*\d+', 'AuditAccountManage = 3'
        $PolicyContent = $PolicyContent -replace 'AuditProcessTracking\s*=\s*\d+', 'AuditProcessTracking = 3'
        $PolicyContent = $PolicyContent -replace 'AuditDSAccess\s*=\s*\d+', 'AuditDSAccess = 3'
        $PolicyContent = $PolicyContent -replace 'AuditAccountLogon\s*=\s*\d+', 'AuditAccountLogon = 3'

        # Security Options Policies
        $PolicyContent += "`nMACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\LegalNoticeCaption=1,Legal Notice"

        $PolicyContent += "`nMACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\LegalNoticeText=7,Unauthorized access to the system is prohibited."

        $PolicyContent += "`nMACHINE\System\CurrentControlSet\Control\Lsa\RestrictAnonymous=4,1"
        $PolicyContent += "`nMACHINE\System\CurrentControlSet\Control\Lsa\NoLMHash=4,1"
        $PolicyContent += "`nMACHINE\System\CurrentControlSet\Control\Lsa\LmCompatibilityLevel=4,5"

        # User Rights Assignment Policies
        $PolicyContent += "`n[Privilege Rights]"
        $PolicyContent += "`nSeDebugPrivilege = "
        $PolicyContent += "`nSeRemoteShutdownPrivilege = "
        $PolicyContent += "`nSeDenyNetworkLogonRight = *S-1-5-32-546"
        $PolicyContent += "`nSeDenyInteractiveLogonRight = *S-1-5-32-546"
        $PolicyContent += "`nSeDenyRemoteInteractiveLogonRight = *S-1-5-32-546"

        # Write the modified content to the file
        $PolicyContent | Set-Content -Path $NewIniFilePath -Force
    } catch {
        Write-Error "`nFailed to modify the policy file. Ensure the file is not locked or in use."
        return
    }

    # Apply the updated policies using secedit
    try {
        # Specify the database file location in the POLICIES folder
        secedit.exe /import /db $DatabaseFilePath /cfg $NewIniFilePath
        secedit.exe /configure /db $DatabaseFilePath
    } catch {
        Write-Error "`nFailed to apply the updated security policies."
        return
    }

    # Apply the changes
    try {
        gpupdate /force
    } catch {
        Write-Error "`nFailed to run gpupdate."
        return
    }

    # Print confirmation
    Write-Output "`nLocal Security Policy has been configured. Check '$PoliciesFolderPath'"
}

# Call the function
Invoke-secpolconf
