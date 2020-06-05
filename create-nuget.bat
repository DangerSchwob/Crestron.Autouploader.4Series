@echo off
set /p id="Enter Version: "

del .\BuildTemp\* /F /Q
copy .\Autouploader\* .\BuildTemp\*

powershell -Command "(gc .\BuildTemp\Crestron.Autouploader.4Series.nuspec) -replace '###VERSION###', '%id%' | Out-File -encoding ASCII .\BuildTemp\Crestron.Autouploader.4Series.nuspec"
powershell -Command "(gc .\BuildTemp\Crestron.Autouploader.4Series.targets) -replace '###VERSION###', '%id%' | Out-File -encoding ASCII .\BuildTemp\Crestron.Autouploader.4Series.targets"

.\nuget.exe pack .\BuildTemp\Crestron.Autouploader.4Series.nuspec
PAUSE