; ddclient desktop installer
; based on NSIS Modern User Interface example script written by Joost Verburg

; TODO: fix install service as custom user
; TODO: don't install service shortcuts when not installing service
; silent install resources:
;   http://nsis.sourceforge.net/Docs/Chapter4.html#4.12
;   http://forums.winamp.com/showthread.php?t=274505

;--------------------------------
;Include Modern UI

  ; building from src/main/nsi or target/main/nsi should have same directory depth
  ; it's entirely possible that PROJECT_VERSION is already set here in project.nsh anyway.
  !AddIncludeDir "..\..\..\target"    

  !include "MUI.nsh"    
  !include "internet-shortcut.nsh"
  !include nsDialogs.nsh
  !include LogicLib.nsh
  !include "project.nsh"
  !include FileFunc.nsh
  
  !insertmacro GetParameters
  !insertmacro GetOptions

  !addplugindir "..\..\..\target"
  !addplugindir "." ; for SimpleSC.dll and nsProcess.dlls

; the needed nsProcess DLLs required for uninstallation are automatically built into 
; the uninstaller. crikey.

;--------------------------------
;General

  ;Name and file
  Name "ddclient"
  ;OutFile set by maven
  ;OutFile "..\..\build\exe\something-v0.1.exe"

  ;Default installation folder (32-bit)
  InstallDir "$PROGRAMFILES\ddclient"

  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\Randomnoun\ddclient" "InstallDir"


;--------------------------------
;Variables

  Var MUI_TEMP
  Var STARTMENU_FOLDER

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define VERSION "${PROJECT_VERSION}"


;!define MUI_PAGE_CUSTOMFUNCTION_SHOW myShowCallback

;--------------------------------
;Pages

  !define MUI_FINISHPAGE_NOAUTOCLOSE

  !insertmacro MUI_PAGE_WELCOME
  ; !insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
  !insertmacro MUI_PAGE_LICENSE "License.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
Page custom DisplaySelectDdserverPage LeaveSelectDdserverPage
Page custom DisplaySelectServiceuserPage

  ;Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Randomnoun\ddclient" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
  !define MUI_STARTMENUPAGE_DEFAULTFOLDER "ddclient"
  !insertmacro MUI_PAGE_STARTMENU Application $STARTMENU_FOLDER

  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"


