
echo param 1 is %1
echo perl is %perl%

rem set this to the mvn version + ".0" (windows resources versions have four numeric components apparently)
rem set DDCLIENT_VERSION=1.0.1.0
set DDCLIENT_VERSION=%1

rem see http://search.cpan.org/~rschupp/PAR-Packer-1.014/lib/pp.pm
rem NB(1): supplying an .ico containing anything over 32x32 here doesn't work
rem NB(2): calling  c:\perl\site\bin\pp.bat here doesn't work
rem NB(3): this doesn't seem to work in 64-bit perl, either

%PERL% %PERL%\..\..\site\bin\pp --icon "c:\setup\ddclient-3.8.1\ddclient32.ico" -o ddclient.exe ddclient
%PERL% %PERL%\..\..\site\bin\pp --gui --icon "c:\setup\ddclienght-3.8.1\ddclient32.ico" -o ddclient-noconsole.exe ddclient

rem verpath sourced from http://www.codeproject.com/Articles/37133/Simple-Version-Resource-Tool-for-Windows
rem NB(3): verpatch appears to trim the last character from the strings here in procexp (but not in windows explorer)

verpatch ..\resources\ddclient.exe %DDCLIENT_VERSION% /fn /s company "randomnoun" /s description "A Dynamic DNS client" /s copyright "(c) 2013-2014 randomnoun Creative Commons Attribution 3.0 Unported License" /s product ddclient /pv %DDCLIENT_VERSION%

verpatch ..\resources\ddclient-noconsole.exe %DDCLIENT_VERSION% /fn /s company "randomnoun" /s description "A Dynamic DNS client" /s copyright "(c) 2013-2014 randomnoun Creative Commons Attribution 3.0 Unported License" /s product ddclient /pv %DDCLIENT_VERSION%

exit 0