rem anything over 32x32 doesn't work in pp.exe
c:\perl\site\bin\pp --icon "c:\setup\ddclient-3.8.1\ddclient32.ico" -o ddclient.exe ddclient

rem verpath sourced from http://www.codeproject.com/Articles/37133/Simple-Version-Resource-Tool-for-Windows
verpatch ddclient.exe 1.0.0.0 /fn /s company "randomnoun" /s description "A Dynamic DNS client" /s copyright "(c) 2013 randomnoun Creative Commons Attribution 3.0 Unported License" /s product ddclient /pv 1.0.0.0