@echo off
REM we need nuget to install tools locally
if not exist tools\nuget\nuget.exe (
  ECHO Nuget not found.. Downloading..
    mkdir tools\nuget
  PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& 'scripts\download-nuget.ps1'"
)

REM ensure that F# tools are in place
if not exist tools\FSharp.Core\FSharp.Core.nupkg (
  ECHO FSharp.Core not found.. Downloading..
  "tools\nuget\nuget.exe" "install" "FSharp.Core" "-OutputDirectory" "tools" "-ExcludeVersion" "-Prerelease"
)

REM we need FAKE to process our build scripts
if not exist tools\FAKE\tools\Fake.exe (
  ECHO FAKE not found.. Installing..
  "tools\nuget\nuget.exe" "install" "FAKE" "-OutputDirectory" "tools" "-ExcludeVersion" "-Prerelease"
)

REM NUnit console to run NUnit and NaturalSpec tests
if not exist tools\NUnit.Runners\tools\lib\nunit-console.exe (
  ECHO NUnit.Runners not found.. Downloading..
  "tools\nuget\nuget.exe" "install" "NUnit.Runners" "-OutputDirectory" "tools" "-Version" "2.6.3" "-ExcludeVersion" "-Prerelease"
)

SET TARGET="Build"
SET VERSION=
IF NOT [%1]==[] (set TARGET="%1")
IF NOT [%2]==[] (set VERSION="%2")

shift
shift

"tools\FAKE\tools\Fake.exe" "build.fsx" "target=%TARGET%" "version=%VERSION%"
