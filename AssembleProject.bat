@echo off

REM Script to generate assembly file of project

REM DASM Specific variables
set DASMDir=DASM
set DASMPath="%DASMDir%/Dasm.exe"
set OutputDir=Output/
set SourceDir=Source/
set DefaultArgs=-f3 -v5
set LogModifer=-l
set OutputModifer=-o
set IncludeModifier=-Idir

echo Directory is %DASMDir%
echo Path is %DASMPath%
echo OutputDir is %OutputDir%
echo SourceDir is %SourceDir%
echo Default args are %DefaultArgs%
echo LogModifer is %LogModifer%
echo OutputModifer is %OutputModifer%
echo IncludeModifer is %IncludeModifier%

REM Use default if none provided
set DefaultOutputName=Test
set OutputName=%DefaultOutputName%

if NOT "%1"=="" set OutputName=%1

echo Using output prefix of %OutputName%

REM Run DASM
set Command=%DASMPath% %SourceDir%%OutputName%.asm  %LogModifer%%OutputDir%%OutputName%.txt %DefaultArgs% %OutputModifer%%OutputDir%%OutputName%.bin

echo command call looks like %Command%

call %Command%

pause

EXIT