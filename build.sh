#!/bin/bash
mkdir -p packages

NUGET="tools/nuget/nuget.exe"
FAKE="tools/FAKE/tools/FAKE.exe"
NUNIT="tools/NUnit.Runners/tools/nunit-console.exe"


RUNTIME=""
if hash mono 2>/dev/null; then
  if [ "$1" != "--lazy" ]; then
    mozroots --import --sync #Need mozroots for running mono (at least on linux)
  fi
  RUNTIME="mono"
fi

if [ "$1" = "--lazy" ]; then
  echo "#### Running in lazy mode! #####"
	$RUNTIME $FAKE "./" "build.fsx" lazy=true
  exit
fi


#we need nuget to install tools locally
if [[ ! -f "$NUGET" ]]; then
  echo NUGET not found.. Download...
  mkdir -p tools/nuget
  curl -o $NUGET https://nugetbuild.cloudapp.net/drops/client/master/NuGet.exe
fi

#we need FAKE to process our build scripts
if [[ ! -f "$FAKE" ]]; then
  echo FAKE not found.. Installing..
  $RUNTIME "$NUGET" "install" "FAKE" "-OutputDirectory" "tools" "-Version" "5.8.4" "-ExcludeVersion" "-Prerelease"
fi

#we need NUnit to run NaturalSpec and NUnit
if [[ ! -f "$NUNIT" ]]; then
  echo NUnit not found.. Installing..
  $RUNTIME "$NUGET" "install" "NUnit.Runners" "-OutputDirectory" "tools" "-Version" "3.11.0" "-ExcludeVersion" "-Prerelease"
fi


$RUNTIME $FAKE -ev findNuget "./" "build.fsx"