;--------------------------------
;Functions
Function .onInit
  ;Extract InstallOptions INI files
  ; !insertmacro MUI_INSTALLOPTIONS_EXTRACT "AdditionalTasksPage.ini"  
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "select-ddserver.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "select-serviceuser.ini"
  
  var /GLOBAL cmdLineParams
  Push $R0
  ${GetParameters} $cmdLineParams
  ClearErrors
  
  ${GetOptions} $cmdLineParams '/?' $R0
  IfErrors +3 0
  MessageBox MB_OK "Unattended Silent Installs:$\r$\n\
    /S$\t$\t= Silent install$\r$\n\
    /?$\t$\t= This help page.$\r$\n\
    $\r$\n\
    Settings for this machine:$\r$\n\
    /HOSTNAME=xxx$\t= The DNS name of this machine$\r$\n\
    $\r$\n\
    Settings for Dynamic DNS server:$\r$\n\
    /DDSERVER=xxx$\t= The name of the Dynamic DNS server$\r$\n\
    /DDCONNECTION=xxx = HTTP or HTTPS (default HTTP)$\r$\n\
    /DDPROTOCOL=xxx = One of: concont, dnspark, dslreports1, dtdns, dyndns1, dyndns2, easydns, freedns, hammernode1, namecheap, noip, sitelutions, zoneedit1 (default dyndns2)$\r$\n\
    /DDUSERNAME=xxx = Username authentication to the Dynamic DNS server$\r$\n\
    /DDPASSWORD=xxx = Password authentication to the Dynamic DNS server$\r$\n\
    $\r$\n\
    Service settings:$\r$\n\
    /SERVICEASNETWORKSERVICEUSER = Install ddclient as a service on this machine running as the Network Service account$\r$\n\
    /SERVICEASLOCALSYSTEMUSER = Run as the Local System account$\r$\n\
    /SERVICEASCUSTOMUSER = Run as a custom Windows user account$\r$\n\
    /SERVICEUSERNAME=xxx = local user account name$\r$\n\
    /SERVICEPASSWORD=xxx = local user account password$\r$\n\
    /NOSERVICE$\t= Do not install ddclient as a service$\r$\n\
    $\r$\n"
  Abort
  
  Pop $R0
  
  ; /HOSTNAME=
  ${GetOptions} $cmdLineParams /HOSTNAME= $R0
  IfErrors +2 0
  WriteINIStr "$PLUGINSDIR\select-ddserver.ini" "Field 2" "State" '$R0'
  
  ; /DDSERVER=
  ${GetOptions} $cmdLineParams /DDSERVER= $R0
  IfErrors +2 0
  WriteINIStr "$PLUGINSDIR\select-ddserver.ini" "Field 4" "State" '$R0'
   
  ; /DDUSERNAME=
  ${GetOptions} $cmdLineParams /DDUSERNAME= $R0
  IfErrors +2 0
  WriteINIStr "$PLUGINSDIR\select-ddserver.ini" "Field 7" "State" '$R0'
  
  ; /DDPASSWORD=
  ${GetOptions} $cmdLineParams /DDPASSWORD= $R0
  IfErrors +2 0
  WriteINIStr "$PLUGINSDIR\select-ddserver.ini" "Field 8" "State" '$R0'

  ; these field numbers will probably change to fix the tab order  
  ; /DDCONNECTION
  ${GetOptions} $cmdLineParams /DDCONNECTION= $R0
  IfErrors +2 0
  WriteINIStr "$PLUGINSDIR\select-ddserver.ini" "Field 10" "State" '$R0'
  
  ; /DDPROTOCOL
  ${GetOptions} $cmdLineParams /DDPROTOCOL= $R0
  IfErrors +2 0
  WriteINIStr "$PLUGINSDIR\select-ddserver.ini" "Field 12" "State" '$R0'
  
  
   ; radio buttons:
  ; 2 - network service
  ; 3 - local service
  ; 4 - custom user (7, 8 = username,password text fields)
  ; 9 - do not install as service
  
  ; /SERVICEASNETWORKSERVICEUSER (default)
  ${GetOptions} $cmdLineParams /SERVICEASNETWORKSERVICEUSER $R0
  IfErrors +3 0
  WriteINIStr "$PLUGINSDIR\select-serviceuser.ini" "Field 2" "State" ''
  WriteINIStr "$PLUGINSDIR\select-serviceuser.ini" "Field 2" "State" '1'

  ; /SERVICEASLOCALSYSTEMUSER
  ${GetOptions} $cmdLineParams /SERVICEASLOCALSYSTEMUSER $R0
  IfErrors +3 0
  WriteINIStr "$PLUGINSDIR\select-serviceuser.ini" "Field 2" "State" ''
  WriteINIStr "$PLUGINSDIR\select-serviceuser.ini" "Field 3" "State" '1'

  ; /SERVICEASCUSTOMUSER
  ${GetOptions} $cmdLineParams /SERVICEASCUSTOMUSER $R0
  IfErrors +3 0
  WriteINIStr "$PLUGINSDIR\select-serviceuser.ini" "Field 2" "State" ''
  WriteINIStr "$PLUGINSDIR\select-serviceuser.ini" "Field 4" "State" '1'
  
  ; /NOSERVICE
  ${GetOptions} $cmdLineParams /NOSERVICE $R0
  IfErrors +3 0
  WriteINIStr "$PLUGINSDIR\select-serviceuser.ini" "Field 2" "State" ''
  WriteINIStr "$PLUGINSDIR\select-serviceuser.ini" "Field 9" "State" '1'

  ; /SERVICEUSERNAME
  ${GetOptions} $cmdLineParams /SERVICEUSERNAME= $R0
  IfErrors +2 0
  WriteINIStr "$PLUGINSDIR\select-serviceuser.ini" "Field 7" "State" '$R0'

  ; /SERVICEPASSWORD
  ${GetOptions} $cmdLineParams /SERVICEPASSWORD= $R0
  IfErrors +2 0
  WriteINIStr "$PLUGINSDIR\select-serviceuser.ini" "Field 8" "State" '$R0'
  
     
