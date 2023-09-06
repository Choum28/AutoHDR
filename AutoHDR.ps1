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
	
    1.0     06.09.2023	First version
.LINK
 #>

[void][System.Reflection.Assembly]::LoadWithPartialName('PresentationFramework')
[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
[System.Windows.Forms.Application]::EnableVisualStyles()

# Define the registry path,
$RegistryPath = "HKCU:\SOFTWARE\Microsoft\Direct3D"
$fail = $false
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
		<Label x:Name="T_Nametext" Content="Enter the name of the game (ex: Starfield)" HorizontalAlignment="Left" Margin="33,115,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="T_GameName" HorizontalAlignment="Left" Margin="307,119,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="120"/>
        <Label x:Name="T_Exetext" Content="Enter the game's exe name (ex: Starfield.exe)" HorizontalAlignment="Left" Margin="33,143,0,0" VerticalAlignment="Top"/>	
        <TextBox x:Name="T_GameExe" HorizontalAlignment="Left" Margin="307,147,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="120"/>
		<Label x:Name="T_10Bit" Content="Optional setting for D3D Behaviors:" HorizontalAlignment="Left" Margin="50,183,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="C_10bit" Content="BufferUpgradeEnable10Bit" HorizontalAlignment="Left" Margin="287,188,0,0" VerticalAlignment="Top"/>
		<Button x:Name="B_Submit" Content="Submit" HorizontalAlignment="Left" Margin="20,230,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.265,0.155"/>
    </Grid>
</Window>

"@
# function to remove unneeded XAML options for powershell
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
[xml]$XAML = $inputXML
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window =[Windows.Markup.XamlReader]::Load( $reader )
$xaml.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name)}

# button, radiobox, text settings
$R_install.Add_Checked({
            $T_Nametext.IsEnabled=$True
			$T_GameName.IsEnabled=$True
			$T_Exetext.IsEnabled=$True
			$T_GameExe.IsEnabled=$True
			$T_10Bit.IsEnabled=$True
			$C_10bit.IsEnabled=$True
			$global:Action = "i"
        })
		
$R_remove.Add_Checked({
			$T_GameExe.Text=""
            $T_Nametext.IsEnabled=$True
			$T_GameName.IsEnabled=$True
			$T_Exetext.IsEnabled=$False
			$T_GameExe.IsEnabled=$False
			$T_10Bit.IsEnabled=$False
			$C_10bit.IsEnabled=$False
			$global:Action = "r"
        })

$R_Uninstall.Add_Checked({
			$T_GameName.Text=""
			$T_GameExe.Text=""
            $T_Nametext.IsEnabled=$False
			$T_GameName.IsEnabled=$False
			$T_Exetext.IsEnabled=$False
			$T_GameExe.IsEnabled=$False
			$T_10Bit.IsEnabled=$False
			$C_10bit.IsEnabled=$False
			$global:Action = "u"
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
		#test if game name and exe name are present in textbox
		#Test if game is already present (to create regkey or not, then String value are created or updated)
		if ([string]::IsNullOrEmpty($T_GameName.Text)){
			$fail = $true
			[System.Windows.Forms.MessageBox]::Show("Enter the game name")
		}
		if ([string]::IsNullOrEmpty($T_GameExe.Text)){
			$fail = $true
			[System.Windows.Forms.MessageBox]::Show("Enter the game Exe name")
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
				New-Item $RegistryPath -Name $Game
				}
				Set-ItemProperty -Path "$RegistryPath\$Game" -Name "Name" -Value $Name
				Set-ItemProperty -Path "$RegistryPath\$Game" -Name "D3DBehaviors" -Value $D3DBehaviors

				[System.Windows.Forms.MessageBox]::Show("Registry values for $Game installed.")
			} catch {
				[System.Windows.Forms.MessageBox]::Show("Error installing registry values.`n$($_.Exception.Message)")
			}
		}
    } elseif ($global:Action -eq "r") {
		# remove choice
		# test if game is present
		# Check if game is present in registry
		# delete key in registry
		if ([string]::IsNullOrEmpty($T_GameName.Text)){
			$fail = $true
			[System.Windows.Forms.MessageBox]::Show("Enter the game name")
		}
		$Game = $T_GameName.Text
		if (-not (test-path $RegistryPath\$Game)){
			$fail = $true
			[System.Windows.Forms.MessageBox]::Show("$Game not found in registry")
		}
			if ($fail -eq $false) {
				try {
					Remove-Item "$RegistryPath\$Game" -r
				} catch { System.Windows.Forms.MessageBox]::Show("Error trying to remove Registry entries for $Game.")
				}
				[System.Windows.Forms.MessageBox]::Show("Registry entries for $Game removed.")	
				
			}
		}elseif ($global:Action -eq "u") {
		# Uninstall choice
		# cehck all games in registry
		# delete key in registry if game is present
		$list = Get-ChildItem $RegistryPath
		if ($list){ 
			foreach ($entry in $list.name){
			$Game = $entry|split-path -leaf
			Remove-Item "$RegistryPath\$Game" -r
			[System.Windows.Forms.MessageBox]::Show("$Game registry entries removed.")
			}
			[System.Windows.Forms.MessageBox]::Show("All registry entries removed.")
		} else {  [System.Windows.Forms.MessageBox]::Show("No game found in registry.")
		}
	}	else {
        [System.Windows.Forms.MessageBox]::Show("Invalid action. Please select 'Install', 'Remove' or 'Uninstall'.")
    }
})
# Display forms
$Window.ShowDialog() | out-null