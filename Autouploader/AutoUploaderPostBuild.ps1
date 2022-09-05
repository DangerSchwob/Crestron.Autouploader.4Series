param(
[string]$uploaderFile,
[bool]$debug = $false
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO

Import-Module Posh-SSH


#-----------FUNCTIONS------------------------------
function createUploadParameterForm()
{
    [OutputType([System.Windows.Forms.Form])]

    
    $currentLinePos = 5;
    $lineHeight = 20;


    #--------- Form -------------------
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'AutoUploader'
    $form.Size = New-Object System.Drawing.Size(300,390)
    $form.StartPosition = 'CenterScreen'
    $form.FormBorderStyle = "Fixed3D";

    #--------- Tooltip -------------------
    $toolTip = New-Object System.Windows.Forms.ToolTip
    $toolTip.AutoPopDelay = 5000;
    $toolTip.InitialDelay = 500;
    $toolTip.ReshowDelay = 500;
    $toolTip.ShowAlways = $true;

    #--------- Upload Address -------------------

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $label.Size = New-Object System.Drawing.Size(260,20)
    $label.Text = 'Enter address for upload:'
    $form.Controls.Add($label)

    $currentLinePos += $lineHeight

    $field = New-Object System.Windows.Forms.TextBox
    $field.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $field.Size = New-Object System.Drawing.Size(260,20)
    $field.Text = $controlSystem.address
    $field.Name = "FieldAddress"
    $field.add_MouseHover({
        $toolTip.SetToolTip($this, "The IP-Address or the Hostname of the 4-Series Crestron control system.")
    })
    $form.Controls.Add($field)

    #--------- Slot -------------------
    $currentLinePos += $lineHeight*1.5

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $label.Size = New-Object System.Drawing.Size(260,20)
    $label.Text = 'Select slot number:'
    $form.Controls.Add($label)

    $currentLinePos += $lineHeight

    $field = New-Object System.Windows.Forms.Combobox
    $field.Location = New-Object System.Drawing.Size(10,$currentLinePos)
    $field.Size = New-Object System.Drawing.Size(260,50)
    for ($i=1; $i -le 10; $i++)
    {
        $field.Items.Add("Slot $i") | Out-Null
    }
    $field.SelectedIndex = (($controlSystem.slot)-1);
    $field.Name = "FieldSlot"
    $field.DropDownStyle = "DropDownList"
    $field.add_MouseHover({
        $toolTip.SetToolTip($this, "Program slot of the control system you want use.")
    })
    $form.Controls.Add($field)

    #--------- Username -------------------
    $currentLinePos += $lineHeight*1.5

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $label.Size = New-Object System.Drawing.Size(260,20)
    $label.Text = 'Username:'
    $form.Controls.Add($label)

    $currentLinePos += $lineHeight

    $field = New-Object System.Windows.Forms.TextBox
    $field.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $field.Size = New-Object System.Drawing.Size(260,20)
    $field.Text = $controlSystem.username
    $field.Name = "FieldUsername"
    $field.add_MouseHover({
        $toolTip.SetToolTip($this, "Username for the SSH authentication on the control system")
    })
    $form.Controls.Add($field)

    #--------- Selection Authentication Type -------------------
    $currentLinePos += $lineHeight*1.5

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $label.Size = New-Object System.Drawing.Size(260,20)
    $label.Text = 'Authentication type:'
    $form.Controls.Add($label)

    $currentLinePos += $lineHeight

    $AuthenticationTypePasswordSelected = {
        $form.Controls["FieldAuthenticationTypePassword"].Checked = $true
        $form.Controls["FieldAuthenticationTypeSSHKey"].Checked = $false
        $form.Controls["LabelPassword"].Text = "Password:"
        $form.Controls["LabelSSHKeyPath"].Visible = $false
        $form.Controls["FieldSSHKeyPath"].Visible = $false
        $form.Controls["ButtonSSHKeyPath"].Visible = $false
    }

    $AuthenticationTypeSSHKeySelected = {
        $form.Controls["FieldAuthenticationTypePassword"].Checked = $false
        $form.Controls["FieldAuthenticationTypeSSHKey"].Checked = $true
        $form.Controls["LabelPassword"].Text = "Passphrase:"
        $form.Controls["LabelSSHKeyPath"].Visible = $true
        $form.Controls["FieldSSHKeyPath"].Visible = $true
        $form.Controls["ButtonSSHKeyPath"].Visible = $true
    }

    $field = New-Object System.Windows.Forms.RadioButton 
    $field.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $field.Size = New-Object System.Drawing.Size(80,20)
    $field.Text = "Password";
    $field.Name = "FieldAuthenticationTypePassword"
    $field.Add_Click($AuthenticationTypePasswordSelected)
    $field.add_MouseHover({
        $toolTip.SetToolTip($this, "For authentication a username and a password will be used.")
    })
    $form.Controls.Add($field)

    $field = New-Object System.Windows.Forms.RadioButton 
    $field.Location = New-Object System.Drawing.Point(90,$currentLinePos)
    $field.Size = New-Object System.Drawing.Size(80,20)
    $field.Text = "SSH Key";
    $field.Name = "FieldAuthenticationTypeSSHKey"
    $field.Add_Click($AuthenticationTypeSSHKeySelected)
    $field.add_MouseHover({
        $toolTip.SetToolTip($this, "For authentication a username and a SSH key with passphrase will be used.")
    })
    $form.Controls.Add($field)

    #--------- Password -------------------
    $currentLinePos += $lineHeight*1.5

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $label.Size = New-Object System.Drawing.Size(260,20)
    $label.Text = "Password:"
    $label.Name = "LabelPassword"
    $form.Controls.Add($label)

    $currentLinePos += $lineHeight

    $field = New-Object System.Windows.Forms.TextBox
    $field.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $field.Size = New-Object System.Drawing.Size(260,20)

    if($password -eq "")
    {
        $field.Text = ""
    }
    else
    {
        $field.Text = "###USE#SAVED#PASSWORD#FOR#LOGIN###"
    }
    
    $field.Name = "FieldPassword"
    $field.UseSystemPasswordChar = $true
    $form.Controls.Add($field)

    #--------- SSH Key File -------------------
    $currentLinePos += $lineHeight*1.5

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $label.Size = New-Object System.Drawing.Size(260,20)
    $label.Text = 'SSH Key File:'
    $label.Name = "LabelSSHKeyPath"
    $form.Controls.Add($label)

    $currentLinePos += $lineHeight

    $field = New-Object System.Windows.Forms.TextBox
    $field.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $field.Size = New-Object System.Drawing.Size(185,20)
    $field.Text = $controlSystem.sshkeypath
    $field.Name = "FieldSSHKeyPath"
    $form.Controls.Add($field)

    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog

    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Point(195,$currentLinePos)
    $Button.Size = New-Object System.Drawing.Size(75,20)
    $Button.Text = 'Browse'  
    $Button.Name = "ButtonSSHKeyPath"  
    $Button.Add_Click({
        $fileBrowser.ShowDialog()
        $form.Controls["FieldSSHKeyPath"].Text = $fileBrowser.FileName
    })
    $form.Controls.Add($Button)

    #--------- Set all for Password or SSHKey -------------------
    if($controlSystem.usesshkey -eq $true)
    {
        & $AuthenticationTypeSSHKeySelected
    }
    else
    {
        & $AuthenticationTypePasswordSelected
    }


    #--------- Buttons -------------------
    $currentLinePos += $lineHeight*2



    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Point(75,$currentLinePos)
    $Button.Size = New-Object System.Drawing.Size(75,23)
    $Button.Text = 'Upload'
    $Button.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $Button
    $form.Controls.Add($Button)

    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Point(150,$currentLinePos)
    $Button.Size = New-Object System.Drawing.Size(75,23)
    $Button.Text = 'Cancel'
    $Button.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $Button
    $form.Controls.Add($Button)

    $form.Topmost = $true

    $form.Add_Shown({$form.Controls["FieldAddress"].Select()})
    $result = $form.ShowDialog()
    
    
    return $form

}
#--------------------------------------------------
function createStatusForm()
{
    [OutputType([System.Windows.Forms.Form])]

    
    $currentLinePos = 5;
    $lineHeight = 20;

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Auto uploader'
    $form.Size = New-Object System.Drawing.Size(400,300)
    $form.StartPosition = 'CenterScreen'
    

    #--------- Upload Address -------------------

    $status = New-Object System.Windows.Forms.Textbox
    $status.Location = New-Object System.Drawing.Point(10,$currentLinePos)
    $status.Size = New-Object System.Drawing.Size(360,250)
    $status.Text = ""
    $status.Name = "FieldStatus"
    $status.Multiline = $true
    $status.ScrollBars = "Vertical"
    $status.ReadOnly = $true
    $form.Controls.Add($status)

    $form.Topmost = $true

    $form.Add_Shown({$status.Select()})
    $result = $form.Show()
    
    
    return $form

}
#--------------------------------------------------
try
{
    #Check if uploader file exist
    if((Test-Path $uploaderFile) -eq $false)
    {
       throw "UPLOADER FILE NOT FOUND: $uploaderFile"
    }

    $file = New-Object System.IO.FileInfo -ArgumentList $uploaderFile
    $configFolder = $file.Directory.Parent.Parent.FullName

    #Check if configuration file is availble and loading the configuration
    $controlSystem = @{}
    if((Test-Path "$configFolder\AutoUploaderConfig.auc") -eq $true)
    {
        $controlSystem = (Get-Content -Path "$configFolder\AutoUploaderConfig.auc") | ConvertFrom-Json
    }

    #Check if configruation parameter is missing, because the configuration file is from an older version
    if(![bool]($controlSystem.PSobject.Properties.name -match "address"))
    { $controlSystem | add-member NoteProperty "address" "" }
    if(![bool]($controlSystem.PSobject.Properties.name -match "slot"))
    { $controlSystem | add-member NoteProperty "slot" 1 }
    if(![bool]($controlSystem.PSobject.Properties.name -match "username"))
    { $controlSystem | add-member NoteProperty "username" "" }
    if(![bool]($controlSystem.PSobject.Properties.name -match "password"))
    { $controlSystem | add-member NoteProperty "password" "" }
    if(![bool]($controlSystem.PSobject.Properties.name -match "usesshkey"))
    { $controlSystem | add-member NoteProperty "usesshkey" $false }
    if(![bool]($controlSystem.PSobject.Properties.name -match "sshkeypath"))
    { $controlSystem | add-member NoteProperty "sshkeypath" "" }

    #read password from config file and check if the password can be used.
    #The password from the config can only be used if the SAME user on the SAME PC open the config.
    $password = ""
    try
    {
        $password = ConvertTo-SecureString -String $controlSystem.password
    }
    catch
    {}




    
    #Prompt the user form
    $uploadParameterForm = createUploadParameterForm -controlSystem $controlSystem -password $password

    #If user press cancle, stop script
    if ($uploadParameterForm.DialogResult -eq [System.Windows.Forms.DialogResult]::Cancel)
    {
        throw "NOERROR"
    }




    #Copy the data from the form to the variable and rewrite the config file
    $controlSystem.address = $uploadParameterForm.Controls["FieldAddress"].Text
    $controlSystem.slot = $uploadParameterForm.Controls["FieldSlot"].SelectedIndex+1
    $controlSystem.username = $uploadParameterForm.Controls["FieldUsername"].Text

    if($uploadParameterForm.Controls["FieldPassword"].Text -eq "###USE#SAVED#PASSWORD#FOR#LOGIN###")
    {}
    elseif($uploadParameterForm.Controls["FieldPassword"].Text -eq "")
    {
        $password = (new-object System.Security.SecureString);
    }
    else
    {
        $password = $uploadParameterForm.Controls["FieldPassword"].Text | ConvertTo-SecureString -AsPlainText -Force    
    }
    $controlSystem.password = ConvertFrom-SecureString $password

    $controlSystem.usesshkey = $uploadParameterForm.Controls["FieldAuthenticationTypeSSHKey"].Checked
    $controlSystem.sshkeypath = $uploadParameterForm.Controls["FieldSSHKeyPath"].Text
    
    New-Item -Path $configFolder -Name "AutoUploaderConfig.auc" -ItemType "file" -Value ($controlSystem | ConvertTo-Json) -Force | Out-Null






    #Promp status form with the ticker
    $statusForm = createStatusForm

    $projectType = ""
    if(Test-Path $file.FullName.Replace($file.Extension,".cpz"))
    {
        $file = New-Object System.IO.FileInfo -ArgumentList ($file.FullName.Replace($file.Extension,".cpz"))
        $projectType = "cpz"
    }
    elseif(Test-Path $file.FullName.Replace($file.Extension,".clz"))
    {
        $projectType = "clz"
    }
    else
    {
        throw "UNKOWN Project type, don't know if clz or cpz"
    }



    #Create credential
    $credential = New-Object System.Management.Automation.PSCredential ($controlSystem.username , $password)
    

    $Timeout = 10
    $SFTPSession = ""
    $SSHSession = ""
              
    Try
    {
        #create SFTP and SSH session
        try
        {
            if($controlSystem.usesshkey -eq $true) #Authentication via Username/SSH key file
            {
                $SFTPSession = New-SFTPSession -ComputerName $controlSystem.address -Credential $credential -ConnectionTimeout $Timeout -AcceptKey:$true -ErrorAction Stop  -KeyFile $controlSystem.sshkeypath #-Verbose
                $SSHSession = New-SSHSession -ComputerName $controlSystem.address -Credential $credential -ConnectionTimeout $Timeout -AcceptKey:$true -ErrorAction Stop  -KeyFile $controlSystem.sshkeypath # -Verbose
            }
            else #Authentication via Username/Password
            {
                $SFTPSession = New-SFTPSession -ComputerName $controlSystem.address -Credential $credential -ConnectionTimeout $Timeout -AcceptKey:$true -ErrorAction Stop #-Verbose
                $SSHSession = New-SSHSession -ComputerName $controlSystem.address -Credential $credential -ConnectionTimeout $Timeout -AcceptKey:$true -ErrorAction Stop # -Verbose
            }
        }
        catch [System.InvalidOperationException]
        {
            throw "Error in connection to control system: SSH Key passphrase wrong"
        }
        catch [System.Management.Automation.ItemNotFoundException]
        {
            throw "Error in connection to control system: Unable to find SSH Key file"
        }
        catch [Renci.SshNet.Common.SshException]
        {
            throw "Error in connection to control system: {0}" -f $_.Exception.Message
        }
        catch
        {
            throw "Unkown error in the control sytem connection: {0}" -f $_.Exception.GetType().Name # $_.Exception.Message
        }
        
        $statusForm.Controls["FieldStatus"].AppendText("Project type: {0}`r`n" -f $projectType)





        #check for project type
        if($projectType -eq "cpz")
        {
            $file = New-Object System.IO.FileInfo -ArgumentList ($file.FullName.Replace($file.Extension,".cpz"))

            #upload cpz file
            $statusForm.Controls["FieldStatus"].AppendText("Upload starting`r`n")
            Set-SFTPItem -SFTPSession $SFTPSession -Path $file.FullName -Destination ("/program{0:00}" -f $controlSystem.slot) -Force
            $statusForm.Controls["FieldStatus"].AppendText("Upload done`r`n")
            #load programming
            $statusForm.Controls["FieldStatus"].AppendText("Program starting.`r`n")
            $stream = New-SSHShellStream -SSHSession $SSHSession
            $null = Invoke-SSHStreamShellCommand -ShellStream $stream -Command ("progload -p:{0}" -f $controlSystem.slot)
            $cmdOut = $stream.Read()
            while ($cmdOut -notlike "*Program(s) Started...*" -and $cmdOut -notlike "*Unable to load new program*") {
                $statusForm.Controls["FieldStatus"].AppendText(".")
                if($debug){ $statusForm.Controls["FieldStatus"].AppendText("$cmdOut") }
                Start-Sleep  -Milliseconds 500
                $cmdOut = $stream.Read()
            }

            if($cmdOut -like "*Unable to load new program*")
            {
                throw "Unable to start program"
            }


            $statusForm.Controls["FieldStatus"].AppendText("`r`nProgram started")
        }
        elseif($projectType -eq "clz")
        {
            #stop the programming
            $statusForm.Controls["FieldStatus"].AppendText("Program stopping")
            $stream = New-SSHShellStream -SSHSession $SSHSession
            $null = Invoke-SSHStreamShellCommand -ShellStream $stream -Command ("stopprog -p:{0}" -f $controlSystem.slot)
            $cmdOut = $stream.Read()
            while ($cmdOut -notlike ("*``*``*Program Stopped:{0}``*``**" -f $controlSystem.slot) -and $cmdOut -notlike "*Specified App does not exist*") {
                $statusForm.Controls["FieldStatus"].AppendText(".")
                if($debug){ $statusForm.Controls["FieldStatus"].AppendText("$cmdOut") }
                Start-Sleep -Milliseconds 500
                $cmdOut = $stream.Read()
            }
            if($cmdOut -like "*Specified App does not exist*")
            {
                throw "No programm running in this slot"
            }
            $statusForm.Controls["FieldStatus"].AppendText("Program stopped")

            #upload all dll files from the uploadFile folder. In this case, also new dlls or changed dlls will be uploaded
            $statusForm.Controls["FieldStatus"].AppendText("`r`n")
            $statusForm.Controls["FieldStatus"].AppendText("Upload starting`r`n")
            Get-ChildItem -Path $file.Directory -Filter *.dll | ForEach-Object {
                $statusForm.Controls["FieldStatus"].AppendText("--> {0}`r`n" -f $_.Name)
                Set-SFTPFile -SFTPSession $SFTPSession -LocalFile $_.FullName -RemotePath ("/program{0:00}" -f $controlSystem.slot) -Overwrite:$true
            }
            $statusForm.Controls["FieldStatus"].AppendText("Upload done`r`n")

            #start programming again
            $statusForm.Controls["FieldStatus"].AppendText("`r`n")
            $statusForm.Controls["FieldStatus"].AppendText("Program starting.`r`n")
            $stream = New-SSHShellStream -SSHSession $SSHSession
            $null = Invoke-SSHStreamShellCommand -ShellStream $stream -Command ("progreset -p:{0}" -f $controlSystem.slot)
            $cmdOut = $stream.Read()
            while ($cmdOut -notlike "*Program(s) Started...*") {
                $statusForm.Controls["FieldStatus"].AppendText(".")
                if($debug){ $statusForm.Controls["FieldStatus"].AppendText("$cmdOut") }
                Start-Sleep  -Milliseconds 500
                $cmdOut = $stream.Read()
            }
            $statusForm.Controls["FieldStatus"].AppendText("`r`nProgram started")
        }
        
    }
    Catch
    {
        throw $_.Exception.Message
    }
    Finally
    {
        Remove-SFTPSession $SFTPSession | Out-Null
        Remove-SSHSession $SSHSession | Out-Null
    }

    $password.Clear()            
    $password.Dispose()
}
catch
{
    if($_.Exception.Message -ne "NOERROR")
    {
        if($statusForm -eq $null)
        {
            $statusForm = createStatusForm
        }
            
        $statusForm.Controls["FieldStatus"].AppendText("`r`n---- ERROR -----")
        $statusForm.Controls["FieldStatus"].AppendText("`r`n{0}" -f $_.Exception.Message)
        Start-Sleep -Seconds 4
        
    }
}
finally
{
    if($statusForm -ne $null)
    {
        Start-Sleep -Seconds 1
        $statusForm.close()
    }
}