FunctionEnd

Function DisplaySelectDdserverPage
  !insertmacro MUI_HEADER_TEXT "Select Dynamic DNS server" "An external server must be configured in order to provide Dynamic DNS services"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "select-ddserver.ini"
FunctionEnd

; leave function is also called during control NOTIFY events (set for Field 12 (Dynamic DNS Protocol))  
Function LeaveSelectDdserverPage
  ; find out which field event called us 0 = next button called us
  !insertmacro MUI_INSTALLOPTIONS_READ $R0 "select-ddserver.ini" "Settings" "State"
  ${If} $R0 == 12  ; field 12
    !insertmacro MUI_INSTALLOPTIONS_READ $R0 "select-ddserver.ini" "Field 12" "State"
    readinistr $1 "$PLUGINSDIR\select-ddserver.ini" "Field 13" "HWND"
    ; concont|dnspark|dslreports1|dtdns|dyndns1|dyndns2|easydns|freedns|hammernode1|namecheap|noip|sitelutions|zoneedit1
    ${If} $R0 == 'concont'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'concont' protocol is the protocol used by the content management system ConCont's dydns module. This is currently used by the free dynamic DNS service offered by Tyrmida at www.dydns.za.net"
    ${ElseIf} $R0 == 'dnspark'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'dnspark' protocol is used by DNS service offered by www.dnspark.com."
    ${ElseIf} $R0 == 'dslreports1'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'dslreports1' protocol is used by a free DSL monitoring service offered by www.dslreports.com."
    ${ElseIf} $R0 == 'dtdns'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'dtdns' protocol is the protocol used by the dynamic hostname services of the 'DtDNS' dns services. This is currently used by the free dynamic DNS service offered by www.dtdns.com."
    ${ElseIf} $R0 == 'dyndns1'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'dyndns1' protocol is a deprecated protocol used by the used-to-be-free dynamic DNS service offered by www.dyndns.org. The 'dyndns2' should be used to update the www.dyndns.org service.  However, other services are also using this protocol so support is still provided by ddclient."
    ${ElseIf} $R0 == 'dyndns2'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'dyndns2' protocol is a newer low-bandwidth protocol used by the used-to-be-free dynamic DNS service offered by www.dyndns.org. It supports features of the older 'dyndns1' in addition to others.$\r$\nThe namingwords.com Dynamic DNS server supports this protocol."
    ${ElseIf} $R0 == 'easydns'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'easydns' protocol is used by the for fee DNS service offered by www.easydns.com."
    ${ElseIf} $R0 == 'freedns'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'freedns' protocol is used by DNS services offered by freedns.afraid.org."
    ${ElseIf} $R0 == 'hammernode1'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'hammernode1' protocol is the protocol used by the free dynamic DNS service offered by Hammernode at www.hn.org"
    ${ElseIf} $R0 == 'namecheap'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'namecheap' protocol is used by DNS service offered by www.namecheap.com."
    ${ElseIf} $R0 == 'noip'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'No-IP Compatible' protocol is used to make dynamic dns updates over an http request.  Details of the protocol are outlined at: http://www.no-ip.com/integrate/"
    ${ElseIf} $R0 == 'sitelutions'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'sitelutions' protocol is used by DNS services offered by www.sitelutions.com."
    ${ElseIf} $R0 == 'zoneedit1'
      SendMessage $1 ${WM_SETTEXT} 1 "STR:The 'zoneedit1' protocol is used by a DNS service offered by www.zoneedit.com."
    ${Else}
      ; MessageBox MB_OK "Invalid protocol selected"
    ${EndIf}  
    Abort
  ${EndIf}
FunctionEnd

Function DisplaySelectServiceuserPage
  !insertmacro MUI_HEADER_TEXT "Select user account" "When installed as a service, ddclient needs to run with the privileges of a local user account."
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "select-serviceuser.ini"
FunctionEnd
 

;--------------------------------
;Installer Sections

; Var WINPCAP_UNINSTALL ;declare variable for holding the value of a registry key

