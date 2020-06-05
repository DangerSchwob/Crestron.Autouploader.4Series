Thanks for using AutoUploader

After compiling your program you will get a popup to enter the details for uploading.

-----!!!!IMPORTANT!!!!------
The AutoUploader is based on PowerShell and the SSH Client POSH-SSH, to use this, 
you need to do the following steps when you install AutoUploader the first time on a PC.

1.) Open PowerShell as administrator
2.) Allow the execution of PowerShell scripts with this command
		Set-ExecutionPolicy Unrestricted -Scope CurrentUser
3.) Install the SSH client POSH-SSH with this command
		Install-Module -Name Posh-SSH


All connection details you enter in the AutoUploader, will be stored in a *.auc file in 
the project folder. The password will be additional encrypted with the SecureString 
method of .Net. The stored password is only readable from the User and PC combination
who saved the password.
----------------------------


The uploader supporting 2 types of projects SimplSharpLibrary (clz) and SimplSharpPro (cpz)

SimplSharpLibrary:
-> The programming will be stopped
-> All dll files from the folder with the clz will be uploaded to the control system
-> Starting the programming again

SimplSharpPro
-> Uploading the cpz file to the control system
-> Loading program


The uploader is based on PowerShell and Windows Forms.


This tool is written by DangerSchwob