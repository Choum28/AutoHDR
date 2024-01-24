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
	1.5		24.01.2024	Add translation support (psd1 file)
	1.4		17.01.2024	Switch remaining Windows forms for WPF.
	1.3		10.09.2023	Add Icons in message, bug fix.
	1.2		09.09.2023	Add Combobox for removal, label rework
	1.1		08.09.2023  Add verification for Removal and uninstall option by security
						This will prevent any key or value that were not created by the script to be removed.
    1.0     06.09.2023	First version
.LINK
 #>

Add-Type -AssemblyName PresentationFramework

#load translation if exist, if not found will load en-US one.
Import-LocalizedData -BindingVariable txt

# Define the registry path,
$RegistryPath = "HKCU:\SOFTWARE\Microsoft\Direct3D"
$fail = $false

# Detect game in registry that have, populate combobox, default selection.
function Update-Game {
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
[xml]$inputXML =@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="AutoHdr" Height="313" Width="489">
    <Grid Margin="0,0,0,0">
        <Label Name="L_action" HorizontalAlignment="Left" Margin="27,25,0,0" VerticalAlignment="Top"/>
        <RadioButton Name="R_install" HorizontalAlignment="Left" Margin="259,31,0,0" VerticalAlignment="Top"/>
        <RadioButton Name="R_remove" HorizontalAlignment="Left" Margin="259,51,0,0" VerticalAlignment="Top"/>
        <RadioButton Name="R_uninstall" HorizontalAlignment="Left" Margin="259,71,0,0" VerticalAlignment="Top"/>
		<Label Name="T_Nametext" HorizontalAlignment="Left" Margin="33,115,0,0" VerticalAlignment="Top"/>
		<Label Name="T_NametextR" HorizontalAlignment="Left" Margin="33,115,0,0" VerticalAlignment="Top"/>
        <TextBox Name="T_GameName" HorizontalAlignment="Left" Margin="307,119,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="120"/>
        <Label Name="T_Exetext" HorizontalAlignment="Left" Margin="33,143,0,0" VerticalAlignment="Top"/>	
        <TextBox Name="T_GameExe" HorizontalAlignment="Left" Margin="307,147,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="120"/>
		<Label Name="T_10Bit" HorizontalAlignment="Left" Margin="50,183,0,0" VerticalAlignment="Top"/>
        <CheckBox Name="C_10bit" HorizontalAlignment="Left" Margin="287,188,0,0" VerticalAlignment="Top"/>
		<Button Name="B_Submit" HorizontalAlignment="Left" Margin="20,230,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.265,0.155"/>
		<ComboBox Name="C_Listgame" HorizontalAlignment="Left" Margin="307,119,0,0" VerticalAlignment="Top" Width="120"/>
    </Grid>
</Window>
"@

$reader=(New-Object System.Xml.XmlNodeReader $inputXML)
$Window =[Windows.Markup.XamlReader]::Load( $reader )
$inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name)}

# Add text to WPF.
$L_action.Content=$txt.main00
$R_install.Content=$txt.mainR1
$R_remove.Content=$txt.mainR2
$R_uninstall.Content=$txt.mainR3
$T_Nametext.Content=$txt.txt1
$T_NametextR.Content=$txt.txtr
$T_Exetext.Content=$txt.txtexe
$T_10Bit.Content=$txt.txt2
$C_10bit.Content=$txt.txtBuff

# button, radiobox, text settings and events
$C_Listgame.visibility="Hidden"
$T_NametextR.visibility="Hidden"
$B_Submit.visibility ="Hidden"

$R_install.Add_Checked({
            $T_Nametext.visibility="Visible"
			$T_GameName.visibility="Visible"
			$T_Exetext.visibility="Visible"
			$T_GameExe.visibility="Visible"
			$T_10Bit.visibility="Visible"
			$C_10bit.visibility="Visible"
			$C_Listgame.visibility="Hidden"
			$T_NametextR.visibility="Hidden"
			$B_Submit.visibility ="visible"
			$B_Submit.Content=$txt.ButtonI
        })
		
$R_remove.Add_Checked({
			Update-Game
			$T_GameExe.Text=""
            $T_Nametext.visibility="Hidden"
			$T_GameName.visibility="Hidden"
			$T_NametextR.visibility="Visible"
			$T_Exetext.visibility="Hidden"
			$T_GameExe.visibility="Hidden"
			$T_10Bit.visibility="Hidden"
			$C_10bit.visibility="Hidden"
			$C_Listgame.visibility="Visible"
			$B_Submit.visibility ="visible"
			$B_Submit.Content=$txt.ButtonR
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
			$B_Submit.visibility ="visible"
			$B_Submit.Content=$txt.ButtonU
        })
		
