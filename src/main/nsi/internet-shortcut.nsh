; downloaded by knoxg on 2010-12-13
; from http://nsis.sourceforge.net/CreateInternetShortcut_macro_%26_function

!macro CreateInternetShortcut FILENAME URL ICONFILE ICONINDEX
WriteINIStr "${FILENAME}.url" "InternetShortcut" "URL" "${URL}"
WriteINIStr "${FILENAME}.url" "InternetShortcut" "IconFile" "${ICONFILE}"
WriteINIStr "${FILENAME}.url" "InternetShortcut" "IconIndex" "${ICONINDEX}"
!macroend