# AutoHDR
A powershell script with WPF Gui to enable autoHDR on game that do not trigger it automaticaly on windows 11.

This script will created specific registry key that will trigger autoHdr in unsupported Game.  
Game should be a DX11/DX12 game, it will not bypass this limiration.  
You can use a graphics wrapper like Dgvoodoo 2 to bypass that limitation for old game.  
 
Registry key and value created will be created under the HKEY_CURRENT_USER\Software\Microsoft\Direct3D  
&nbsp;&nbsp;&nbsp;&nbsp;  a registy key with the name of the game.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A registry string value : BufferUpgradeOverride (mandatory to enable AutoHDR)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A registry string value : BufferUpgradeEnable10Bit (optional, use it if you have a true 10bits colors monitor/TV)

<img src="https://i.imgur.com/yh5HzER.png">
<img src="https://i.imgur.com/V2B4HQf.png">


The Gui support :   
&nbsp;&nbsp;&nbsp;&nbsp; removal of games autohdr settings.  
&nbsp;&nbsp;&nbsp;&nbsp; update of already existing game.  
&nbsp;&nbsp;&nbsp;&nbsp; provide a uninstall function to remove all registry key created.  

Exe version has been compiled with PS2EXE.
