# Originally Written by Bram Cohen
# Parts Copyright (c) 2004 Eric Ries under the GNU GPL
# see LICENSE.txt for license information

import nsis
import sys

def msgbox(msg):
    if 0:
        nsis.messagebox(msg)
    
sys.path = []
sys.path.append(nsis.getvar("OUTDIR"))
sys.path.append(nsis.getvar("OUTDIR")+"/python23.zip")
import os
msgbox("%s" % sys.path)

import BitTorrent.download
from threading import Event
import os
import traceback

def dummychoose(default, size, saveas, dir):
    return saveas

lastProgress = 0
fractionDone = 0
downTotal = 0
torrentUrlToDisplay = ""


    
def download(torrentUrl, useHttp, file):
    ev = Event()
    def fin(ev = ev):
        ev.set()
    def dummyerror(message, ev=ev):
        nsis.log("error = %s" % message)
        nsis.messagebox("error = %s" % message)
        ev.set()
    if useHttp:
        BitTorrent.download.download(['--url', torrentUrl, '--saveas', file], 
                                     dummychoose, dummydisplay, fin, dummyerror, ev, 80)
    else:
        if not os.path.exists(torrentUrl):
            msgbox("file %s does not exist!" % torrentUrl)
            raise "file %s does not exist!" % torrentUrl
        BitTorrent.download.download(['--responsefile', torrentUrl, '--saveas', file], 
                                     dummychoose, dummydisplay, fin, dummyerror, ev, 80)
        
        
    while not ev.isSet:
        try:
            pass
        except:
            ev.set()
            return
        #win32gui.PumpWaitingMessages()

if __name__ == "__main__":
    #import win32gui
    nsis.setupprogress()
    cmdline = nsis.getvar("R0")
    arr = cmdline.split(" ")
    url = arr.pop()
    destDir = os.path.normpath(nsis.getvar("R1"))
    if not os.path.exists(destDir):
        msgbox("Cannot access dir: %s" % destDir)
    
    if url.startswith("http"):
        torrentUrl = url
        useHttp = 1
    else:
        useHttp = 0
        torrentUrl = os.path.normpath(url)
        torrentUrl = torrentUrl.replace('"', '')

    def dummydisplay(dict, torrentUrlToDisplay=torrentUrl, useHttp=useHttp):
        #msgbox("torrentUrlToDisplay = %s" % torrentUrlToDisplay)
        for key, val in dict.items():
            if key == "fractionDone":
                lastProgress = int(float(val) * 30000)
                lastProgressTuple = ("%0.3f%% complete" % ((float(val)*100)),
                                     "downloading %s" % os.path.basename(torrentUrlToDisplay),
                                     lastProgress)
                nsis.setprogress(*lastProgressTuple)
            if key == "downTotal":
                downTotal = val

            if key in ("upTotal", "fractionDone", "upRate", "downTotal", "downRate"):
                continue
            nsis.log("key %s = %s" % (key,val))

    msgbox("going to download %s to %s" % (torrentUrl, destDir))
    try:
        download(torrentUrl=torrentUrl,
                 useHttp=useHttp,
                 file=destDir)
    except:
        tb = traceback.format_exception(*(sys.exc_info()))
        nsis.messagebox("Error downloading %s to %s: %s" % (torrentUrl,destDir,tb))
    else:
        msgbox("Survived BitTorrent.download")
