@echo off
rem make-ddclient-exe.bat
rem
rem Batch file to compile the ddclient perl source into a gui and console .exe files, then post-process
rem these files to add Windows icon and version resources.
 

rem parameters are set from within mvn
set DDCLIENT_VERSION=%1
echo Building ddclient %DDCLIENT_VERSION%

rem see http://search.cpan.org/~rschupp/PAR-Packer-1.014/lib/pp.pm
rem NB(1): supplying an .ico containing anything over 32x32 here doesn't work
rem NB(2): calling  c:\perl\site\bin\pp.bat here doesn't work
rem NB(3): this doesn't seem to work in 64-bit perl, either
rem NB(4): verpatch appears to trim the last character from the strings here in procexp (but not in windows explorer)

rem verpatch sourced from http://www.codeproject.com/Articles/37133/Simple-Version-Resource-Tool-for-Windows
rem resourcehacker sourced from http://angusj.com/resourcehacker/#download

rem --icon no longer supported in pp (see http://stackoverflow.com/questions/22607334 )
rem %PERL% %PERL%\..\..\site\bin\pp --icon "..\resources\ddclient32.ico" -o ..\..\..\target\ddclient-noicon.exe ddclient
rem %PERL% %PERL%\..\..\site\bin\pp --gui --icon "..\resources\ddclient32.ico" -o ..\..\..\target\ddclient-noconsole-noicon.exe ddclient

echo Compiling ddclient.exe
%PERL% %PERL%\..\..\site\bin\pp  --link %PERL%\..\..\..\c\bin\libssl-1_1-x64__.dll --link %PERL%\..\..\..\c\bin\zlib1__.dll --link %PERL%\..\..\..\c\bin\libcrypto-1_1-x64__.dll -o ..\..\..\target\ddclient-noicon.exe ddclient

rem win32::exe no longer works
rem %PERL% -e "use Win32::Exe; $exe = Win32::Exe->new('..\..\..\target\ddclient.exe'); $exe->set_single_group_icon('..\resources\ddclient32.ico'); $exe->write;"

rem ResourceHacker.exe -open ..\..\..\target\ddclient.exe -save ddclient.exe -action modify -res ..\resources\ddclient32.ico -mask ICONGROUP,WINEXE,1033
ResourceHacker.exe -open ..\..\..\target\ddclient-noicon.exe -save ..\..\..\target\ddclient.exe -action modify -res ..\resources\ddclient32.ico -mask ICONGROUP,WINEXE,1033
del ..\..\..\target\ddclient-noicon.exe
verpatch ..\..\..\target\ddclient.exe %DDCLIENT_VERSION% /fn /s company "randomnoun" /s description "A Dynamic DNS client" /s copyright "(c) 2013-2021 randomnoun Creative Commons Attribution 3.0 Unported License" /s product ddclient /pv %DDCLIENT_VERSION%

echo Compiling ddclient-noconsole.exe
%PERL% %PERL%\..\..\site\bin\pp --gui -o ..\..\..\target\ddclient-noconsole-noicon.exe ddclient
rem %PERL% -e "use Win32::Exe; $exe = Win32::Exe->new('..\..\..\target\ddclient-noconsole.exe'); $exe->set_single_group_icon('..\resources\ddclient32.ico'); $exe->write;"
rem ResourceHacker.exe -open ..\..\..\target\ddclient-noconsole.exe -save ddclient-noconsole2.exe -action modify -res ..\resources\ddclient32.ico -mask ICONGROUP,WINEXE,1033
ResourceHacker.exe -open ..\..\..\target\ddclient-noconsole-noicon.exe -save ..\..\..\target\ddclient-noconsole.exe -action modify -res ..\resources\ddclient32.ico -mask ICONGROUP,WINEXE,1033
del ..\..\..\target\ddclient-noconsole-noicon.exe
verpatch ..\..\..\target\ddclient-noconsole.exe %DDCLIENT_VERSION% /fn /s company "randomnoun" /s description "A Dynamic DNS client" /s copyright "(c) 2013-2021 randomnoun Creative Commons Attribution 3.0 Unported License" /s product ddclient /pv %DDCLIENT_VERSION%

exit 0