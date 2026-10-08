# BattleTorrent plug-in for NSIS

![License](https://img.shields.io/github/license/nsis-community/plugin-battletorrent?color=blue&style=for-the-badge)
![Release](https://img.shields.io/github/v/release/nsis-community/plugin-battletorrent?style=for-the-badge)
![CI](https://img.shields.io/github/actions/workflow/status/nsis-community/plugin-battletorrent/ci.yml?style=for-the-badge)

> [!WARNING]
> **Altered NSISdl.** BattleTorrent is a 2004 fork of the stock NSISdl plug-in that embeds a Python 2.3 interpreter. It was originally shipped as `nsisdl.dll` and replaced NSISdl; here it's renamed to `BattleTorrent.dll`, so call it as `BattleTorrent::download`, `BattleTorrent::execFile` etc. It needs the Python 2.3 headers and `python23.lib` to build, which CI doesn't provide yet.

> [!NOTE]
> **Looking for the usage guide?** See [Docs/BattleTorrent/ReadMe.txt](Docs/BattleTorrent/ReadMe.txt).

This repository mirrors the BattleTorrent plug-in, which was previously hosted on the [NSIS wiki](https://nsis.sourceforge.io/). Its source has been rearranged so that it builds automatically; code changes are limited to build fixes and the rename.

The examples in [Examples/BattleTorrent/](Examples/BattleTorrent/) download a torrent through a bundled BitTorrent client. That client, and the Python runtime it needs, aren't part of this repository; [btdownloadnsis.py](Examples/BattleTorrent/btdownloadnsis.py) is licensed under the GPL, see [Examples/BattleTorrent/LICENSE.txt](Examples/BattleTorrent/LICENSE.txt).

**Are you the author?** You're welcome to take it over: [open an issue](https://github.com/nsis-community/plugin-battletorrent/issues/new) and we'll transfer the repository to you.

## Installation

Download the installer or archive from the [Releases page](https://github.com/nsis-community/plugin-battletorrent/releases).

If you downloaded the zip archive, extract it into your NSIS folder: it adds `BattleTorrent.dll` to `Plugins/<variant>/`.

## License

See [License.txt](License.txt).