Section "!ddclient" SecMain
  
  ; mandatory section
  SectionIn RO

  SetOutPath "$INSTDIR"
  File ..\..\..\target\ddclient.exe
  File ..\..\..\target\ddclient-noconsole.exe
  File ..\..\..\src\main\resources\srvany.exe
  File ..\..\..\src\main\resources\ddclient128.ico
  ; File ..\..\..\src\main\resources\start-console.bat

  ;Store installation folder
  WriteRegStr HKCU "Software\Randomnoun\ddclient" "InstallDir" $INSTDIR

  ;Create uninstaller
  ; Write the uninstall keys for Windows
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\ddclient" "DisplayVersion" "${VERSION}"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\ddclient" "DisplayName" "ddclient ${VERSION}"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\ddclient" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\ddclient" "Publisher" "Randomnoun, http://www.randomnoun.com"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\ddclient" "HelpLink" "mailto:knoxg@randomnoun.com"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\ddclient" "URLInfoAbout" "http://www.randomnoun.com"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\ddclient" "URLUpdateInfo" "http://www.randomnoun.com/updateInfo/"
  WriteRegDWORD HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\ddclient" "NoModify" 1
  WriteRegDWORD HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\ddclient" "NoRepair" 1
  WriteUninstaller "Uninstall.exe"

  ; WriteUninstaller "$INSTDIR\Uninstall.exe"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    
  ;Create shortcuts
  SetShellVarContext current
  ; XXX: this all appears to be in 'all users' anyway
  ; if I ever manage to fix this, then remove the two start menu delete sections in the in the uninstall section
  CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Start ddclient console.lnk" "$INSTDIR\ddclient.exe" "-foreground -file $\"$INSTDIR\ddclient.conf$\" -cache $\"$LOCALAPPDATA\ddclient.cache$\""
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Start ddclient service.lnk" "$SYSDIR\net.exe" "start ddclient"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Stop ddclient service.lnk" "$SYSDIR\net.exe" "stop ddclient"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Open ddclient.conf in notepad.lnk" "notepad.exe" "$INSTDIR\ddclient.conf"

  ; for some reason the following goes into the user's startmenu folder, the above go into the all users startmenu folder.
  ; on uninstall, none of these shortcuts get deleted properly
  !insertmacro CreateInternetShortcut \
    "$SMPROGRAMS\$STARTMENU_FOLDER\ddclient website" \
    "http://www.randomnoun.com/wp/2013/08/19/a-dynamic-dns-client-for-windows/" \
    "$INSTDIR\ddclient128.ico" "0"
  
  !insertmacro MUI_STARTMENU_WRITE_END

  ; get these details from the custom nsis pages 
  DetailPrint "Configuring ddclient"   
  FileOpen $1 "$INSTDIR\ddclient.conf" "w"
  FileWrite $1 "# ddclient.conf$\r$\n"
  FileWrite $1 "#$\r$\n"
  FileWrite $1 "daemon=5m$\r$\n"
  FileWrite $1 "use=web$\r$\n"

  ReadINIStr $0 "$PLUGINSDIR\select-ddserver.ini" "Field 4" "State"
  FileWrite $1 "web=$0/nic/checkip.html$\r$\n"
  FileWrite $1 "server=$0$\r$\n"
  ReadINIStr $0 "$PLUGINSDIR\select-ddserver.ini" "Field 12" "State"
  FileWrite $1 "protocol=$0 "
  ReadINIStr $0 "$PLUGINSDIR\select-ddserver.ini" "Field 7" "State"
  FileWrite $1 " login=$0, "
  ReadINIStr $0 "$PLUGINSDIR\select-ddserver.ini" "Field 8" "State"
  FileWrite $1 "password=$0 "
  ReadINIStr $0 "$PLUGINSDIR\select-ddserver.ini" "Field 2" "State"
  FileWrite $1 "$0$\r$\n"
  
  ; HTTP/HTTPS, convert to 'no'/'yes'
  ReadINIStr $0 "$PLUGINSDIR\select-ddserver.ini" "Field 10" "State"
  ${If} $0 == 'HTTP'
    FileWrite $1 "ssl=no$\r$\n"
  ${ElseIf} $0 == 'HTTPS'
    FileWrite $1 "ssl=yes$\r$\n"
  ${EndIf}  
  
  
  FileClose $1

  
  ; DetailPrint "Installing service"
  ; install service (depending on select-serviceuser.ini setting)
  ; radio buttons:
  ; 2 - network service
  ; 3 - local system
  ; 4 - custom user (7, 8 = username,password text fields)
  ; 9 - do not install as service
  ReadINIStr $0 "$PLUGINSDIR\select-serviceuser.ini" "Field 2" "State"
  StrCmp $0 "1" lblInstallNetworkService

  ReadINIStr $0 "$PLUGINSDIR\select-serviceuser.ini" "Field 3" "State"
  StrCmp $0 "1" lblInstallLocalSystemService

  ReadINIStr $0 "$PLUGINSDIR\select-serviceuser.ini" "Field 4" "State"
  StrCmp $0 "1" lblInstallCustomUserService

  ReadINIStr $0 "$PLUGINSDIR\select-serviceuser.ini" "Field 9" "State"
  StrCmp $0 "1" lblInstallServiceDone

  Goto lblInstallServiceDone

