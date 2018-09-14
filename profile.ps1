##########Madhukar#########
## I keep this updated when ever I get add new Function to Automate my mundane work

# Change Title of Powershell Window
$Host.UI.RawUI.WindowTitle = "moogalm"

# Gets full Computer Infomation
Function Get-ComputerInformation {
    PARAM ($ComputerName)
    # Computer System
    $ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName
    # Operating System
    $OperatingSystem = Get-WmiObject -class win32_OperatingSystem -ComputerName $ComputerName
    # BIOS
    $Bios = Get-WmiObject -class win32_BIOS -ComputerName $ComputerName
    
    # Prepare Output
    $Properties = @{
        ComputerName           = $ComputerName
        Manufacturer           = $ComputerSystem.Manufacturer
        Model                  = $ComputerSystem.Model
        OperatingSystem        = $OperatingSystem.Caption
        OperatingSystemVersion = $OperatingSystem.Version
        SerialNumber           = $Bios.SerialNumber
    }
    
    # Output Information
    New-Object -TypeName PSobject -Property $Properties
    
}

# Outputs System Uptime
Function UpTime {
    $Os = Get-WmiObject -Class Win32_OperatingSystem
    $TimeSpan = [DateTime]$Os.ConvertToDateTime($Os.LocalDateTime) - [DateTime]$Os.ConvertToDateTime($Os.LastBootUpTime)
    Write-Host "In HH::MM::SS $TimeSpan"
}

#Copying large file to remote VC machines
#Usage: rcopy -Source "C:\M\TestCADInstaller.zip" -Destination \\10.50.84.241\Share\OEM
Function rcopy {
    [CmdletBinding(DefaultParameterSetName="Source")]
    param(
        [parameter (Mandatory = $True,Position=0)]
        [string]$Source,
        [parameter (Mandatory = $True,Position=1)]
        [string]$Destination
    )
    Import-Module BitsTransfer
    $Description = [System.IO.Path]::GetFileNameWithoutExtension($Source)
    $Description = "Copying " + $Description + "...."
    Start-BitsTransfer -Source $Source -Destination $Destination -Description $Description -DisplayName "Copying to Virtual Image"
}

Function rdownload {
    param ([string] $srcUrl)
    Import-Module BitsTransfer
    $outFileName = [System.IO.Path]::GetFileNameWithoutExtension($srcUrl)
    $start_time = Get-Date
    #$Description = $outFileName + "Downloading...."
    Start-BitsTransfer -Source $srcUrl -Destination $outFileName
    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}

Function gldir {

    (Get-ChildItem -Directory | Sort-Object CreationTime -descending)[0].FullName | Set-Location

}

#To get AWS S3 URI with given input of bucket:
#ex: getAwsUrl -s3path s3://fpd-uploads
Function getAwsUrl {
    [CmdletBinding(DefaultParameterSetName = "S3Path")]
    param(
        [parameter (ParameterSetName = "S3Path", mandatory = $true)]$s3path,
        [parameter (ParameterSetName = "Bucket")]$bucket,
        [parameter (ParameterSetName = "Key", mandatory = $true)]$key 
    )
    if ($s3path) {
        $splits = $s3path.Split('//')
        $bucket = $splits[2]
        $key = $splits[3]
    }
    else {
        #user input bucket and key
        $bucket = $bucket
        $key = $key
    }

    #using standard aws region "us-west-2"
    Write-Output "https://$bucket.s3.us-west-2.amazonaws.com/$key"
}

#Usage:IsAOEMInstallerXMLTruePath -Path "C:\Users\Default\Documents\AutoCAD OEM 2019\installer\TestCADInstallerSettings\TestCAD.xml"
Function IsAOEMInstallerXMLTruePath {
    #A util Test if Installer XML file holds valid paths
    [CmdletBinding(DefaultParameterSetName = "Path")]
    param(
        [parameter (ParameterSetName = "Path", mandatory = $true)]$Path    
    )
    if (Test-Path -Path $Path) {
        [xml]$f = Get-Content $Path
        $a = $f.OemInstallerWizard.ProductDescriptor
        $b = $f.OemInstallerWizard.SDKDescriptor
        Write-Host($b.AoemExePath)
        Write-Host(Test-Path -Path $b.AoemExePath)
        Write-Host($b.MasterRoot)
        Write-Host(Test-Path -Path $b.MasterRoot)
        $keys = @('TargetDir', 'MakeWizardConfigFile', 'BuildLocation', 'LicenseFile', 'BackgroundImage', 'InfotainmentImage', 'ProductlogoImage', 'CompanylogoImage', 'SetupIconImage')
        foreach ($key in $keys) {
            Write-Host($a.$key)
            Write-Host(Test-Path -Path $a.$key)
        }
    }
}