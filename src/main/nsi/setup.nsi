; ddclient desktop installer
; based on NSIS Modern User Interface example script written by Joost Verburg

;--------------------------------
;Include Modern UI

  !AddIncludeDir "..\..\..\target"

  !include "MUI.nsh"
  !include "internet-shortcut.nsh"
  !include LogicLib.nsh
  !include "project.nsh"

  !addplugindir "..\..\..\target"
  !addplugindir "." ; for SimpleSC.dll

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
  !define VERSION "1.0.0"


;!define MUI_PAGE_CUSTOMFUNCTION_SHOW myShowCallback

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  ; !insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
  !insertmacro MUI_PAGE_LICENSE "License.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
Page custom DisplaySelectDdserverPage
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
FunctionEnd

Function DisplaySelectDdserverPage
  !insertmacro MUI_HEADER_TEXT "Select Dynamic DNS server" "An external server must be configured in order to provide Dynamic DNS services"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "select-ddserver.ini"
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
  File ..\..\..\src\main\resources\ddclient.exe
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

  ; for some reason the following goes into the user's startmenu folder, the above go into the all users startmenu folder
  ; on uninstall, none of these shortcuts get deleted properly
  !insertmacro CreateInternetShortcut \
    "$SMPROGRAMS\$STARTMENU_FOLDER\ddclient website" \
    "http://www.randomnoun.com/wp/something" \
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
  ReadINIStr $0 "$PLUGINSDIR\select-ddserver.ini" "Field 7" "State"
  FileWrite $1 "protocol=dyndns2 login=$0, "
  ReadINIStr $0 "$PLUGINSDIR\select-ddserver.ini" "Field 8" "State"
  FileWrite $1 "password=$0 "
  ReadINIStr $0 "$PLUGINSDIR\select-ddserver.ini" "Field 2" "State"
  FileWrite $1 "$0$\r$\n"
  FileClose $1

  
  ; DetailPrint "Installing service"
  ; install service (depending on select-serviceuser.ini setting)
  ; radio buttons:
  ; 2 - network service
  ; 3 - local service
  ; 4 - custom user (7, 8 = username,password text fields)
  ; 9 - do not install as service
  ReadINIStr $0 "$PLUGINSDIR\select-serviceuser.ini" "Field 2" "State"
  StrCmp $0 "1" lblInstallNetworkService

  ReadINIStr $0 "$PLUGINSDIR\select-serviceuser.ini" "Field 3" "State"
  StrCmp $0 "1" lblInstallLocalService

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
  WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "AppParameters" "-foreground -file $\"$INSTDIR\ddclient.conf$\""
  DetailPrint "Starting service"
  SimpleSC::StartService "ddclient" "" 30
  Goto lblInstallServiceDone
  
lblInstallLocalService:
  DetailPrint "Installing service with Local Service account"
  ; 16 = SERVICE_WIN32_OWN_PROCESS 
  ; 2 = SERVICE_AUTO_START
  SimpleSC::InstallService "ddclient" "ddclient Dynamic DNS Client" "16" "2" "$INSTDIR\srvany.exe" "" "" ""
  Pop $0 ; returns an errorcode (<>0) otherwise success (0)
  IntCmp $0 0 +2
  MessageBox MB_OK|MB_ICONSTOP "Service installation failed: could not create service."
  WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "Application" "$INSTDIR\ddclient.exe"
  WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "AppParameters" "-foreground -file $\"$INSTDIR\ddclient.conf$\""
  DetailPrint "Starting service"
  SimpleSC::StartService "ddclient" "" 30
  Goto lblInstallServiceDone

lblInstallCustomUserService:
  ReadINIStr $0 "$PLUGINSDIR\select-serviceuser.ini" "Field 7" "State"
  ReadINIStr $1 "$PLUGINSDIR\select-serviceuser.ini" "Field 8" "State"
  DetailPrint "Installing service with custom user account"
  SimpleSC::InstallService "ddclient" "ddclient Dynamic DNS Client" "16" "2" "$INSTDIR\srvany.exe" "" $0 $1
  IntCmp $0 0 +2
  MessageBox MB_OK|MB_ICONSTOP "Service installation failed: could not create service."
  WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "Application" "$INSTDIR\ddclient.exe"
  WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\ddclient\Parameters" "AppParameters" "-foreground -file $\"$INSTDIR\ddclient.conf$\""
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
  SimpleSC::RemoveService "ddclient"
  Sleep 2000 ; this is here to hopefully allow us to remove the .exe's below  

  ;ADD YOUR OWN FILES HERE...
  Delete $INSTDIR\ddclient.exe  ; these aren't deleted properly
  Delete $INSTDIR\srvany.exe
  Delete $INSTDIR\ddclient128.ico
  Delete $INSTDIR\ddclient.conf        ; keep configuration around ?
  ;Delete $INSTDIR\start-console.bat
  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP
  SetShellVarContext current
  Delete "$SMPROGRAMS\$MUI_TEMP\ddclient website.url"
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


;!include "GetWindowsVersion.nsh"
!include WinMessages.nsh