lblInstallNetworkService:
  DetailPrint "Installing service with Network Service account"
  SimpleSC::InstallService "ddclient" "ddclient Dynamic DNS Client" "16" "2" "$INSTDIR\srvany.exe" "" "NT AUTHORITY\NetworkService" ""
  Pop $0 ; returns an errorcode (<>0) otherwise success (0)
  IntCmp $0 0 +2
  MessageBox MB_OK|MB_ICONSTOP "Service installation failed: could not create service."
  WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "Application" "$INSTDIR\ddclient.exe"
  ; NB: cache should probably go into Local App folder.
  ; ddclient now stores it's cache by default in the Local AppData folder
  ; WriteRegStr HKEY_LOCAL_MACINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "AppParameters" "-foreground -file $\"$INSTDIR\ddclient.conf$\" -cache $\"$INSTDIR\ddclient.cache$\""
  ; WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "AppParameters" "-foreground -file $\"$INSTDIR\ddclient.conf$\""
  WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "AppParameters" "-foreground -appdatalog -file $\"$INSTDIR\ddclient.conf$\""
  DetailPrint "Starting service"
  SimpleSC::StartService "ddclient" "" 30
  Goto lblInstallServiceDone
  
lblInstallLocalSystemService:
  DetailPrint "Installing service with Local System account"
  ; 16 = SERVICE_WIN32_OWN_PROCESS 
  ; 2 = SERVICE_AUTO_START
  SimpleSC::InstallService "ddclient" "ddclient Dynamic DNS Client" "16" "2" "$INSTDIR\srvany.exe" "" "" ""
  Pop $0 ; returns an errorcode (<>0) otherwise success (0)
  IntCmp $0 0 +2
  MessageBox MB_OK|MB_ICONSTOP "Service installation failed: could not create service."
  WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "Application" "$INSTDIR\ddclient.exe"
  WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "AppParameters" "-foreground -appdatalog -file $\"$INSTDIR\ddclient.conf$\""
  DetailPrint "Starting service"
  SimpleSC::StartService "ddclient" "" 30
  Goto lblInstallServiceDone

lblInstallCustomUserService:
  ReadINIStr $0 "$PLUGINSDIR\select-serviceuser.ini" "Field 7" "State"
  ReadINIStr $1 "$PLUGINSDIR\select-serviceuser.ini" "Field 8" "State"
  DetailPrint "Installing service with custom user account"
  SimpleSC::InstallService "ddclient" "ddclient Dynamic DNS Client" "16" "2" "$INSTDIR\srvany.exe" "" "$0" "$1"
  IntCmp $0 0 +2
  MessageBox MB_OK|MB_ICONSTOP "Service installation failed: could not create service."
  WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "Application" "$INSTDIR\ddclient.exe"
  WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "AppParameters" "-foreground -appdatalog -file $\"$INSTDIR\ddclient.conf$\""
  DetailPrint "Starting service"
  SimpleSC::StartService "ddclient" "" 30
  Goto lblInstallServiceDone

lblInstallServiceDone:


SectionEnd


