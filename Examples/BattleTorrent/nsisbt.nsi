;--------------------------------
;NSISbt.nsi -- part of Battle Torrent
; This file Copyright (c) 2004 Eric Reis licensed under the GNU GPL
; See LICENCE.txt for details
;Include Modern UI

  !include "MUI.nsh"

;--------------------------------
;Configuration

  ;General
  Name "BitTorrentDownloader"
  OutFile "nsisbt.exe"

  SetCompress off 
  SetCompressorDictSize 128
  SetPluginUnload alwaysoff
  XPStyle on
  ;Folder selection page
  InstallDir "$DESKTOP"

;--------------------------------
;Variables


;--------------------------------
;Modern UI Configuration

  !define MUI_HEADERIMAGE
  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME

  !insertmacro MUI_PAGE_DIRECTORY
;  Page custom CustomPageA_Pre CustomPageA_Post
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_PAGE_FINISH
  
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Reserve Files
  

;--------------------------------
;Installer Sections


Section "BitTorrentDownloader" SecDummy
  SetOutPath "$INSTDIR"

  Push "asdef"
  call GetParameters  
  Pop $R0

  StrCmp $R0 "" noparams gotparams
  noparams:
      MessageBox MB_OK|MB_ICONSTOP "usage: BitTorrentDownloader torrentUrl"
  Quit
  gotparams:
  
 ;      MessageBox MB_OK|MB_ICONSTOP "$R1"


  !insertmacro MUI_HEADER_TEXT "Downloading" "Downloading the torrent file"
  call ConnectInternet

  ReadRegStr $R2 HKCU "Software\NSISbt" "" 
  IfFileExists "$R2\bt\btdownloadnsis.py" good bad
  bad:
      MessageBox MB_OK|MB_ICONSTOP "$R2\bt\btdownloadnsis.py doesn't exist"
      Abort
  good:
  SetOutPath "$R2\bt\"
  StrCpy $R0 $CMDLINE
  StrCpy $R1 $INSTDIR
  BattleTorrent::execFile "$R2\bt\btdownloadnsis.py"
  Pop $R1
  IfErrors msgerror msgresult
  msgresult:
  StrCmp $R1 "error" msgerror msgdone
  msgerror:
      StrCpy $R3 "c:\\temp\\install.log"
      MessageBox MB_OK "error running $R2\bt\btdownloadnsis.py, log written to $R3"
      Push $R3
      call DumpLog
  msgdone:
SectionEnd

Function CustomPageA_Pre
FunctionEnd

Function CustomPageA_Post
FunctionEnd 

Function .onInit
    ;Extract Install Options files
    ;$PLUGINSDIR will automatically be removed when the installer closes
    InitPluginsDir
    
FunctionEnd


;--------------------------------
;Descriptions

  LangString DESC_SecDummy ${LANG_ENGLISH} "BitTorrentDownloader"

  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDummy} $(DESC_SecDummy)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;--------------------------------
;Uninstaller Section

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
