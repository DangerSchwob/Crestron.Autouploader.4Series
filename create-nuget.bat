@echo off
set /p id="Enter Version: "

del .\NuGet-Build\* /F /Q
copy .Autouploader\* .\NuGet-Build\*

powershell -Command "(gc .\NuGet-Build\Crestron.Autouploader.4Series.nuspec) -replace '###VERSION###', '%id%' | Out-File -encoding ASCII .\NuGet-Build\Crestron.Autouploader.4Series.nuspec"
powershell -Command "(gc .\NuGet-Build\Crestron.Autouploader.4Series.targets) -replace '###VERSION###', '%id%' | Out-File -encoding ASCII .\NuGet-Build\Crestron.Autouploader.4Series.targets"

.\nuget.exe pack .\NuGet-Build\Crestron.Autouploader.4Series.nuspec
PAUSE