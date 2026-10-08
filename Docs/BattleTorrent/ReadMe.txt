BattleTorrent is an altered version of NSISdl, not the original plugin.
It adds a third status line to the download dialog and an embedded
Python 2.3 interpreter. Below is the original NSISdl documentation, with
NSISdl:: replaced by BattleTorrent::. Additional commands:

  BattleTorrent::eval "expression"     evaluates a Python expression
  BattleTorrent::exec "statements"     runs Python statements
  BattleTorrent::execFile "script.py"  runs a Python script (up to 30000 bytes)

Each pushes the result as a string, or "error". Scripts can import the
"nsis" module: log, messagebox, setprogress, setupprogress, getvar, setvar,
getParent. Python 2.3 (python23.dll) must be available at run time.

NSISdl 1.1 - HTTP downloading plugin for NSIS
---------------------------------------------

Copyright (C) 2001-2002 Yaroslav Faybishenko & Justin Frankel

This plugin can be used from NSIS to download files via http.

To connect to the internet, use the Dialer pluin.

USAGE
-----

BattleTorrent::download http://www.domain.com/file localfile.exe

You can also pass /TIMEOUT to set the timeout in milliseconds:

BattleTorrent::download /TIMEOUT=30000 http://www.domain.com/file localfile.exe

The return value is pushed to the stack:

  "cancel" if cancelled
  "success" if success
  otherwise, an error string describing the error

If you don't want the progess window to appear use BattleTorrent::download_quiet.

Example of usage:

BattleTorrent::download http://www.domain.com/file localfile.exe
Pop $R0 ;Get the return value
  StrCmp $R0 "success" +3
    MessageBox MB_OK "Download failed: $R0"
    Quit

For another example, see waplugin.nsi in the examples directory.

TRANSLATE
---------

To translate NSISdl add the following values to the call line:

/TRANSLATE downloading connecting second minute hour plural progress remianing

Default values are:

  downloading - "Downloading %s"
  connecting - "Connecting ..."
  second - "second"
  minute - "minute"
  hour - "hour"
  plural - "s"
  progress - "%dkB (%d%%) of %dkB @ %d.%01dkB/s"
  remaining -  "(%d %s%s remaining)"

/TRANSLATE must come before /TIMEOUT.