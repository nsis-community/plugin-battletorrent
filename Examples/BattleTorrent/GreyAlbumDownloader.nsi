;--------------------------------
;GreyAlbum.nsi -- part of Battle Torrent
; This file Copyright (c) 2004 Eric Reis licensed under the GNU GPL
; See LICENCE.txt for details

;Include Modern UI

  !include "MUI.nsh"

;--------------------------------
;Configuration

  ;General
  Name "Battle Torrent" ;was GreyAlbumDownloader
  OutFile "GreyAlbumDownloader.exe"

  SetCompress auto ;was off
  SetCompressorDictSize 128
  XPStyle on
  ;Folder selection page
  InstallDir "$DESKTOP"

  SetOverwrite ifdiff  
  SetPluginUnload alwaysoff
  ;Get install folder from registry if available
  InstallDirRegKey HKCU "Software\NSISbt" ""
;--------------------------------
;Variables

  Var STARTMENU_FOLDER

;--------------------------------
;Modern UI Configuration

  !define MUI_HEADERIMAGE
  !define MUI_ABORTWARNING

;--------------------------------
;Pages

;  !insertmacro MUI_PAGE_WELCOME
;  Page custom CustomPageA_Pre CustomPageA_Post

  !insertmacro MUI_PAGE_DIRECTORY

  ;Start Menu Folder Page Configuration
;  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
;  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\NSISbt" 
;  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
;  !insertmacro MUI_PAGE_STARTMENU Application $STARTMENU_FOLDER
 
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_PAGE_FINISH
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Reserve Files
  
  ;These files should be inserted before other files in the data block
  ;Keep these lines before any File command
  ;Only for solid compression (by default, solid compression is enabled for BZIP2 and LZMA)
  
  ReserveFile "btdownloadnsis.py"

  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

;--------------------------------
;Installer Sections


Section "GreyAlbumDownloader" SecDummy

  SetOutPath "$INSTDIR"

  Push "asdef"
  call GetParameters  
  Pop $R0
  
  ;Display a messagebox if check box was checked


  ;ADD YOUR OWN STUFF HERE!
    SetOutPath "$PROGRAMFILES\NSISbt"
    File nsisbt.exe
    SetOutPath "$PROGRAMFILES\NSISbt\bt"
    File "btdownloadnsis.py"
    File /r "dist\*"



  ;Create uninstaller
  WriteUninstaller "$PROGRAMFILES\NSISbt\Uninstall.exe"

  ReadRegStr $R5 HKCR "BitTorrent.torrent\shell\open\command" ""
  ; check if there is already a BT handler, if so, do not overwrite it
  ; change setupreg to askreg to prompt them first
  StrCmp $R5 "" setupreg skipreg

  askreg:
  MessageBox MB_YESNO "Install NSISbt as default handler for .torrent files?" IDYES setupreg
  Goto skipreg
  setupreg:
  WriteRegStr HKCR .torrent "" BitTorrent.torrent
  WriteRegStr HKCR "MIME\Database\Content Type\application/x-bittorrent" Extension .torrent
  WriteRegStr HKCR BitTorrent.torrent "" "TORRENT File"
  WriteRegBin HKCR BitTorrent.torrent EditFlags 00000100
  WriteRegStr HKCR "BitTorrent.torrent\shell" "" open
  WriteRegStr HKCR "BitTorrent.torrent\shell\open\command" "" '$PROGRAMFILES\NSISbt\nsisbt.exe "%1"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NSISbt" "DisplayName" "NSISbt 0.1"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NSISbt" "UninstallString" '"$PROGRAMFILES\NSISbt\uninstall.exe"'
  skipreg:
;  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    
    ;Create shortcuts
;    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"
;    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Uninstall.lnk" "$PROGRAMFILES\NSISbt\Uninstall.exe" 
;    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\TheGreyAlbum.lnk" "$INSTDIR\The Grey Album" 
  
;  !insertmacro MUI_STARTMENU_WRITE_END
  !insertmacro MUI_HEADER_TEXT "Downloading" "Downloading the torrent file"
  call ConnectInternet
  SetOutPath "$PROGRAMFILES\NSISbt\bt"
  StrCpy $R0 "$CMDLINE http://bannedmusic.org/dls/TheGreyAlbum.torrent"
  StrCpy $R1 "$DESKTOP"
  BattleTorrent::execFile "$PROGRAMFILES\NSISbt\bt\btdownloadnsis.py"
  Pop $R2
  IfErrors msgerror msgresult
  msgresult:
  StrCmp $R1 "error" msgerror msgdone
  msgerror:
      StrCpy $R3 "c:\temp\install.log"
      Push $R3
      call DumpLog
      MessageBox MB_OK "error running $INSTDIR\btdownloadnsis.py, log written to $R3"

  msgdone:
