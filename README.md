# AutoHDR
A powershell script with WPF Gui to enable autoHDR on game that do not trigger it automaticaly on windows 11.

This script will created specific registry key that will trigger autoHdr in unsupported Game.
	Game should be a DX11/DX12 game, it will not bypass this limiration.
 
Registry created will be created under the HKEY_CURRENT_USER\Software\Microsoft\Direct3D
	registy key that could be created
		BufferUpgradeOverride (mandatory to enable AutoHDR)
		BufferUpgradeEnable10Bit (optional, use it if you have a true 10bits colors monitor/TV)

<img src="https://i.imgur.com/08FS16Y.png">

The Gui support removel of game autohdr setting, update of already existing game, or provide a unisntall function to remove all registry key created.

Exe version has been compiled with PS2EXE.
