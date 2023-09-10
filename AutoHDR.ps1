<# 
.SYNOPSIS
    This script is a powxwershell script created to activate auto HDR on game that do not automatically trigger it.

.DESCRIPTION
    This script will created specific registry key that will trigger autoHdr in unsupported Game.
	Game should be a DX11/DX12 game.
	Registry created will be store under the HKEY_CURRENT_USER\Software\Microsoft\Direct3D
	registy key could be created
		BufferUpgradeOverride (mandatory)
		BufferUpgradeEnable10Bit (optional, use it if you have a true 10bits colors monitor/TV)
	

.EXAMPLE
	.\AutoHdr.ps1
	
		Launch the script
	1.3		10.09.2023	Add Icons in message, bug fix.
	1.2		09.09.2023	Add Combobox for removal, label rework
	1.1		08.09.2023  Add verification for Removal and uninstall option by security
						This will prevent any key or value that were not created by the script to be removed.
    1.0     06.09.2023	First version
.LINK
 #>

[void][System.Reflection.Assembly]::LoadWithPartialName('PresentationFramework')
[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
[System.Windows.Forms.Application]::EnableVisualStyles()

# Define the registry path,
$RegistryPath = "HKCU:\SOFTWARE\Microsoft\Direct3D"
$fail = $false

# Detect game in registry that have, populate combobox, default selection.
function Refresh-Game {
	$Listgame=@()
	$C_Listgame.Items.Clear()
	if ((Test-Path $RegistryPath)){
		$list = Get-ChildItem $RegistryPath
					if ($list){ 
						foreach ($entry in $list.name){
							$Game = $entry|split-path -leaf
							if ((Get-Item $RegistryPath\$game).Property -contains "D3DBehaviors"){
								if ((Get-Item $RegistryPath\$game).Property -contains "Name"){
									$C_Listgame.Items.add($game)
								}
							}
						}
					}
		$C_Listgame.SelectedIndex = $C_Listgame.Items.Count - 1
	}
}


#WPF form creation
$inputXML =@"
<Window x:Class="MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:AutoHdr2"
        mc:Ignorable="d"
        Title="AutoHdr" Height="313" Width="489">
    <Grid Margin="0,0,0,0">
        <Label Content="Select the action" HorizontalAlignment="Left" Margin="27,25,0,0" VerticalAlignment="Top"/>
        <RadioButton x:Name="R_install" Content="Install Game" HorizontalAlignment="Left" Margin="259,31,0,0" VerticalAlignment="Top"/>
        <RadioButton x:Name="R_remove" Content="Remove Game" HorizontalAlignment="Left" Margin="259,51,0,0" VerticalAlignment="Top"/>
        <RadioButton x:Name="R_uninstall" Content="Uninstall All" HorizontalAlignment="Left" Margin="259,71,0,0" VerticalAlignment="Top"/>
		<Label x:Name="T_Nametext" Content="Enter the name of the game" HorizontalAlignment="Left" Margin="33,115,0,0" VerticalAlignment="Top"/>
		<Label x:Name="T_NametextR" Content="Choose game to remove" HorizontalAlignment="Left" Margin="33,115,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="T_GameName" HorizontalAlignment="Left" Margin="307,119,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="120"/>
        <Label x:Name="T_Exetext" Content="Enter the game's exe name (ex: game.exe)" HorizontalAlignment="Left" Margin="33,143,0,0" VerticalAlignment="Top"/>	
        <TextBox x:Name="T_GameExe" HorizontalAlignment="Left" Margin="307,147,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="120"/>
		<Label x:Name="T_10Bit" Content="Optional setting for D3D Behaviors:" HorizontalAlignment="Left" Margin="50,183,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="C_10bit" Content="BufferUpgradeEnable10Bit" HorizontalAlignment="Left" Margin="287,188,0,0" VerticalAlignment="Top"/>
		<Button x:Name="B_Submit" Content="Submit" HorizontalAlignment="Left" Margin="20,230,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.265,0.155"/>
		<ComboBox Name="C_Listgame" HorizontalAlignment="Left" Margin="307,119,0,0" VerticalAlignment="Top" Width="120"/>
    </Grid>
</Window>

"@
# remove unneeded XAML options for powershell
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
[xml]$XAML = $inputXML
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window =[Windows.Markup.XamlReader]::Load( $reader )
$xaml.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name)}

