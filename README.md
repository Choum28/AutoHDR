# AutoHDR
A powershell script with WPF Gui to enable autoHDR on game that do not trigger it automaticaly on windows 11.

This script will created specific registry key that will trigger autoHdr in unsupported Game.  
Game should be a DX11/DX12 game, it will not bypass this limitation.  
You can use a graphics wrapper like Dgvoodoo 2 to bypass this limitation on old games.  
 
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

## launch the script  
Create a shortcut with following command:

.\powershell.exe -WindowStyle Hidden -ep bypass -file "x:\xxx\Autohdr\AutoHDR.ps1"

To remove the minimized windows behind the Gui, set in the properties of the shortcut Run=minimized

## Note

If you enter an exe name (like capture "outlaws.exe" in the gui, autohdr will trigger for all game/apps that have the same exe name.
If you set a full path in the exe part of the gui, autohdr will only be triggered for this specific exe/path  (ex : c:\mygames\outlaws\outlaws.exe)