;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecMain ${LANG_ENGLISH} "The ddclient application"

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} $(DESC_SecMain)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ; stop and remove service
  SimpleSC::StopService "ddclient" "" 30
  Sleep 1000 
  SimpleSC::RemoveService "ddclient"
  Sleep 1000
  
  ; I added the sleeps above since this executable is (sometimes) still running at this stage
  ; this doesn't appear to fix it so trying this instaed
  
  ; R0 ?
  nsProcess::_CloseProcess "ddclient.exe" $R0
  ; MessageBox MB_OK "nsProcess::CloseProcess$\n$\nErrorlevel: [$R0]"
  nsProcess::_Unload
  
  Delete $INSTDIR\ddclient.exe  
  Delete $INSTDIR\ddclient-noconsole.exe
  Delete $INSTDIR\srvany.exe
  Delete $INSTDIR\ddclient128.ico
  Delete $INSTDIR\ddclient.conf        ; keep configuration around ?
  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP
  SetShellVarContext current
  Delete "$SMPROGRAMS\$MUI_TEMP\ddclient website.url"
  
  ; on W7, these files are in all, but in XP these files are in current
  Delete "$SMPROGRAMS\$MUI_TEMP\Uninstall.lnk"
  Delete "$SMPROGRAMS\$MUI_TEMP\Start ddclient console.lnk"
  Delete "$SMPROGRAMS\$MUI_TEMP\Start ddclient service.lnk"
  Delete "$SMPROGRAMS\$MUI_TEMP\Stop ddclient service.lnk"
  Delete "$SMPROGRAMS\$MUI_TEMP\Open ddclient.conf in notepad.lnk"
  
  ; so let's just delete them from both
  SetShellVarContext all
  ; for some reason this is c:\users\knoxg\appdata\roaming\microsoft\windows\start menu\programs\ddclient\Uninstall.lnk
  ; not                     C:\ProgramData\Microsoft\Windows\Start Menu\Programs\ddclient
  ; although some would argue that that's where it's supposed to be anyway.                      
  ; MessageBox MB_OK|MB_ICONSTOP "Attempting to delete $SMPROGRAMS\$MUI_TEMP\Uninstall.lnk"  
  Delete "$SMPROGRAMS\$MUI_TEMP\Uninstall.lnk"
  Delete "$SMPROGRAMS\$MUI_TEMP\Start ddclient console.lnk"
  Delete "$SMPROGRAMS\$MUI_TEMP\Start ddclient service.lnk"
  Delete "$SMPROGRAMS\$MUI_TEMP\Stop ddclient service.lnk"
  Delete "$SMPROGRAMS\$MUI_TEMP\Open ddclient.conf in notepad.lnk"

  ; remove uninstall registry entry and settings
  DeleteRegKey HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\ddclient"
  DeleteRegKey HKEY_LOCAL_MACHINE "Software\Randomnoun\ddclient"
  
  ;Delete empty start menu parent directories (current user)
  !insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP
  SetShellVarContext current
  StrCpy $MUI_TEMP "$SMPROGRAMS\$MUI_TEMP"
startMenuDeleteLoop1:
  ClearErrors
  RMDir $MUI_TEMP
  GetFullPathName $MUI_TEMP "$MUI_TEMP\.."
  IfErrors startMenuDeleteLoopDone1
  StrCmp $MUI_TEMP $SMPROGRAMS startMenuDeleteLoopDone1 startMenuDeleteLoop1
startMenuDeleteLoopDone1:
  
  ;Delete empty start menu parent directories (all users)
  !insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP
  SetShellVarContext all
  StrCpy $MUI_TEMP "$SMPROGRAMS\$MUI_TEMP"
startMenuDeleteLoop2:
  ClearErrors
  RMDir $MUI_TEMP
  GetFullPathName $MUI_TEMP "$MUI_TEMP\.."
  IfErrors startMenuDeleteLoopDone2
  StrCmp $MUI_TEMP $SMPROGRAMS startMenuDeleteLoopDone2 startMenuDeleteLoop2
startMenuDeleteLoopDone2:
  

  DeleteRegKey /ifempty HKCU "Software\Randomnoun\ddclient"

SectionEnd


!include WinMessages.nsh