#Code when clicking submit
$B_Submit.Add_Click({
	
    if ($R_install.IsChecked) {
		# Install action
		#test if game name and exe name are present in textbox and valid
		#Test if game is already present (to create regkey or not, then String value are created or updated)
		if ([string]::IsNullOrEmpty($T_GameName.Text)){
			$fail = $true
			[System.Windows.MessageBox]::Show($txt.txt1,"",0,48)
		}
		if ([string]::IsNullOrEmpty($T_GameExe.Text)){
			$fail = $true
			[System.Windows.MessageBox]::Show($txt.txtexe,"",0,48)
		}elseif (!($T_GameExe.Text -like '*.exe')){
					$fail = $true
					$T_GameExe.Foreground="Red"
					[System.Windows.MessageBox]::Show($txt.exeend,"",0,48)
					$T_GameExe.Foreground="Black"
		}elseif ($T_GameExe.Text.Length -eq 4){
				$fail = $true
				$T_GameExe.Foreground="Red"
				[System.Windows.MessageBox]::Show($txt.validexe,"",0,48)
				$T_GameExe.Foreground="Black"
		}
	    if ($fail -eq $false) {
			$Game = $T_GameName.Text
			$Name = $T_GameExe.Text
			if ($C_10bit.IsChecked) {
			$D3DBehaviors = "BufferUpgradeOverride=1;BufferUpgradeEnable10Bit=1"
		} else { $D3DBehaviors = "BufferUpgradeOverride=1" }

			try {
				if (-not (Test-Path $RegistryPath)) {
					New-Item -Path $RegistryPath -Force | Out-Null
				}
				if (-not (Test-Path $RegistryPath\$Game)) {
					$text = $txt.st1
					New-Item $RegistryPath -Name $Game
				} else { $text = $txt.st2 }
				Set-ItemProperty -Path "$RegistryPath\$Game" -Name "Name" -Value $Name
				Set-ItemProperty -Path "$RegistryPath\$Game" -Name "D3DBehaviors" -Value $D3DBehaviors
				[System.Windows.MessageBox]::Show("$($Game) -> $($txt.ok1) $($text)","",0,64)
			} catch {
				[System.Windows.MessageBox]::Show("$($txt.ko1)`n$($_.Exception.Message)","",0,16)
			}
		}
    } elseif ($R_remove.IsChecked) {
		# remove choice
		# test if game is present
		# Check if game is present in registry
		# delete key in registry
		# Check to not remove different key / value created by other program or manually by user.
		if ([string]::IsNullOrEmpty($C_Listgame.SelectedItem)){
			$fail = $true
			[System.Windows.MessageBox]::Show($txt.Kofound,"",0,64)
		}else {
			$Game = $C_Listgame.SelectedItem
			if (-not (test-path $RegistryPath\$Game)){
				$fail = $true
				[System.Windows.MessageBox]::Show("$($Game) -> $($koreg)","",0,64)
			}
				if ($fail -eq $false) {
					if ((Get-Item $RegistryPath\$game).Property -contains "D3DBehaviors"){
						try {
							Remove-ItemProperty -Path "$RegistryPath\$Game" -Name "D3DBehaviors"
						} catch { System.Windows.MessageBox]::Show("$($Game) -> $($txt.kodel1)","",0,16)}
					}
					if ((Get-Item $RegistryPath\$game).Property -contains "Name"){
						try {
							Remove-ItemProperty -Path "$RegistryPath\$Game" -Name "Name"
						} catch { System.Windows.MessageBox]::Show("$($Game) -> $($txt.kodel2)","",0,16)}
					}
					if ((Get-ChildItem $RegistryPath\$game).count -eq 0){
						if (((Get-Item $RegistryPath\$game).Property).count -eq 0){
							try{
								Remove-Item "$RegistryPath\$Game" -r
							} catch { System.Windows.MessageBox]::Show("$($Game) -> $($txt.kodel3)","",0,16)}
						}
					}
					[System.Windows.MessageBox]::Show("$Game -> $($txt.ok1) $($txt.st3)","",0,64)
					Update-Game
			}
		}
	}else {
		# Uninstall choice
		# check all games in registry
		# delete key in registry if game is present
		# Check to not remove different key / value created by other program or manually by user.
		# Check to remove the Direct3D key (should be empty.)
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
					} catch { System.Windows.MessageBox]::Show("$($Game) -> $($txt.kodel1)","",0,16)}
				}
				if ((Get-Item $RegistryPath\$game).Property -contains "Name"){
					try {
							Remove-ItemProperty -Path "$RegistryPath\$Game" -Name "Name"
					} catch { System.Windows.MessageBox]::Show("$($Game) -> $($txt.kodel2)","",0,16)}
				}
				if ((Get-ChildItem $RegistryPath\$game).count -eq 0){
					if (((Get-Item $RegistryPath\$game).Property).count -eq 0){
						try{
							Remove-Item "$RegistryPath\$Game" -r
						} catch { System.Windows.MessageBox]::Show("$($Game) -> $($txt.kodel3)","",0,16)}
					}
				}
				[System.Windows.MessageBox]::Show("$($Game) -> $($txt.ok1) $($txt.st3)","",0,64)
			}
			if ((Get-ChildItem $RegistryPath).count -eq 0){
				if (((Get-Item $RegistryPath).Property).count -eq 0){
					try {
						Remove-Item "$RegistryPath"
					} catch { System.Windows.MessageBox]::Show($txt.kodel14,"",0,16)}
				}
			}
			[System.Windows.MessageBox]::Show($txt.oku,"",0,64)
		} else {  
				[System.Windows.MessageBox]::Show($txt.kou,"",0,64)
			}
	}
})
# Display forms
$Window.ShowDialog() | out-null
