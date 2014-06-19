rem set this to the mvn version + ".0" (windows resources versions have four numeric components apparently)
set DDCLIENT_VERSION=1.0.1.0

rem see http://search.cpan.org/~rschupp/PAR-Packer-1.014/lib/pp.pm
rem NB(1): supplying an .ico containing anything over 32x32 here doesn't work
rem NB(2): calling  c:\perl\site\bin\pp.bat here doesn't work
rem NB(3): this doesn't seem to work in 64-bit perl, either

c:\perl\bin\perl c:\perl\site\bin\pp --icon "c:\setup\ddclient-3.8.1\ddclient32.ico" -o ddclient.exe ddclient
c:\perl\bin\perl c:\perl\site\bin\pp --gui --icon "c:\setup\ddclient-3.8.1\ddclient32.ico" -o ddclient-noconsole.exe ddclient

rem verpath sourced from http://www.codeproject.com/Articles/37133/Simple-Version-Resource-Tool-for-Windows
rem NB(3): verpatch appears to trim the last character from the strings here in procexp (but not in windows explorer)

verpatch ddclient.exe %DDCLIENT_VERSION% /fn /s company "randomnoun" /s description "A Dynamic DNS client" /s copyright "(c) 2013-2014 randomnoun Creative Commons Attribution 3.0 Unported License" /s product ddclient /pv %DDCLIENT_VERSION%

verpatch ddclient-noconsole.exe %DDCLIENT_VERSION% /fn /s company "randomnoun" /s description "A Dynamic DNS client" /s copyright "(c) 2013-2014 randomnoun Creative Commons Attribution 3.0 Unported License" /s product ddclient /pv %DDCLIENT_VERSION%