# button, radiobox, text settings
$C_Listgame.visibility="Hidden"
$T_NametextR.visibility="Hidden"

$R_install.Add_Checked({
            $T_Nametext.visibility="Visible"
			$T_GameName.visibility="Visible"
			$T_Exetext.visibility="Visible"
			$T_GameExe.visibility="Visible"
			$T_10Bit.visibility="Visible"
			$C_10bit.visibility="Visible"
			$C_Listgame.visibility="Hidden"
			$T_NametextR.visibility="Hidden"
			$global:Action = "i"
			$B_Submit.Content="Install or update"
        })
		
$R_remove.Add_Checked({
			Refresh-Game
			$T_GameExe.Text=""
            $T_Nametext.visibility="Hidden"
			$T_GameName.visibility="Hidden"
			$T_NametextR.visibility="Visible"
			$T_Exetext.visibility="Hidden"
			$T_GameExe.visibility="Hidden"
			$T_10Bit.visibility="Hidden"
			$C_10bit.visibility="Hidden"
			$C_Listgame.visibility="Visible"
			$global:Action = "r"
			$B_Submit.Content="Remove Game"
        })

$R_Uninstall.Add_Checked({
			$T_GameName.Text=""
			$T_GameExe.Text=""
            $T_Nametext.visibility="Hidden"
			$T_GameName.visibility="Hidden"
			$T_Exetext.visibility="Hidden"
			$T_GameExe.visibility="Hidden"
			$T_10Bit.visibility="Hidden"
			$C_10bit.visibility="Hidden"
			$C_Listgame.visibility="Hidden"
			$T_NametextR.visibility="Hidden"
			$global:Action = "u"
			$B_Submit.Content="Uninstall all"
        })
		
$C_10bit.Add_Checked({
			$Global:10bit = $true
        })

$C_10bit.Add_UnChecked({
			$Global:10bit = $false
        })
		
