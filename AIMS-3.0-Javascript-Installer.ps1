#-----------------------------------------------------------------#
# Created 01/02/2024 for use with AIMS 3.0 Database installation. #
#-----------------------------------------------------------------#

# This is the javascript code that will be written to the file.
$jsCode = 
@"
        function LockAfterSigning(sMyActions, sMyFields, sMySignature) { 
            app.beginPriv();

                var arrMyFields = sMyFields.split(','); 
                var MyLock = {action:sMyActions,fields:arrMyFields}; 
                var f = this.getField(sMySignature); 
                var oLock = f.getLock(); 
                oLock = MyLock; 
                f.setLock(oLock); 
            app.endPriv(); 
        }
"@

Write-Host "            AIMS 3.0 Javacript Installer"
Write-Host "-----------------------------------------------------"
Write-Host "Please select your user type:"
Write-Host "Admin User - [1] - *Administator privileges required*"
Write-Host "Basic User - [2]"
Write-Host "Exit       - [0]"
Write-Host " "
Write-Host "-----------------------------------------------------"
$choice = Read-Host "Enter your choice: "

switch ($choice) {
    1 { # Workstation Admin
        # Code Snippet from https://stackoverflow.com/questions/63342982/how-to-powershell-script-ask-for-administrator-rights
        # Forces UAC pop up for admin rights. User will have to go through the selection and select 1 again to complete the script.
        # Can be bypassed if they run from powershell as an admin initially.
        if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
            Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
            Exit
        # End Snippet
        } else {
            # This portion will run if admin rights are present.
            Write-Host "You selected admin user, checking for directory now..."
            Write-Host "Checking for directory now..."
            $jsDirectory = "C:\Program Files (x86)\Adobe\Acrobat X.0\Acrobat\Javascripts\"
            
            # Check if directory exists, if not create it.
            if (-not (Test-Path $jsDirectory)) {
                Write-Host "Directory not found, creating..."
                New-Item -ItemType Directory -Path $jsDirectory | Out-Null
                
            } else {
                # Directory exists, continue.
                Write-Host "Directory found, continuing..."
            }     

            # Create the LockAfterSigning.js file in the created directory.
            Write-Host "Creating LockAfterSigning.js..."
            $jsFilePath = Join-Path -Path $jsDirectory -ChildPath "LockAfterSigning.js"
            $jsCode | Out-File -FilePath $jsFilePath -Encoding UTF8
            Write-Host "Complete!"
            Write-Host "-----------------------------------------------------"
            
            #Press any key to continue...
            cmd /c pause
        }
    }
    2 { # Basic User
        Write-Host "You selected basic user, checking for directory now..."
        $currentUser = $env:USERNAME
        $jsDirectory = "C:\Users\$currentUser\AppData\Roaming\Adobe\Acrobat\Privileged\DC\JavaScripts"
        
        # Check if directory exists, if not create it.
        if (-not (Test-Path $jsDirectory)) {
            Write-Host "Directory not found, creating..."
            New-Item -ItemType Directory -Path $jsDirectory | Out-Null
            
        } else {
            # Directory exists, continue.
            Write-Host "Directory found, continuing..."
        }     
        
        $files = Get-ChildItem -Path $jsDirectory
        $jsCheck = $files | Where-Object { $_.Name -eq "LockAfterSigning.js" }

        if ($jsCheck) {
            # Check if LockAfterSigning.js exists
            Write-Host "LockAfterSigning.js file exists."
        } else {
            # Create js if it does not exist
            Write-Host "LockAfterSigning.js file does not exist."
            Write-Host "Creating LockAfterSigning.js..."
            $jsFilePath = Join-Path -Path $jsDirectory -ChildPath "LockAfterSigning.js"
            $jsCode | Out-File -FilePath $jsFilePath -Encoding UTF8
            Write-Host "Complete!"
            Write-Host "-----------------------------------------------------"
        }
        #Press any key to continue...
        cmd /c pause
    }
    0 { # Exit
        Write-Host "Exiting..."
        return
    }
    default { # Invalid choice
        Write-Host "Invalid choice. Please enter 1, 2, or 0."
    }
}