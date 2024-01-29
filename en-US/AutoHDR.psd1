#culture="en-US"
ConvertFrom-StringData @'
 #BUTTON
 main00 = Select the action
 mainR1 = Install Game
 mainR2 = Remove Game
 mainR3 = Uninstall All
 txt1 = Enter the name of the game
 txtr = Choose game to remove
 txtexe = Enter the game's exe name (ex: game.exe or c:\\mygame\game.exe)
 txtexetooltip =  If only the exe name is written, AutoHdr will be trigger for all game that have the same exe name.\nIf the game exe with its full path is written, Only this game and exe location will trigger AutoHDR.
 txt2 = Optional setting for D3D Behaviors:
 txtBuff = BufferUpgradeEnable10Bit
 txtBuffTooltip = To enable only if you use a real 10bits colors monitor/TV.
 ButtonI = Install or update
 ButtonR = Remove Game
 ButtonU = Uninstall all
 exeend = The game exe name must end with '.exe'
 validexe = Enter a valid exe name
 ok1 = AutoHDR registry values
 oku = All AutoHDR registry entries has been removed.
 st1 = created.
 st2 = updated.
 st3= Deleted.
 ko1 = Error installing AutoHDR registry values.
 Kofound = No game found
 koreg = not found in registry
 kou = No game found in registry.
 kodel1 = Error trying to remove AutoHDR registry string value D3DBehaviors.
 kodel2 = Error trying to remove AutoHDR registry string value Name.
 kodel3 = Error trying to remove AutoHDR registry key.
 kodel4 = Error trying to remove registry key Direct3D.
'@