#Code when clicking submit
$B_Submit.Add_Click({
	
    if ($global:Action -eq "i") {
		# Install action
		#test if game name and exe name are present in textbox and valid
		#Test if game is already present (to create regkey or not, then String value are created or updated)
		if ([string]::IsNullOrEmpty($T_GameName.Text)){
			$fail = $true
			[System.Windows.Forms.MessageBox]::Show("Enter the game name","",0,48)
		}
		if ([string]::IsNullOrEmpty($T_GameExe.Text)){
			$fail = $true
			[System.Windows.Forms.MessageBox]::Show("Enter the game Exe name","",0,48)
		}elseif (!($T_GameExe.Text -like '*.exe')){
					$fail = $true
					$T_GameExe.Foreground="Red"
					[System.Windows.Forms.MessageBox]::Show("The game exe name must end with '.exe'","",0,48)
					$T_GameExe.Foreground="Black"
		}elseif ($T_GameExe.Text.Length -eq 4){
				$fail = $true
				$T_GameExe.Foreground="Red"
				[System.Windows.Forms.MessageBox]::Show("Enter a valid exe name","",0,48)
				$T_GameExe.Foreground="Black"
		}
	    if ($fail -eq $false) {
			$Game = $T_GameName.Text
			$Name = $T_GameExe.Text
			if ($Global:10bit -eq $true) {
			$D3DBehaviors = "BufferUpgradeOverride=1;BufferUpgradeEnable10Bit=1"
		} else { $D3DBehaviors = "BufferUpgradeOverride=1" }

			try {
				if (-not (Test-Path $RegistryPath)) {
					New-Item -Path $RegistryPath -Force | Out-Null
				}
				if (-not (Test-Path $RegistryPath\$Game)) {
					$text = "created"
					New-Item $RegistryPath -Name $Game
				} else { $text = "updated" }
				Set-ItemProperty -Path "$RegistryPath\$Game" -Name "Name" -Value $Name
				Set-ItemProperty -Path "$RegistryPath\$Game" -Name "D3DBehaviors" -Value $D3DBehaviors
				[System.Windows.Forms.MessageBox]::Show("AutoHDR registry values for $Game $text.","",0,64)
			} catch {
				[System.Windows.Forms.MessageBox]::Show("Error installing AutoHDR registry values.`n$($_.Exception.Message)","",0,16)
			}
		}
    } elseif ($global:Action -eq "r") {
		# remove choice
		# test if game is present
		# Check if game is present in registry
		# delete key in registry
		# Check to not remove different key / value created by other program or manually by user.
		if ([string]::IsNullOrEmpty($C_Listgame.SelectedItem)){
			$fail = $true
			[System.Windows.Forms.MessageBox]::Show("No game found","",0,64)
		}
		$Game = $C_Listgame.SelectedItem
		if (-not (test-path $RegistryPath\$Game)){
			$fail = $true
			[System.Windows.Forms.MessageBox]::Show("$Game not found in registry","",0,64)
		}
			if ($fail -eq $false) {
				if ((Get-Item $RegistryPath\$game).Property -contains "D3DBehaviors"){
					try {
						Remove-ItemProperty -Path "$RegistryPath\$Game" -Name "D3DBehaviors"
					} catch { System.Windows.Forms.MessageBox]::Show("Error trying to remove AutoHDR registry property D3DBehaviors for $Game.","",0,16)}
				}
				if ((Get-Item $RegistryPath\$game).Property -contains "Name"){
					try {
						Remove-ItemProperty -Path "$RegistryPath\$Game" -Name "Name"
					} catch { System.Windows.Forms.MessageBox]::Show("Error trying to remove AutoHDR registry property Name for $Game.","",0,16)}
				}
				if ((Get-ChildItem $RegistryPath\$game).count -eq 0){
					if (((Get-Item $RegistryPath\$game).Property).count -eq 0){
						try{
							Remove-Item "$RegistryPath\$Game" -r
						} catch { System.Windows.Forms.MessageBox]::Show("Error trying to remove AutoHDR registry entries for $Game.","",0,16)}
					}
				}
				[System.Windows.Forms.MessageBox]::Show("AutoHDR registry entries for $Game removed.","",0,64)
				Refresh-Game
			}
	}elseif ($global:Action -eq "u") {
		# Uninstall choice
		# cehck all games in registry
		# delete key in registry if game is present
		# Check to not remove different key / value created by other program or manually by user.
		#Check to remove the Direct3D key (should be empty.)
		if ((Test-Path $RegistryPath)){
			$list = Get-ChildItem $RegistryPath
		}
		if ($list)
		{ 
			foreach ($entry in $list.name){
				$Game = $entry|split-path -leaf
				if ((Get-Item $RegistryPath\$game).Property -contains "D3DBehaviors"){
					try{
						Remove-ItemProperty -Path "$RegistryPath\$Game" -Name "D3DBehaviors"
					} catch { System.Windows.Forms.MessageBox]::Show("Error trying to remove AutoHDR registry property D3DBehaviors for $Game.","",0,16)}
				}
				if ((Get-Item $RegistryPath\$game).Property -contains "Name"){
					try {
							Remove-ItemProperty -Path "$RegistryPath\$Game" -Name "Name"
					} catch { System.Windows.Forms.MessageBox]::Show("Error trying to remove AutoHDR registry property Name for $Game.","",0,16)}
				}
				if ((Get-ChildItem $RegistryPath\$game).count -eq 0){
					if (((Get-Item $RegistryPath\$game).Property).count -eq 0){
						try{
							Remove-Item "$RegistryPath\$Game" -r
						} catch { System.Windows.Forms.MessageBox]::Show("Error trying to remove AutoHDR registry entries for $Game.","",0,16)}
					}
				}
				[System.Windows.Forms.MessageBox]::Show("$Game AutoHDR registry entries removed.","",0,64)
			}
			if ((Get-ChildItem $RegistryPath).count -eq 0){
				if (((Get-Item $RegistryPath).Property).count -eq 0){
					try {
						Remove-Item "$RegistryPath"
					} catch { System.Windows.Forms.MessageBox]::Show("Error trying to remove registry key Direct3D.","",0,16)}
				}
			}
			[System.Windows.Forms.MessageBox]::Show("All AutoHDR registry entries removed.","",0,64)
		} else {  
				[System.Windows.Forms.MessageBox]::Show("No game found in registry.","",0,64)
			}
	}	else {
				[System.Windows.Forms.MessageBox]::Show("Invalid action. Please select 'Install', 'Remove' or 'Uninstall'.","",0,64)
		}
})
# Display forms
$Window.ShowDialog() | out-null