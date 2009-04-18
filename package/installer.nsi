!addincludedir $SMPROGRAMS\NSIS\Include

; Use the Modern UI
!include "MUI.nsh"

; The name of the installer
Name "${APP_NAME}"

; The file to write
OutFile "${APP_NAME_DOWNCASE}-install-${VERSION}.exe"

; The default installation directory
InstallDir $PROGRAMFILES\${APP_NAME}

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\NSIS_${APP_NAME}" "Install_Dir"
SetCompressor zlib

VIProductVersion ${VERSIONEXTRA}

VIAddVersionKey FileVersion ${VERSION}
VIAddVersionKey FileDescription "${APP_NAME} installer"
VIAddVersionKey LegalCopyright "Private - No Copying"
VIAddVersionKey ProductName ${APP_NAME}

BrandingText "${APP_NAME} ${VERSION} Installer"

;Interface Settings

!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall.ico"
!define MUI_HEADERIMAGE 1
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\orange.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "${NSISDIR}\Contrib\Graphics\Header\orange-uninstall.bmp"
; Pages

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
  
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
;--------------------------------

; The stuff to install
Section "${APP_NAME}" SecCore
  SectionIn RO

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put all the build files there
;  File /r build\*.*
  File /r ${BUILD_DIR}\*.*
  ; And the standard ruby script
  ;File /r mswin-init.rb

  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\NSIS_${APP_NAME} "Install_Dir" "$INSTDIR"

  ; back up old value of ${APP_DOC_EXTENSION}
  !define Index "Line${__LINE__}"
  ReadRegStr $1 HKCR "${APP_DOC_EXTENSION}" ""
  StrCmp $1 "" "${Index}-NoBackup"
  StrCmp $1 "${APP_NAME}" "${Index}-NoBackup"
  WriteRegStr HKCR "${APP_DOC_EXTENSION}" "backup_val" $1 
"${Index}-NoBackup:"

  WriteRegStr HKCR "${APP_DOC_EXTENSION}" "" "${APP_NAME}"
  ReadRegStr $0 HKCR "${APP_NAME}" ""
  StrCmp $0 "" 0 "${Index}-Skip"

  WriteRegStr HKCR "${APP_NAME}" "" "${APP_NAME}"
"${Index}-Skip:"
  WriteRegStr HKCR "${APP_NAME}\shell" "" "open"
  WriteRegStr HKCR "${APP_NAME}\DefaultIcon" "" "$INSTDIR\share\icons\project.ico"
  WriteRegStr HKCR "${APP_NAME}\shell\open\command" "" '$INSTDIR\${APP_NAME_DOWNCASE}.exe "%1"'
!undef Index
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "NSIS ${APP_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  
SectionEnd

LangString DESC_SecCore ${LANG_ENGLISH} "${APP_NAME} software (required)"

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts" SecShortcuts

	SetOutPath "$INSTDIR\bin"
  CreateDirectory "$SMPROGRAMS\${APP_NAME}"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\bin\${APP_NAME_DOWNCASE}.exe" "pinit.rb" "$INSTDIR\image\${APP_NAME_DOWNCASE}.ico" 0
  CreateShortCut "$INSTDIR\${APP_NAME}.lnk" "$SYSDIR\wscript.exe" "run.vbs" "$INSTDIR\image\${APP_NAME_DOWNCASE}.ico" 0
	SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME} Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\image\${APP_NAME_DOWNCASE}.ico" 0
  
SectionEnd

LangString DESC_SecShortcuts ${LANG_ENGLISH} "Add shortcuts to ${APP_NAME} to the Windows start menu (recommended)"

; Optional section (can be disabled by the user)
Section "Quicklaunch Shortcut" SecQShortcut

	SetOutPath "$INSTDIR\bin"
 ; CreateDirectory "$SMPROGRAMS\${APP_NAME}"
  CreateShortCut "$QUICKLAUNCH\${APP_NAME}.lnk" "$INSTDIR\bin\${APP_NAME_DOWNCASE}.exe" "pinit.rb" "$INSTDIR\image\${APP_NAME_DOWNCASE}.ico" 0
  
SectionEnd

LangString DESC_SecQShortcut ${LANG_ENGLISH} "Add Quicklaunch shortcut to ${APP_NAME} (recommended)"

;Section "Help and Documentation" SecHelpfiles

  ; Set output path to the installation directory.
 ; SetOutPath $INSTDIR
  ;File "doc\wefthelp.chm"
  ;File "doc\wefthelp.pdf"	
;SectionEnd
; LangString DESC_SecHelpfiles ${LANG_ENGLISH} "Install the ${APP_NAME} help file and documentation (recommended)"

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecCore} $(DESC_SecCore)
!insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} $(DESC_SecShortcuts)
!insertmacro MUI_DESCRIPTION_TEXT ${SecQShortcut} $(DESC_SecQShortcut)
;!insertmacro MUI_DESCRIPTION_TEXT ${SecHelpfiles} $(DESC_SecHelpfiles)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
  DeleteRegKey HKLM SOFTWARE\NSIS_${APP_NAME}

  ; Delete the installed files
  ; RMDir /r "$INSTDIR\share"
  RMDir /r "$INSTDIR\lib"
  RMDir /r "$INSTDIR\bin"
  RMDir /r "$INSTDIR\config"
  RMDir /r "$INSTDIR\image"
  RMDir /r "$INSTDIR\migrate"
  ; RMDir /r "$INSTDIR\doc"
  ; Delete "$INSTDIR\*.dll"
  Delete "$INSTDIR\*.lnk"
  ; Delete "$INSTDIR\${APP_NAME_DOWNCASE}*"
  Delete "$INSTDIR\uninstall.exe"
  RMDir $INSTDIR

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\${APP_NAME}\*.*"
  Delete "$SMPROGRAMS\${APP_NAME}\*.*"
	Delete "$QUICKLAUNCH\${APP_NAME}.lnk"
	
  ; Remove directories used
  RMDir "$SMPROGRAMS\${APP_NAME}"
  RMDir "$SMPROGRAMS\${APP_NAME}"


 ;start of restore script
!define Index "Line${__LINE__}"
  ReadRegStr $1 HKCR "${APP_DOC_EXTENSION}" ""
  StrCmp $1 "${APP_NAME}" 0 "${Index}-NoOwn" ; only do this if we own it
    ReadRegStr $1 HKCR "${APP_DOC_EXTENSION}" "backup_val"
    StrCmp $1 "" 0 "${Index}-Restore" ; if backup="" then delete the whole key
      DeleteRegKey HKCR "${APP_DOC_EXTENSION}"
    Goto "${Index}-NoOwn"
"${Index}-Restore:"
      WriteRegStr HKCR "${APP_DOC_EXTENSION}" "" $1
      DeleteRegValue HKCR "${APP_DOC_EXTENSION}" "backup_val"
   
    DeleteRegKey HKCR "${APP_NAME}" ;Delete key with association settings

"${Index}-NoOwn:"
!undef Index

SectionEnd
