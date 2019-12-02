<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Test
#>

Add-Type -AssemblyName System.Windows.Forms
Function GeneratePassword ([int]$Length)
{
    Add-Type -AssemblyName System.Web
    $CharSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{())};(/|'.ToCharArray()
    #Index1s 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
    #Index10s 0 1 2 3 4 5 6 7 8
    
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[]($Length)
    
    $rng.GetBytes($bytes)
    
    $Return = New-Object char[]($Length)
    
    For ($i = 0 ; $i -lt $Length ; $i++)
    {
        $Return[$i] = $CharSet[$bytes[$i]%$CharSet.Length]
    }
    
    Return (-join $Return)
}

[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "Test"
$Form.TopMost                    = $false

$Groupbox1                       = New-Object system.Windows.Forms.Groupbox
$Groupbox1.height                = 149
$Groupbox1.width                 = 248
$Groupbox1.text                  = "Group Box"
$Groupbox1.location              = New-Object System.Drawing.Point(25,34)

$RadioButton1                    = New-Object system.Windows.Forms.RadioButton
$RadioButton1.text               = "radioButton"
$RadioButton1.AutoSize           = $true
$RadioButton1.width              = 104
$RadioButton1.height             = 20
$RadioButton1.location           = New-Object System.Drawing.Point(13,19)
$RadioButton1.Font               = 'Microsoft Sans Serif,10'

$RadioButton2                    = New-Object system.Windows.Forms.RadioButton
$RadioButton2.text               = "radioButton"
$RadioButton2.AutoSize           = $true
$RadioButton2.width              = 104
$RadioButton2.height             = 20
$RadioButton2.location           = New-Object System.Drawing.Point(7,62)
$RadioButton2.Font               = 'Microsoft Sans Serif,10'

$RadioButton3                    = New-Object system.Windows.Forms.RadioButton
$RadioButton3.text               = "radioButton"
$RadioButton3.AutoSize           = $true
$RadioButton3.width              = 104
$RadioButton3.height             = 20
$RadioButton3.location           = New-Object System.Drawing.Point(8,110)
$RadioButton3.Font               = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($Groupbox1))
$Groupbox1.controls.AddRange(@($RadioButton1,$RadioButton2,$RadioButton3))

$Password = GeneratePassword(20)

$Label3 = New-Object System.Windows.Forms.Label
$Label3.Text = $Password
$Label3.Location  = New-Object System.Drawing.Point(200,200)
$Label3.AutoSize = $true
$Form.controls.Add($Label3)

$Form.ShowDialog()