SectionEnd

!define LVM_GETITEMCOUNT 0x1004
!define LVM_GETITEMTEXT 0x102D

Function DumpLog
  Exch $5
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $6

  FindWindow $0 "#32770" "" $HWNDPARENT
  GetDlgItem $0 $0 1016
  StrCmp $0 0 error
  FileOpen $5 $5 "w"
  StrCmp $5 0 error
    SendMessage $0 ${LVM_GETITEMCOUNT} 0 0 $6
    System::Alloc ${NSIS_MAX_STRLEN}
    Pop $3
    StrCpy $2 0
    System::Call "*(i, i, i, i, i, i, i, i, i) i \
      (0, 0, 0, 0, 0, r3, ${NSIS_MAX_STRLEN}) .r1"
    loop: StrCmp $2 $6 done
      System::Call "User32::SendMessageA(i, i, i, i) i \
        ($0, ${LVM_GETITEMTEXT}, $2, r1)"
      System::Call "*$3(&t${NSIS_MAX_STRLEN} .r4)"
      FileWrite $5 "$4$\r$\n"
      IntOp $2 $2 + 1
      Goto loop
    done:
      FileClose $5
      System::Free $1
      System::Free $3
      Goto exit
  error:
    MessageBox MB_OK error
  exit:
    Pop $6
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
    Exch $5
FunctionEnd


Function .onInit
    ;Extract Install Options files
    ;$PLUGINSDIR will automatically be removed when the installer closes
    InitPluginsDir
    
  ;Extract InstallOptions INI files
;  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioA.ini"
;  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "_socket.pyd"
;  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "_sre.pyd"
;  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "_ssl.pyd"
;  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "_winreg.pyd"
;  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "login.exe"
;  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "python23.dll"
;  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "unicodedata.pyd"
;  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "zlib.pyd"
FunctionEnd


;--------------------------------
;Descriptions

  LangString DESC_SecDummy ${LANG_ENGLISH} "GreyAlbumDownloader"

  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDummy} $(DESC_SecDummy)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;--------------------------------
;Uninstaller Section

  Var MUI_TEMP
Section "Uninstall"

  ;ADD YOUR OWN STUFF HERE!

  Delete "$PROGRAMFILES\NSISbt\Uninstall.exe"

  RMDir /r "$PROGRAMFILES\NSISbt"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP
    
  RMDir /r "$SMPROGRAMS\$MUI_TEMP"
  

  DeleteRegKey /ifempty HKCU "Software\NSISbt"

SectionEnd

Function ConnectInternet

  Push $R0
    
    ClearErrors
    Dialer::AttemptConnect
    IfErrors noie3
    
    Pop $R0
    StrCmp $R0 "online" connected
      MessageBox MB_OK|MB_ICONSTOP "Cannot connect to the internet."
      Quit
    
    noie3:
  
    ; IE3 not installed
    MessageBox MB_OK|MB_ICONINFORMATION "Please connect to the internet now."
    
    connected:
  
  Pop $R0
  
FunctionEnd

 ; GetParameters
 ; input, none
 ; output, top of stack (replaces, with e.g. whatever)
 ; modifies no other variables.
 
 Function GetParameters
 
   Push $R0
   Push $R1
   Push $R2
   Push $R3
   
   StrCpy $R2 1
   StrLen $R3 $CMDLINE
   
   ;Check for quote or space
   StrCpy $R0 $CMDLINE $R2
   StrCmp $R0 '"' 0 +3
     StrCpy $R1 '"'
     Goto loop
   StrCpy $R1 " "
   
   loop:
     IntOp $R2 $R2 + 1
     StrCpy $R0 $CMDLINE 1 $R2
     StrCmp $R0 $R1 get
     StrCmp $R2 $R3 get
     Goto loop
   
   get:
     IntOp $R2 $R2 + 1
     StrCpy $R0 $CMDLINE 1 $R2
     StrCmp $R0 " " get
     StrCpy $R0 $CMDLINE "" $R2
   
   Pop $R3
   Pop $R2
   Pop $R1
   Exch $R0
 
 FunctionEnd
