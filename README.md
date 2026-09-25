# secpol-security-config
Config file for securing systems that are not domain-joined. This config will edit Local Security Policy rules and permissions. \
This was originally created for CCDC (Collegiate Cyber Defense Competition). \
This config can be used by anybody, as this has some everyday security policies that should be used by everyone. 

## How to Use
1. Launch PowerShell as Administrator.
2. Navigate to the config file's directory.
3. The script is unsigned and from the internet so you will need to momentarily bypass the execution policy.
```
Set-ExecutionPolicy Bypass -Force
```
4. Run the script. No need to call the function as it is called at the end of the script.
6. When done, you will receive an output message stating that the policies have been configured.

## Features
- All files are saved in a folder onto the current user's Desktop.
- Backup of original config gets created.
- Modify Password Policies.
- Modify Account Lockout Policies.
- Modify Audit Policies.
- Modify Security Options.
- Modify User Rights Assignment Policies.

## History
I first created this config file in March 2025 as I was preparing for NCCDC qualifiers, AKA MWCCDC Regionals. \
This was one of the scripts that helped us secure our systems that were not domain-joined, which were the non-AD servers and workstation. \
This saved so much time during competition. When you have to secure multiple systems at the same time, a run-and-done script feels amazing. \
At the end of it all, we won MWCCDC so the work I put in to dev this was totally worth it.
